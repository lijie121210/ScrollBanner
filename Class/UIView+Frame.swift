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
    
    public var isHorizontal: Bool {
        return bounds.width >= bounds.height
    }
    
}

extension CALayer {
    
    public var isHorizontal: Bool {
        return bounds.width >= bounds.height
    }
    
}



