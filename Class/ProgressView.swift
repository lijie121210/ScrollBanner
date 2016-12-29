//
//  ProgressView.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/28.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import UIKit

class ProgressView: UIView, CAAnimationDelegate {
    
    /// Set strokeColor / strokeStart / strokeEnd ...
    var bar: CAShapeLayer
    
    /// Set duration / timingFunction ...
    var endanimate: CABasicAnimation
    
    ///
    var isAnimatable: Bool = true
    
    fileprivate let endAnimateKey: String = "end_animate_key"
    
    override init(frame: CGRect) {
        
        let path = UIBezierPath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: frame.width, y: 0.0))
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.lineWidth = frame.height
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.white.cgColor
        layer.strokeEnd = 0.001
        
        let end = CABasicAnimation(keyPath: "strokeEnd")
        end.fromValue = 0.001
        end.toValue = 1.001
        end.duration = 2.8
        end.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        end.isRemovedOnCompletion = true
        
        bar = layer

        endanimate = end
        
        super.init(frame: frame)
        
        endanimate.delegate = self
        
        self.layer.addSublayer(bar)
        
        backgroundColor = UIColor(white: 0.8, alpha: 0.9)
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
            bar.removeAllAnimations()
            bar.removeFromSuperlayer()
        }
    }
    
    /// For beginning or stopping animation
    
    func animate() {
        if let _ = bar.animation(forKey: endAnimateKey) {
            bar.removeAnimation(forKey: endAnimateKey)
        }
        if isAnimatable {
            bar.add(endanimate, forKey: endAnimateKey)
        }
    }
    
    func cancelAnimation() {
        if let _ = bar.animation(forKey: endAnimateKey) {
            bar.removeAnimation(forKey: endAnimateKey)
        }
    }
    
    
    
    /// CAAnimationDelegate
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim is CABasicAnimation {
            bar.strokeEnd = 0.001
        }
    }
}
