//
//  CircleProgressView.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/31.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import UIKit

class CircleProgressView: UIView, BannerPageItem {

    var normalTintColor: UIColor? 
    
    var highlightTintColor: UIColor?
    
    var isFocusable: Bool = true
    
    func becomeFocus() {
        print("becomeFocus")
    }
    
    func resignFocus() {
        print("resignFocus")
    }
}
