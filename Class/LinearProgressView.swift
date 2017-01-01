//
//  LinearProgressView.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/30.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import UIKit


//public extension CAAnimation.Keys {
//
//}
public extension BannerAnimation.Keys {
    public static let linearProgressStrokeEnd = "LinearProgressView_end_animate_key"
}

class LinearProgressView: UIView, CAAnimationDelegate {
    
    var bar: CAShapeLayer
    var endanimate: CABasicAnimation
    var isAnimatable: Bool = true
    
    /// CAAnimationDelegate
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim is CABasicAnimation {
            bar.strokeEnd = 0.001
        }
    }
    
    /// Life Cycle
    
    deinit {
        print("LinearProgressView.deinit")
    }
    
    override init(frame: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: frame.width, y: 0.0))
        
        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.lineWidth = frame.height
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeEnd = 0.001
        
        let end = CABasicAnimation(keyPath: "strokeEnd")
        end.fromValue = 0.001
        end.toValue = 1.001
        end.duration = 2.7
        end.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        end.isRemovedOnCompletion = true
        
        bar = shape
        endanimate = end
        super.init(frame: frame)
        endanimate.delegate = self
        self.layer.addSublayer(bar)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        var f = CGRect.zero
        var w: CGFloat = 0.0
        
        let path = UIBezierPath()
        path.move(to: CGPoint.zero)
        
        if layer.isHorizontal {
            f = CGRect(x: 0, y: layer.bounds.height * 0.5, width: layer.bounds.width, height: layer.bounds.height)
            w = layer.bounds.height
            path.addLine(to: CGPoint(x: layer.bounds.width, y: 0.0))
            
        } else {
            f = CGRect(x: layer.bounds.width * 0.5, y: 0, width: layer.bounds.width, height: layer.bounds.height)
            w = layer.bounds.width
            path.addLine(to: CGPoint(x: 0, y: layer.bounds.height))
        }
        bar.frame = f
        bar.path = path.cgPath
        bar.lineWidth = w
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            endanimate.delegate = nil
            bar.removeAllAnimations()
            bar.removeFromSuperlayer()
        }
    }
    
    fileprivate func enableAnimation() {
        if let _ = bar.animation(forKey: BannerAnimation.Keys.linearProgressStrokeEnd) {
            bar.removeAnimation(forKey: BannerAnimation.Keys.linearProgressStrokeEnd)
        }
        if isAnimatable {
            bar.add(endanimate, forKey: BannerAnimation.Keys.linearProgressStrokeEnd)
        }
    }
    
    fileprivate func disableAnimation() {
        if let _ = bar.animation(forKey: BannerAnimation.Keys.linearProgressStrokeEnd) {
            bar.removeAnimation(forKey: BannerAnimation.Keys.linearProgressStrokeEnd)
        }
    }
    

}

/// BannerPageItem

extension LinearProgressView: BannerPageItem {
    
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
            return bar.strokeColor == nil ? nil : UIColor(cgColor: bar.strokeColor!)
        }
        set {
            if newValue?.cgColor != bar.strokeColor {
                bar.strokeColor = newValue?.cgColor
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

