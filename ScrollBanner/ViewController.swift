//
//  ViewController.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/26.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

//    var test: ScrollBannerView!
//    var testV: ScrollBanner!
    
    var banner: BannerView<BannerPageControl<LinearProgressView > >!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path1 = Bundle.main.path(forResource: "img1", ofType: "jpg")!
        let path2 = Bundle.main.path(forResource: "img2", ofType: "jpg")!
        let path3 = Bundle.main.path(forResource: "img3", ofType: "jpg")!
        
        let img1 = UIImage(contentsOfFile: path1)!
        let img2 = UIImage(contentsOfFile: path2)!
        let img3 = UIImage(contentsOfFile: path3)!
        
        let button1 = UIButton(frame: CGRect(x: 0, y: 320, width: view.bounds.width, height: 34))
        button1.setTitle("destroy", for: .normal)
        button1.setTitleColor(UIColor.black, for: .normal)
        button1.addTarget(self, action: #selector(ViewController.destroyBanner), for: .touchUpInside)
        view.addSubview(button1)
        
        let button2 = UIButton(frame: CGRect(x: 0, y: 360, width: view.bounds.width, height: 34))
        button2.setTitle("changeDirection", for: .normal)
        button2.setTitleColor(UIColor.black, for: .normal)
        button2.addTarget(self, action: #selector(ViewController.changeDirection), for: .touchUpInside)
        view.addSubview(button2)
        
        let button3 = UIButton(frame: CGRect(x: 0, y: 400, width: view.bounds.width, height: 34))
        button3.setTitle("changeIndicatorPosition", for: .normal)
        button3.setTitleColor(UIColor.black, for: .normal)
        button3.addTarget(self, action: #selector(ViewController.changeIndicatorPosition), for: .touchUpInside)
        view.addSubview(button3)
        
        banner = BannerView< BannerPageControl< LinearProgressView > >(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 300))
        
//        banner.scrollDirection = .vertical

//        view.addSubview(banner)
        
//        banner.scrollDirection = .vertical
        
        banner.scroll(items: [
            CellConfigurator<BannerImageCell>(viewData: BannerImageCellData(image: img1)),
            CellConfigurator<BannerImageCell>(viewData: BannerImageCellData(image: img2)),
            CellConfigurator<BannerImageCell>(viewData: BannerImageCellData(image: img3))
            ])
        
//        banner.scrollDirection = .vertical

        view.addSubview(banner)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeIndicatorPosition() {
        guard let b = banner else {
            return
        }
        switch b.pageControlAsidePosition {
        case .bottom(offset: 8.0): b.pageControlAsidePosition = .top(offset: 8.0)
        case .top(offset: 8.0): b.pageControlAsidePosition = .left(offset: 8.0)
        case .left(offset: 8.0): b.pageControlAsidePosition = .right(offset: 8.0)
        case .right(offset: 8.0): b.pageControlAsidePosition = .bottom(offset: 8.0)
        default: break
        }
    }

    func changeDirection() {
        guard let b = banner else {
            return
        }
        if b.scrollDirection == .horizontal {
            b.scrollDirection = .vertical
        } else {
            b.scrollDirection = .horizontal
        }
    }
    func destroyBanner() {
        guard let b = banner else {
            return
        }
        b.removeFromSuperview()
        banner = nil
    }

}

