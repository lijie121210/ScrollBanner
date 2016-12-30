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
    
    /// Saving all indicators
    fileprivate var items:[ProgressView] = []

    /// Click action callback
    var selectedAction: ProgressPageControlAction?
    
    
    var lineSpace: CGFloat = 8.0 {
        didSet {
            if oldValue != lineSpace {
                updateIndicatorFrame()
            }
        }
    }
    
    /// Update apperence
    
    var hidesForSinglePage: Bool = false {
        didSet {
            checkHidesForSinglePage()
        }
    }
    
    var pageIndicatorTintColor: UIColor? = UIColor(white: 0.9, alpha: 0.9) {
        didSet {
            guard items.isEmpty == false else {
                return
            }
            items.forEach { (p) in
                p.backgroundColor = pageIndicatorTintColor
            }
        }
    }
    
    var currentPageIndicatorTintColor: UIColor? = UIColor.gray {
        didSet {
            guard items.isEmpty == false else {
                return
            }
            items.forEach { (p) in
                p.bar.strokeColor = currentPageIndicatorTintColor?.cgColor
            }
        }
    }
    
    var numberOfPages: Int = 0 {
        willSet {
            cleanupIndicator()
        }
        didSet {
            for _ in 0 ..< numberOfPages {
                items.append( createIndicator() )
            }
            updateIndicatorFrame()
            
            checkHidesForSinglePage()
        }
    }
    
    var currentPage: Int = -1 {
        didSet {
            guard currentPage != oldValue && currentPage >= 0 && currentPage < items.count else {
                return
            }
            items[oldValue > 0 ? oldValue : 0].disableAnimation()
            items[currentPage].enableAnimation()
        }
    }
    
    fileprivate var layoutDirection: BannerScrollDirection {
        return isHorizontal ? .horizontal : .vertical
    }

    /// Height for each indicator
    var indicatorLength: CGFloat = 2.0 {
        didSet {
            if oldValue != indicatorLength {
                updateIndicatorFrame()
            }
        }
    }
    
    /// Limit width for each indicator
    var indicatorContentWidthLimit: CGFloat = 60.0 {
        didSet {
            if oldValue != indicatorContentWidthLimit {
                updateIndicatorFrame()
            }
        }
    }
    
    /// Limit height for each indicator
    var indicatorContentHeightLimit: CGFloat = 60.0 {
        didSet {
            if oldValue != indicatorContentHeightLimit {
                updateIndicatorFrame()
            }
        }
    }
    
    /// Size for each indicator
    ///
    /// Calculated depends on items.count and layoutDirection
    var indicatorSize: CGSize {
        var resultW: CGFloat = indicatorLength
        var resultH: CGFloat = indicatorLength
        
        if (numberOfPages == 0) {
            return CGSize.zero
        }
        
        switch layoutDirection {
        case .horizontal:
            let width = max( 0.0, ( bounds.width - lineSpace * CGFloat(numberOfPages + 1) ) ) / CGFloat(numberOfPages)
            resultW = min(width, indicatorContentWidthLimit)
        case .vertical:
            let height = max( 0.0, ( bounds.height - lineSpace * CGFloat(numberOfPages + 1) ) ) / CGFloat(numberOfPages)
            resultH = min(height, indicatorContentHeightLimit)
        }
        
        return CGSize(width: resultW, height: resultH)
    }
    
    /// Help calculate originX of first indicator
    var indicatorContentLength: CGFloat {
        if numberOfPages == 0 {
            return 0.0
        }
        var result: CGFloat = 0.0
        
        switch layoutDirection {
        case .horizontal:
            result = indicatorSize.width
        case .vertical:
            result = indicatorSize.height
        }
        
        return CGFloat(numberOfPages) * ( result + lineSpace) - lineSpace
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
    
    /// - return Longest length
    func size(forNumberOfPages pageCount: Int) -> CGSize {
        switch layoutDirection {
        case .horizontal: return CGSize(width: indicatorContentLength, height: indicatorLength)
        case .vertical: return CGSize(width: indicatorLength, height: indicatorContentLength)
        }
    }
    
    /// check should hides
    fileprivate func checkHidesForSinglePage() {
        if numberOfPages == 1 && hidesForSinglePage {
            isHidden = true
        } else {
            isHidden = false
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
        items.forEach { (p) in
            p.disableAnimation()
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
    fileprivate func createIndicator() -> ProgressView {
        let p = ProgressView(frame: CGRect(origin: CGPoint.zero, size: indicatorSize))
        p.backgroundColor = pageIndicatorTintColor
        p.bar.strokeColor = currentPageIndicatorTintColor?.cgColor
        addSubview(p)
        return p
    }
    
    fileprivate func cleanupIndicator() {
        guard items.isEmpty == false, numberOfPages > 0 else {
            return
        }
        items.forEach { $0.removeFromSuperview() }
        items.removeAll()
        items = []
    }
    
    
    /// Update frame
    
    fileprivate func updateIndicatorFrame() {
        guard items.isEmpty == false else {
            return
        }
        for i in 0 ..< items.count {
            items[i].frame = frame(at: i)
        }
    }
    
    /// calculate frame of indicator and update it's frame
    fileprivate func frame(at index: Int) -> CGRect {
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




