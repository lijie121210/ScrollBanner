//
//  ViewController.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/26.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var banner: BannerView<LinearPageControl<LinearProgressView > >!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        banner = BannerView< LinearPageControl< LinearProgressView > >(frame: CGRect(x: 0, y: 20, width: view.bounds.width, height: 280))
        banner.backgroundColor = UIColor.lightGray
        view.addSubview(banner)
        
        let items = [CellConfigurator<BannerTextCell>(viewData: BannerTextCellData(text: "Linear progress banner indicator")),
                     CellConfigurator<BannerTextCell>(viewData: BannerTextCellData(text: "Circle progress banner indicator")),
                     CellConfigurator<BannerTextCell>(viewData: BannerTextCellData(text: "Dots banner indicator"))]
        
        banner.selectedAction = { [weak self] (banner, index) -> () in
            var controller: UIViewController? = nil
            switch index {
            case 0: controller = LinearViewController()
            case 1: controller = CircleViewController()
            default: break
            }
            guard let c = controller else {
                return
            }
            self?.present(c, animated: true, completion: nil)
        }
        
        banner.scroll(items: items)
        
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
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
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

