//
//  BannerControlItem.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/31.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit



enum BannerIndicatorAsidePosition: Equatable {
    
    case top(offset: CGFloat)
    
    case bottom(offset: CGFloat)
    
    case left(offset: CGFloat)
    
    case right(offset: CGFloat)
    
    static func ==(lhs: BannerIndicatorAsidePosition, rhs: BannerIndicatorAsidePosition) -> Bool {
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


extension BannerIndicatorAsidePosition {
    
    func asideFrame(baseSize size: CGSize) -> CGRect {
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



/// Something like UIPageControl should perform those protocals

protocol Selectable: class {
    var selectedAction: ((_ on: Self, _ atIndex: Int) -> ())? {get set}
}

protocol BannerControlItem : class, Selectable {
    var numberOfPages: Int {get set}
    
    var currentPage: Int {get set}
    
    var hidesForSinglePage: Bool {get set}
    
    var pageIndicatorTintColor: UIColor? {get set}
    
    var currentPageIndicatorTintColor: UIColor? {get set}
    
    func size(forNumberOfPages pageCount: Int) -> CGSize
    
    func startResponseDragging()
    
    func endResponseDragging()
}


/// Something like dots of UIPageControl should perform those protocals; Indicators

protocol Colorable: class {
    
    var normalTintColor: UIColor? {get set}
    
    var highlightTintColor: UIColor? {get set}
}

protocol BannerPageItem: class, Colorable {
    
    var isFocusable: Bool {get set}
    
    func becomeFocus()
    
    func resignFocus()
}

public struct BannerAnimation {
    
    public struct Keys {
        public static let `default` = "BannerAnimation"
    }
    
    
}




