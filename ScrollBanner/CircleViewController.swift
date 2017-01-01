//
//  CircleBannerViewController.swift
//  ScrollBanner
//
//  Created by jie on 2017/1/1.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

class CircleViewController: UIViewController {

    var banner: BannerView<LinearPageControl<CircleProgressView > >!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = UIColor.white
        
        let path1 = Bundle.main.path(forResource: "img1", ofType: "jpg")!
        let path2 = Bundle.main.path(forResource: "img2", ofType: "jpg")!
        let path3 = Bundle.main.path(forResource: "img3", ofType: "jpg")!
        
        let img1 = UIImage(contentsOfFile: path1)!
        let img2 = UIImage(contentsOfFile: path2)!
        let img3 = UIImage(contentsOfFile: path3)!
        
        let items = [CellConfigurator<BannerImageCell>(viewData: BannerImageCellData(image: img1)),
                     CellConfigurator<BannerImageCell>(viewData: BannerImageCellData(image: img2)),
                     CellConfigurator<BannerImageCell>(viewData: BannerImageCellData(image: img3))]
        banner = BannerView< LinearPageControl< CircleProgressView > >(frame: CGRect(x: 0, y: 64, width: view.bounds.width, height: 300))
        view.addSubview(banner)
        
        banner.selectedAction = { (banner, index) -> () in
            print("banner.selectedAction : ", index)
        }
        banner.scrolledAction = { (banner, index) -> () in
            
        }
        
        banner.scroll(items: items)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        destroyBanner()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func destroyBanner() {
        guard let b = banner else {
            return
        }
        b.removeFromSuperview()
        banner = nil
    }
}
