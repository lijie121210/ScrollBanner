//
//  ProgressControl.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/27.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import UIKit

/// type define
///
typealias ProgressPageControlAction = (_ control: ProgressPageControl, _ atIndex: Int) -> ()

/// ProgressPageControl
///
/// Using UIProgressView to indicate number of pages and animation
///
class ProgressPageControl: UIControl {
    
    private var items:[ProgressView] = []

    /// Click action callback
    var selectedAction: ProgressPageControlAction?
    
    
    var lineSpace: CGFloat = 8.0 {
        willSet {
            if newValue != lineSpace {
                updateIndicatorFrame()
            }
        }
    }
    
    /// Update apperence
    
    var indicatorTintColor: UIColor = UIColor(white: 0.9, alpha: 0.9) {
        didSet {
            guard items.isEmpty == false else {
                return
            }
            items.forEach { (p) in
                p.backgroundColor = indicatorTintColor
            }
        }
    }
    
    var indicatorTrackingColor: UIColor = UIColor.gray {
        didSet {
            guard items.isEmpty == false else {
                return
            }
            items.forEach { (p) in
                p.bar.strokeColor = indicatorTrackingColor.cgColor
            }
        }
    }
    
    var numberOfpages: Int = 0 {
        willSet {
            cleanupIndicator()
        }
        didSet {
            for index in 0 ..< numberOfpages {
                let p = createIndicator()
                p.frame = frame(at: index)
                items.append(p)
            }
            if numberOfpages == 1 {
                isHidden = true
            }
        }
    }
    
    /// If new currentPage == old currentPage, isSkip is true
    fileprivate var isSkip: Bool = false
    
    var currentPage: Int = -1 {
        willSet {
            isSkip = (currentPage == newValue && newValue >= 0 && newValue < items.count)
        }
        didSet {
            guard isSkip == false else {
                return
            }
            items[currentPage].animate()
        }
    }
    
    fileprivate var layoutDirection: BannerScrollDirection {
        return isHorizontal ? .horizontal : .vertical
    }

    /// Height for each indicator
    var indicatorLength: CGFloat = 2.0
    
    /// Limit width for each indicator
    var indicatorContentWidthLimit: CGFloat = 60.0
    
    /// Limit height for each indicator
    var indicatorContentHeightLimit: CGFloat = 60.0
    
    /// Size for each indicator
    ///
    /// Calculated depends on items.count and layoutDirection
    var indicatorSize: CGSize {
        var resultW: CGFloat = indicatorLength
        var resultH: CGFloat = indicatorLength
        
        if (numberOfpages == 0) {
            return CGSize.zero
        }
        
        switch layoutDirection {
        case .horizontal:
            let width = max( 0.0, ( bounds.width - lineSpace * CGFloat(numberOfpages + 1) ) ) / CGFloat(numberOfpages)
            resultW = min(width, indicatorContentWidthLimit)
        case .vertical:
            let height = max( 0.0, ( bounds.height - lineSpace * CGFloat(numberOfpages + 1) ) ) / CGFloat(numberOfpages)
            resultH = min(height, indicatorContentHeightLimit)
        }
        
        return CGSize(width: resultW, height: resultH)
    }
    
    /// Help calculate originX of first indicator
    var indicatorContentLength: CGFloat {
        if numberOfpages == 0 {
            return 0.0
        }
        var result: CGFloat = 0.0
        
        switch layoutDirection {
        case .horizontal:
            result = indicatorSize.width
        case .vertical:
            result = indicatorSize.height
        }
        
        return CGFloat(numberOfpages) * ( result + lineSpace) - lineSpace
    }

    
    override var frame: CGRect {
        didSet {
            updateIndicatorFrame()
            
            layoutIfNeeded()
        }
    }
    

    deinit {
        print("ProgressPageControl.deinit")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {        
        if newSuperview == nil {
            cleanupIndicator()
        }
    }
    
    /// Touch event
    ///
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first,
            let posv = touch.view as? ProgressView,
            let index = items.index(of: posv),
            let action = selectedAction {
            
            action(self, index)
        }
        super.touchesEnded(touches, with: event)
    }
    
    func disableAnimation() {
        guard items.isEmpty == false, currentPage >= 0, currentPage < items.count else {
            return
        }
        items[currentPage].cancelAnimation()
        items.forEach { (p) in
            p.isAnimatable = false
        }
    }
    
    func enableAnimation() {
        guard items.isEmpty == false, currentPage >= 0, currentPage < items.count else {
            return
        }
        items.forEach { (p) in
            p.isAnimatable = true
        }
    }
    
    /// create a UIProgressView instance and add it to super view (self)
    private func createIndicator() -> ProgressView {
        let p = ProgressView(frame: CGRect(origin: CGPoint.zero, size: indicatorSize))
        p.backgroundColor = indicatorTintColor
        p.bar.strokeColor = indicatorTrackingColor.cgColor
        addSubview(p)
        return p
    }
    
    private func cleanupIndicator() {
        guard items.isEmpty == false, numberOfpages > 0 else {
            return
        }
        items.forEach { $0.removeFromSuperview() }
        items.removeAll()
    }
    
    
    /// Update frame
    
    func updateIndicatorFrame() {
        guard items.isEmpty == false else {
            return
        }
        for i in 0 ..< items.count {
            items[i].frame = frame(at: i)
        }
    }
    
    /// calculate frame of indicator and update it's frame
    private func frame(at index: Int) -> CGRect {
        let size = indicatorSize
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        
        switch layoutDirection {
        case .horizontal:
            x = (bounds.width - indicatorContentLength) * 0.5 + (lineSpace + size.width) * CGFloat(index)
            y = (bounds.height - size.height) * 0.5
        case .vertical:
            x = (bounds.width - size.width) * 0.5
            y = (bounds.height - indicatorContentLength) * 0.5 + (lineSpace + size.height) * CGFloat(index)
        }
        
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
    
    
    
}






