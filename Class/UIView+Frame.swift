//
//  UIView+Frame.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/29.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    var isHorizontal: Bool {
        return bounds.width >= bounds.height
    }
    
}

extension CALayer {
    
    var isHorizontal: Bool {
        return bounds.width >= bounds.height
    }
    
}


extension UIPageControl: BannerControlItem {
    
    struct AssociatedKeys {
        static var selectedIndexKey = "selectedIndexKey"
    }
    
    internal var selectedIndex: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.selectedIndexKey) as! Int
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.selectedIndexKey, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }

    
    internal func endResponseDragging() {
        
    }

    internal func startResponseDragging() {
        
    }

    

    
}
