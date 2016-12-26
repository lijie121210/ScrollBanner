//
//  ViewController.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/26.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var test: ScrollBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        test = ScrollBannerView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 300.0))
        view.addSubview(test)
        
        test.update(items: ["img1","img2","img3"])
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func destroyBanner(_ sender: Any) {
        
        print("removed")
        test.removeFromSuperview()
        print("set nil")
        test = nil
    }

}

