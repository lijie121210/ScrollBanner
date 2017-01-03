//
//  CirclePageControl.swift
//  ScrollBanner
//
//  Created by jie on 2017/1/2.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit


extension BannerPageControl {
    
}

public class CirclePageControl <T: UIView> : BannerPageControl<T>  where T: BannerPageItem  {
    
    deinit {
        print("CirclePageControl<\(T.self)>.deinit")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        indicatorLayout = BannerControlItemLayout(bounds: CGRect(origin: CGPoint.zero, size: frame.size),
                                                  indicatorCount: 0,
                                                  lineSpace: 20.0,
                                                  indicatorWidth: 10.0,
                                                  indicatorHeight: 10.0,
                                                  indicatorContentWidthLimit: 10.0,
                                                  indicatorContentHeightLimit: 10.0,
                                                  isAdapt: false)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func createIndicator() -> T {
        let p = super.createIndicator()
        
        p.normalTintColor = UIColor(white: 0.9, alpha: 0.9)
        p.highlightTintColor = UIColor.white
        
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
