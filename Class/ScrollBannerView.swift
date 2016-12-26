//
//  ScrollBannerView.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/26.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import UIKit

class ScrollBannerCell: UICollectionViewCell {
    
    struct ReuseID {
        static let id: String = "ScrollBannerCell_ReuseID"
    }
    
    weak var imageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        createViews()
    }
    func createViews() {
        let imgView = UIImageView()
        imgView.backgroundColor = UIColor.clear
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFill
        self.contentView.addSubview(imgView)
        
        imageView = imgView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView?.frame = bounds
        
        print("ScrollBannerCell layoutSubviews: ", imageView?.frame ?? "---")
    }
}


class ScrollBannerView: UIView {

    var collectionView: UICollectionView!
    var flowLayout: UICollectionViewFlowLayout!
    
    var scrollDirection: UICollectionViewScrollDirection = .horizontal
    
    var timer: Timer!
    
    var items: [String] = []
    var itemCount: Int = 0
    
    deinit {
        print("deinit")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        customBanner(withLayout: nil, andCellClass: nil, withReuseIdentifier: nil, needReloadData: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        customBanner(withLayout: nil, andCellClass: nil, withReuseIdentifier: nil, needReloadData: false)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        flowLayout.itemSize = frame.size
        print("layoutSubviews: ", flowLayout.itemSize)
        update(to: itemCount / 2, false)
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview == nil else {
            return
        }
        print("removed from superview")
        invalidTimer()
        collectionView.dataSource = nil
        collectionView.delegate = nil
        collectionView = nil
        flowLayout = nil
    }
    
    /// adjust collection view layout; cell is not support now
    func customBanner(withLayout layout: UICollectionViewLayout?,
                      andCellClass anyClass: AnyClass?, withReuseIdentifier id: String?,
                      needReloadData reload:Bool = true) {
        if let cv = collectionView {
            cv.dataSource = nil
            cv.delegate = nil
            cv.removeFromSuperview()
            collectionView = nil
        }
        if let _ = flowLayout {
            flowLayout = nil
        }
        
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = frame.size
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.scrollDirection = .horizontal
        
        collectionView = setupCollectionView(withLayout: layout ?? flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(anyClass ?? ScrollBannerCell.self, forCellWithReuseIdentifier: id ?? ScrollBannerCell.ReuseID.id)
        self.addSubview(collectionView)
        
        if reload {
            collectionView.reloadData()
        }
    }
    
    /// create a new UICollectionView instance
    private func setupCollectionView(withLayout layout: UICollectionViewLayout) -> UICollectionView {
        let cv: UICollectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.clear
        cv.isPagingEnabled = true
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.scrollsToTop = false
        return cv
    }
    
    
    /// timer
    ///
    /// recreate a new timer instance
    func fireTimer() {
        invalidTimer()
        
        timer = Timer.scheduledTimer(timeInterval: 3.0,
                                     target: self,
                                     selector: #selector(ScrollBannerView.timerAction),
                                     userInfo: nil,
                                     repeats: true)
    }
    /// destroy this timer
    func invalidTimer() {
        if let t = timer, t.isValid {
            timer.invalidate()
            timer = nil
        }
    }
    /// call back method
    func timerAction() {
        guard itemCount > 1 else {
            return
        }
        update(to: currentIndex() + 1)
    }
    
    
    /// scroll
    ///
    func update(items newItems: [String]) {
        invalidTimer()
        
        items = newItems
        if items.count < 2 {
            collectionView.isScrollEnabled = false
        } else {
            itemCount = items.count * 100
            collectionView.isScrollEnabled = true
            fireTimer()
        }
        
        collectionView.reloadData()
    }
    
    func update(to targetIndex: Int, _ animated: Bool = true) {
        var targetIndex = targetIndex
        var animated = animated
        let pos: UICollectionViewScrollPosition = scrollDirection == .horizontal ?
            .centeredHorizontally :
            .centeredVertically
        
        if targetIndex >= itemCount {
            targetIndex = itemCount / 2
            animated = false
        }
        
        collectionView.scrollToItem(at: IndexPath(item: targetIndex, section: 0), at: pos, animated: animated)
    }
    
    func currentIndex() -> Int {
        var index: CGFloat = 0.0
        guard collectionView.bounds.width > 0.0 && collectionView.bounds.height > 0.0 else {
            return Int(index)
        }
        switch scrollDirection {
        case .horizontal:
            index = (collectionView.contentOffset.x + flowLayout.itemSize.width * 0.5) / flowLayout.itemSize.width
        case .vertical:
            index = (collectionView.contentOffset.y + flowLayout.itemSize.height * 0.5) / flowLayout.itemSize.height
        }
        return max(0, Int(index))
    }
    
    func itemIndex(with cellIndex: IndexPath) -> Int {
        return cellIndex.item % items.count
    }
    
    /// resource
    ///
    func localImage(named name: String) -> UIImage? {
        var path = Bundle.main.path(forResource: name, ofType: "png")
        if path == nil {
            path = Bundle.main.path(forResource: name, ofType: "jpg")
        }
        if let p = path {
            return UIImage(contentsOfFile: p)
        } else {
            return UIImage(contentsOfFile: Bundle.main.path(forResource: "placeholder", ofType: "jpg")!)
        }
    }
}


extension ScrollBannerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScrollBannerCell.ReuseID.id, for: indexPath)
        let name = items[itemIndex(with: indexPath)]
        
        if cell is ScrollBannerCell {
            if name.hasPrefix("http") || name.hasPrefix("www") {
                
            } else {
                (cell as! ScrollBannerCell).imageView?.image = localImage(named: name)
            }
        }
        
        return cell
    }
    
}


extension ScrollBannerView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard itemCount > 1 && scrollView.isScrollEnabled else {
            return
        }
        invalidTimer()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        fireTimer()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
    }
    
}
