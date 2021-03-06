//
//  BannerLayout.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/29.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit


public typealias BannerScrollDirection = UICollectionViewScrollDirection

/// Protocal
///
/// Basic requirement for layout using in Banner View
///
public protocol BannerLayout: class {
    var itemSize: CGSize {get set}
    var scrollDirection: BannerScrollDirection {get set}
    var minimumLineSpacing: CGFloat {get set}
    var minimumInteritemSpacing: CGFloat {get set}
}


extension UICollectionViewFlowLayout: BannerLayout {
    
}
