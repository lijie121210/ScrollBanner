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


class CircleProgressView: UIView, CAAnimationDelegate {
    
    var ring: CAShapeLayer
    var endanimate: CABasicAnimation
    var isAnimatable: Bool = true
    
    /// CAAnimationDelegate
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim is CABasicAnimation {
            ring.strokeEnd = 0.001
        }
    }
    
    /// Life Cycle
    
    deinit {
        print("CircleProgressView.deinit")
    }
    
    override init(frame: CGRect) {
        let path = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: frame.size))
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.lineWidth = 1
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeEnd = 0.001
        
        let end = CABasicAnimation(keyPath: "strokeEnd")
        end.fromValue = 0.001
        end.toValue = 1.001
        end.duration = 2.7
        end.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        end.isRemovedOnCompletion = true
        
        ring = shape
        endanimate = end
        super.init(frame: frame)
        endanimate.delegate = self
        self.layer.addSublayer(ring)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        let path = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: layer.bounds.size))
        
        ring.frame = layer.bounds
        ring.path = path.cgPath
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            endanimate.delegate = nil
            ring.removeAllAnimations()
            ring.removeFromSuperlayer()
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
    
    var isFocusable: Bool {
        get {
            return isAnimatable
        }
        set {
            if isAnimatable != newValue {
                isAnimatable = newValue
            }
        }
    }
    
    var normalTintColor: UIColor? {
        get {
            return backgroundColor
        }
        set {
            if newValue != backgroundColor {
                backgroundColor = newValue
            }
        }
    }
    
    var highlightTintColor: UIColor? {
        get {
            return ring.strokeColor == nil ? nil : UIColor(cgColor: ring.strokeColor!)
        }
        set {
            if newValue?.cgColor != ring.strokeColor {
                ring.strokeColor = newValue?.cgColor
            }
        }
    }
    
    func becomeFocus() {
        enableAnimation()
    }
    
    func resignFocus() {
        disableAnimation()
    }
}
