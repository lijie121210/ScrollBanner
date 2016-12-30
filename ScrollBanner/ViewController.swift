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
    var testV: ScrollBannerView!
    var p: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path1 = Bundle.main.path(forResource: "img1", ofType: "jpg")!
        let path2 = Bundle.main.path(forResource: "img2", ofType: "jpg")!
        let path3 = Bundle.main.path(forResource: "img3", ofType: "jpg")!
        
        let img1 = UIImage(contentsOfFile: path1)!
        let img2 = UIImage(contentsOfFile: path2)!
        let img3 = UIImage(contentsOfFile: path3)!
        
        test = ScrollBannerView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 300.0))
        view.addSubview(test)
        
        test.update(items: [
            CellConfigurator<BannerImageCell>(viewData: BannerImageCellData(image: img1)),
            CellConfigurator<BannerImageCell>(viewData: BannerImageCellData(image: img2)),
            CellConfigurator<BannerImageCell>(viewData: BannerImageCellData(image: img3))
            ])
        
        
        testV = ScrollBannerView(frame: CGRect(x: 0, y: 320.0, width: view.bounds.width, height: 300.0))
        testV.layout.scrollDirection = .vertical
//        view.addSubview(testV)
        
        testV.update(items: [
            CellConfigurator<BannerImageCell>(viewData: BannerImageCellData(image: img1)),
            CellConfigurator<BannerImageCell>(viewData: BannerImageCellData(image: img2)),
            CellConfigurator<BannerImageCell>(viewData: BannerImageCellData(image: img3))
            ])
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    @IBAction func changeDirectionToH(_ sender: Any) {
//        let flow = UICollectionViewFlowLayout()
//        flow.itemSize = CGSize(width: view.bounds.width, height: 300.0)
//        flow.minimumLineSpacing = 0.0
//        flow.scrollDirection = .horizontal
//        testV.update(bannerLayout: flow)
        
//        testV.pageControl.frame = CGRect(x: 0, y: 0, width: 24, height: 300)
        
//        testV.pageControlAsidePosition = .top(tOffset: 8.0)
//        testV.pageControlAsidePosition = .right(rOffset: 8.0)
        testV.pageControlAsidePosition = .left(lOffset: 8.0)
        
    }
    @IBAction func destroyBanner(_ sender: Any) {
        // do not click twice, just simple test
        
        print("removed")
        test.removeFromSuperview()
        print("set nil")
        test = nil
        
        testV.removeFromSuperview()
        testV = nil
    }

}

