//
//  BannerPageControl.swift
//  ScrollBanner
//
//  Created by jie on 2017/1/2.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

/// class definition
///
/// Instead of using this class directly, instead, you should inherit this class to implement customization of the indicator layout.
/// On inheritance, the init(_:) method must be overrided.
/// When you override createIndicator(), you can adjust the appearance of indicators.
/// In general, inheritance of this class is quite easy.
///
/// In addition, you can completely create a class to implement the protocol (BannerControlItem) instead of inheriting this class.
///
open class BannerPageControl <T: UIView> : UIControl, BannerControlItem  where T: BannerPageItem {
    
    open var items:[T] = []
    
    open var jumpToIndex: Int = -1
    
    open var numberOfPages: Int = 0 {
        willSet {
            cleanupIndicator()
        }
        didSet {
            indicatorLayout.indicatorCount = numberOfPages
            
            for _ in 0 ..< numberOfPages {
                items.append( createIndicator() )
            }
            updateIndicatorFrame()
            
            checkHidesForSinglePage()
        }
    }
    
    /// Setting -1 to currentPage to remove old value
    open var currentPage: Int = -1 {
        didSet {
            guard currentPage != oldValue, currentPage >= 0 && currentPage < items.count, oldValue < items.count else {
                return
            }
            if oldValue >= 0 {
                items[oldValue].resignFocus()
            }
            items[currentPage].becomeFocus()
        }
    }
    
    open var hidesForSinglePage: Bool = false {
        didSet {
            checkHidesForSinglePage()
        }
    }
    
    open var pageIndicatorTintColor: UIColor? {
        didSet {
            guard items.isEmpty == false else {
                return
            }
            items.forEach { $0.normalTintColor = pageIndicatorTintColor }
        }
    }
    
    open var currentPageIndicatorTintColor: UIColor? {
        didSet {
            guard items.isEmpty == false else {
                return
            }
            items.forEach { $0.highlightTintColor = currentPageIndicatorTintColor }
        }
    }
    
    open var layoutDirection: BannerScrollDirection {
        return isHorizontal ? .horizontal : .vertical
    }
    
    /// Size for each indicator
    
    /// override and init
    open var indicatorLayout: BannerControlItemLayout
    
    open var indicatorSize: CGSize {
        if (numberOfPages == 0) {
            return CGSize.zero
        }
        switch layoutDirection {
        case .horizontal: return indicatorLayout.indicatorHorizontalSize()
        case .vertical: return indicatorLayout.indicatorVerticalSize()
        }
    }
    
    open var indicatorContentLength: CGFloat {
        if numberOfPages == 0 {
            return 0.0
        }
        switch layoutDirection {
        case .horizontal: return indicatorLayout.indicatorHorizontalContentLength()
        case .vertical: return indicatorLayout.indicatorVerticalContentLength()
        }
    }
    
    open func size(forNumberOfPages pageCount: Int) -> CGSize {
        switch layoutDirection {
        case .horizontal: return indicatorLayout.horizontalSize(forNumberOfPages: pageCount)
        case .vertical: return indicatorLayout.verticalSize(forNumberOfPages: pageCount)
        }
    }
    
    open override var frame: CGRect {
        didSet {
            indicatorLayout.bounds = CGRect(origin: CGPoint.zero, size: frame.size)
            updateIndicatorFrame()
            layoutIfNeeded()
        }
    }
    
    open func frame(at index: Int) -> CGRect {
        switch layoutDirection {
        case .horizontal: return indicatorLayout.horizontalFrame(at: index)
        case .vertical: return indicatorLayout.verticalFrame(at: index)
        }
    }
    
    open func startResponseDragging() {
        guard items.isEmpty == false, currentPage >= 0, currentPage < items.count else {
            return
        }
        items.forEach {
            $0.resignFocus()
            $0.isFocusable = false
        }
    }
    
    open func endResponseDragging() {
        guard items.isEmpty == false, currentPage >= 0, currentPage < items.count else {
            return
        }
        items.forEach {
            $0.isFocusable = true
        }
    }
    
    open func checkHidesForSinglePage() {
        if numberOfPages == 1 && hidesForSinglePage {
            isHidden = true
        } else {
            isHidden = false
        }
    }
    
    deinit {
        print("BannerPageControl<\(T.self)>.deinit")
    }
    
    /// Overriding to initialize indicatorLayout
    override init(frame: CGRect) {
        indicatorLayout = BannerControlItemLayout.default
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Overriding to complete your own cleanup or call super.willMove(_:)
    override open func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            cleanupIndicator()
        }
    }
    
    
    /// Touch event
    ///
    /// if touch is on the indicator, jump to this indicator,
    /// otherwise jump to the pre or suc indicaor, 
    /// but if touch right of indicator item or left of first, jump to curr.
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        defer {
            super.touchesEnded(touches, with: event)
        }
        guard let touch = touches.first else {
            return
        }
        
        if let touchView = touch.view as? T,
            let index = items.index(of: touchView) {
            jumpToIndex = index
            sendActions(for: .valueChanged)
            return
        }
        
        let curr = currentPage
        guard curr >= 0, curr < items.count else {
            return
        }
        var currX = items[curr].frame.origin.x
        var toucX = touch.location(in: self).x
        if layoutDirection == .vertical {
            currX = items[curr].frame.origin.y
            toucX = touch.location(in: self).y
        }
        
        if (curr == items.count - 1 && toucX > currX) || (curr == 0 && toucX < currX) {
            jumpToIndex = curr
        } else {
            jumpToIndex = toucX > currX ? curr + 1 : curr - 1
        }
        
        sendActions(for: .valueChanged)
    }
    
    /// Create a T instance and add it to super view (self).
    /// For subclasses, when overriding this method, you can call super.createIndicator(), and then adjust the appearance.
    /// - return A indicator instance with black background color and white hightlight color.
    open func createIndicator() -> T {
        let centerFrame = CGRect(x: (bounds.width - indicatorSize.width) * 0.5,
                                 y: (bounds.height - indicatorSize.height) * 0.5,
                                 width: indicatorSize.width,
                                 height: indicatorSize.height)
        let p = T(frame: centerFrame)
        
        p.normalTintColor = UIColor.black
        p.highlightTintColor = UIColor.white
        
        addSubview(p)
        return p
    }
    
    /// Release all indicators and reset items
    /// When overriding, you can call super.cleanupIndicator() after clean up new resource in subclass
    open func cleanupIndicator() {
        guard items.isEmpty == false, numberOfPages > 0 else {
            return
        }
        items.forEach { $0.removeFromSuperview() }
        items.removeAll()
        items = []
    }
    
    /// First, center all indicators, and then scatter each indicator to a new position.
    /// The new position is calculated by func frame(_:).
    open func updateIndicatorFrame() {
        guard items.isEmpty == false else {
            return
        }
        let centerFrame = CGRect(x: (bounds.width - indicatorSize.width) * 0.5,
                                 y: (bounds.height - indicatorSize.height) * 0.5,
                                 width: indicatorSize.width,
                                 height: indicatorSize.height)
        items.forEach { $0.frame = centerFrame }
        for i in 0 ..< items.count {
            UIView.animate(withDuration: 0.5, animations: {
                self.items[i].frame = self.frame(at: i)
            })
        }
    }
}
