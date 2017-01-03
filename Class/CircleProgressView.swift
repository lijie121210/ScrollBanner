//
//  CircleProgressView.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/31.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import UIKit


public extension BannerAnimation.Keys {
    public static let CircleProgressStrokeEnd = "CircleProgressView_end_animate_key"
}


public class CircleProgressView: UIView, CAAnimationDelegate {
    
    var outline: CAShapeLayer
    var ring: CAShapeLayer
    var endanimate: CABasicAnimation
    var isAnimatable: Bool = true
    
    /// CAAnimationDelegate
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim is CABasicAnimation {
            ring.strokeEnd = 0.001
        }
    }
    
    /// Life Cycle
    
    deinit {
        print("CircleProgressView.deinit")
    }
    
    override init(frame: CGRect) {
        
        var radius = frame.width * 0.5
        if frame.width > frame.height {
            radius = frame.height * 0.5
        }
        let offset: CGFloat = 1.0
        let point = CGPoint(x: frame.width * 0.5, y: frame.height * 0.5)
        let sangle: CGFloat = 0.0
        let eangle = CGFloat(M_PI * 2.0)
        
        let outlinePath = UIBezierPath(arcCenter: point, radius: radius, startAngle: sangle, endAngle: eangle, clockwise: true)
        let inlinePath = UIBezierPath(arcCenter: point, radius: (radius - offset) * 0.5, startAngle: sangle, endAngle: eangle, clockwise: true)
        
        let outlineLayer = CAShapeLayer()
        outlineLayer.path = outlinePath.cgPath
        outlineLayer.lineWidth = 1.0
        outlineLayer.strokeEnd = 1.0
        outlineLayer.fillColor = UIColor.clear.cgColor
        
        let inlineLayer = CAShapeLayer()
        inlineLayer.path = inlinePath.cgPath
        inlineLayer.lineWidth = radius - offset
        inlineLayer.strokeEnd = 0.001
        inlineLayer.fillColor = UIColor.clear.cgColor
        
        let end = CABasicAnimation(keyPath: "strokeEnd")
        end.fromValue = 0.001
        end.toValue = 1.001
        end.duration = 2.7
        end.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        end.isRemovedOnCompletion = true
        
        outline = outlineLayer
        ring = inlineLayer
        endanimate = end
        
        super.init(frame: frame)
        
        endanimate.delegate = self
        self.layer.addSublayer(outlineLayer)
        self.layer.addSublayer(inlineLayer)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        ring.frame = layer.bounds
        
        print("layoutSublayers ", layer)
    }
    override public func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            endanimate.delegate = nil
            ring.removeAllAnimations()
            ring.removeFromSuperlayer()
            outline.removeFromSuperlayer()
        }
    }
    
    fileprivate func enableAnimation() {
        if let _ = ring.animation(forKey: BannerAnimation.Keys.CircleProgressStrokeEnd) {
            ring.removeAnimation(forKey: BannerAnimation.Keys.CircleProgressStrokeEnd)
        }
        if isAnimatable {
            ring.add(endanimate, forKey: BannerAnimation.Keys.CircleProgressStrokeEnd)
        }
    }
    
    fileprivate func disableAnimation() {
        if let _ = ring.animation(forKey: BannerAnimation.Keys.CircleProgressStrokeEnd) {
            ring.removeAnimation(forKey: BannerAnimation.Keys.CircleProgressStrokeEnd)
        }
    }
}


/// BannerPageItem

extension CircleProgressView: BannerPageItem {
    
    public var isFocusable: Bool {
        get {
            return isAnimatable
        }
        set {
            if isAnimatable != newValue {
                isAnimatable = newValue
            }
        }
    }
    
    public var normalTintColor: UIColor? {
        get {
            return outline.strokeColor == nil ? nil : UIColor(cgColor: outline.strokeColor!)
        }
        set {
            if newValue?.cgColor != outline.strokeColor {
                outline.strokeColor = newValue?.cgColor
            }
        }
    }
    
    public var highlightTintColor: UIColor? {
        get {
            return ring.strokeColor == nil ? nil : UIColor(cgColor: ring.strokeColor!)
        }
        set {
            if newValue?.cgColor != ring.strokeColor {
                ring.strokeColor = newValue?.cgColor
            }
        }
    }
    
    public func becomeFocus() {
        enableAnimation()
    }
    
    public func resignFocus() {
        disableAnimation()
    }
}
