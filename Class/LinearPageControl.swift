//
//  BannerPageControl.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/29.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit


public class LinearPageControl <T: UIView> : BannerPageControl<T>  where T: BannerPageItem {
    
    deinit {
        print("LinearPageControl<\(T.self)>.deinit")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        indicatorLayout = BannerControlItemLayout(bounds: CGRect(origin: CGPoint.zero, size: frame.size),
                                                  indicatorCount: 0,
                                                  lineSpace: 20.0,
                                                  indicatorWidth: 2.0,
                                                  indicatorHeight: 2.0,
                                                  indicatorContentWidthLimit: 60.0,
                                                  indicatorContentHeightLimit: 60.0,
                                                  isAdapt: true)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func createIndicator() -> T {
        let p = super.createIndicator()
        
        p.normalTintColor = UIColor(white: 0.9, alpha: 0.9)
        p.highlightTintColor = UIColor.gray
        
        p.layer.shadowColor = UIColor.black.cgColor
        p.layer.shadowOpacity = 0.2
        if layoutDirection == .horizontal {
            p.layer.shadowOffset = CGSize(width: 0, height: indicatorSize.height * 2)
            p.layer.shadowRadius = indicatorSize.height * 3
            p.layer.cornerRadius = indicatorSize.height * 0.5
        } else {
            p.layer.shadowOffset = CGSize(width: indicatorSize.width * 2, height: 0)
            p.layer.shadowRadius = indicatorSize.width * 3
            p.layer.cornerRadius = indicatorSize.width * 0.5
        }
        return p
    }
}




