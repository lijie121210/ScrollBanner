//
//  BannerPageControl.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/29.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit


protocol PageControl {
    var numberOfPages: Int {get set}
    
    var currentPage: Int {get set}
    
    var hidesForSinglePage: Bool {get set}
    
    var pageIndicatorTintColor: UIColor? {get set}
    
    var currentPageIndicatorTintColor: UIColor? {get set}
    
    func size(forNumberOfPages pageCount: Int) -> CGSize
}

protocol Animateable {
    
}

protocol AppearanceAdjustable {
    
}

protocol Movable {
    
}


