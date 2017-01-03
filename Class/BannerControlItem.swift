//
//  BannerControlItem.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/31.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit



/// Something like UIPageControl should perform those protocals


public protocol BannerControlItem : class {
    
    var jumpToIndex: Int {get set}
    
    var numberOfPages: Int {get set}
    
    var currentPage: Int {get set}
    
    var hidesForSinglePage: Bool {get set}
    
    var pageIndicatorTintColor: UIColor? {get set}
    
    var currentPageIndicatorTintColor: UIColor? {get set}
    
    func size(forNumberOfPages pageCount: Int) -> CGSize
    
    func startResponseDragging()
    
    func endResponseDragging()
}

public enum BannerControlAsidePosition: Equatable {
    
    case top(offset: CGFloat)
    
    case bottom(offset: CGFloat)
    
    case left(offset: CGFloat)
    
    case right(offset: CGFloat)
    
    public static func ==(lhs: BannerControlAsidePosition, rhs: BannerControlAsidePosition) -> Bool {
        switch (lhs, rhs) {
        case (.top(let a), .top(let b)) where a == b: return true
        case (.bottom(let a), .bottom(let b)) where a == b: return true
        case (.left(let a), .left(let b)) where a == b: return true
        case (.right(let a), .right(let b)) where a == b: return true
        default:
            return false
        }
    }
}


extension BannerControlAsidePosition {
    
    public func asideFrame(baseSize size: CGSize) -> CGRect {
        var result: CGRect = CGRect.zero
        let len: CGFloat = 20.0
        switch self {
        case .top(let tOffset): result = CGRect(x: 0.0, y: tOffset, width: size.width, height: len)
        case .bottom(let bOffset): result = CGRect(x: 0.0, y: size.height - len - bOffset, width: size.width, height: len)
        case .left(let lOffset): result = CGRect(x: lOffset, y: 0, width: len, height: size.height)
        case .right(let rOffset): result = CGRect(x: size.width - len - rOffset, y: 0, width: len, height: size.height)
        }
        return result
    }
    
}


public struct BannerControlItemLayout {
    
    public static let `default` = BannerControlItemLayout(bounds: CGRect.zero,
                                                   indicatorCount: 0,
                                                   lineSpace: 0,
                                                   indicatorWidth: 0, indicatorHeight: 0,
                                                   indicatorContentWidthLimit: 0, indicatorContentHeightLimit: 0,
                                                   isAdapt: false)
    public var bounds: CGRect
    public var indicatorCount: Int
    public var lineSpace: CGFloat
    public let indicatorWidth: CGFloat
    public let indicatorHeight: CGFloat
    public let indicatorContentWidthLimit: CGFloat
    public let indicatorContentHeightLimit: CGFloat
    
    /// If isAdapt is true, indicator size is calculated to fit the bounds, but will not over the limit
    /// If isAdapt is false, indicator size is CGSize(width: indicatorWidth, height: indicatorHeight)
    public var isAdapt: Bool
    
    ///
    /// Depending on the bounds, those two functions calculate the new adaptive size for each indicator, 
    /// considering the gap between each indicator and gap to border.
    ///
    /// In the horizontal direction, indicatorHeight is retained
    /// In the vertical direction, indicatorWidth is retained
    ///
    public func indicatorHorizontalSize() -> CGSize {
        if (indicatorCount == 0) {
            return CGSize.zero
        }
        if isAdapt == false {
            return CGSize(width: indicatorWidth, height: indicatorHeight)
        }
        let width = max( 0.0, ( bounds.width - lineSpace * CGFloat(indicatorCount + 1) ) ) / CGFloat(indicatorCount)
        return CGSize(width: min(width, indicatorContentWidthLimit), height: indicatorHeight)
    }
    public func indicatorVerticalSize() -> CGSize {
        if (indicatorCount == 0) {
            return CGSize.zero
        }
        if isAdapt == false {
            return CGSize(width: indicatorWidth, height: indicatorHeight)
        }
        let height = max( 0.0, ( bounds.height - lineSpace * CGFloat(indicatorCount + 1) ) ) / CGFloat(indicatorCount)
        
        return CGSize(width: indicatorWidth, height: min(height, indicatorContentHeightLimit))
    }
    
    
    /// Help calculate originX of first indicator
    
    public func indicatorHorizontalContentLength() -> CGFloat {
        if indicatorCount == 0 {
            return 0.0
        }
        let length = indicatorHorizontalSize().width
        
        return CGFloat(indicatorCount) * ( length + lineSpace) - lineSpace
    }
    public func indicatorVerticalContentLength() -> CGFloat {
        if indicatorCount == 0 {
            return 0.0
        }
        let length = indicatorVerticalSize().height
        
        return CGFloat(indicatorCount) * ( length + lineSpace) - lineSpace
    }
    
    /// For clarity, if isAdapt is false, the size of each indicator is already determined, 
    /// otherwise, the size of indicator should be calculated first
    ///
    /// - return content length
    public func horizontalSize(forNumberOfPages pageCount: Int) -> CGSize {
        var length = indicatorWidth
        if isAdapt {
            let width = max( 0.0, ( bounds.width - lineSpace * CGFloat(pageCount + 1) ) ) / CGFloat(pageCount)
            length = min(width, indicatorContentWidthLimit)
        }
        return CGSize(width: (CGFloat(pageCount) * (length + lineSpace) - lineSpace), height: indicatorHeight)
    }
    public func verticalSize(forNumberOfPages pageCount: Int) -> CGSize {
        var length = indicatorHeight
        if isAdapt {
            let width = max( 0.0, ( bounds.height - lineSpace * CGFloat(pageCount + 1) ) ) / CGFloat(pageCount)
            length = min(width, indicatorContentHeightLimit)
        }
        return CGSize(width: indicatorWidth, height: (CGFloat(pageCount) * (length + lineSpace) - lineSpace))
    }
    
    ///
    
    public func horizontalFrame(at index: Int) -> CGRect {
        let size = indicatorHorizontalSize()
        let x = (bounds.width - indicatorHorizontalContentLength()) * 0.5 + (lineSpace + size.width) * CGFloat(index)
        let y = (bounds.height - size.height) * 0.5
        
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
    public func verticalFrame(at index: Int) -> CGRect {
        let size = indicatorVerticalSize()
        let x = (bounds.width - size.width) * 0.5
        let y = (bounds.height - indicatorVerticalContentLength()) * 0.5 + (lineSpace + size.height) * CGFloat(index)
        
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}



/// Something like dots of UIPageControl should perform those protocals; Indicators

public protocol Colorable: class {
    
    var normalTintColor: UIColor? {get set}
    
    var highlightTintColor: UIColor? {get set}
}

public protocol BannerPageItem: class, Colorable {
    
    var isFocusable: Bool {get set}
    
    func becomeFocus()
    
    func resignFocus()
}

public struct BannerAnimation {
    
    public struct Keys {
        public static let `default` = "BannerAnimation"
    }
    
    
}




