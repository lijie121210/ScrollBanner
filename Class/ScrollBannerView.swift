//
//  ScrollBannerView.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/26.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import UIKit


/// Banner
///
class ScrollBannerView: UIView {
    
    var timer: Timer!
    var collectionView: UICollectionView!
    var pageControl: ProgressPageControl!
    
    var layout: BannerLayout! {
        didSet {
            updateLayout()
        }
    }
    var items: [CellConfigurable] = [] {
        didSet {
            scroll()
        }
    }
    
    var itemCount: Int = 0
    let contentExpendFactor: Int = 50
    
    deinit {
        print("ScrollBannerView.deinit", collectionView == nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialization()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialization()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        layout.itemSize = frame.size
        update(to: itemCount / 2, false)
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview == nil else {
            return
        }
        print("removed from superview")
        invalidTimer()
        cleanupCollectionView()
        cleanupLayout()
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
    
    /// Collection View
    ///
    /// This function will only be called when initializing this class.
    /// So, it will initialize self.layout, self.collectionView and add self.collectionView to subviews;
    /// No cell class will register on collection view, because itemCount == 0; 
    ///
    private func initialization() {
        let flow = UICollectionViewFlowLayout()
        flow.itemSize = frame.size
        flow.minimumLineSpacing = 0.0
        flow.scrollDirection = .horizontal
        
        layout = flow
        collectionView = setupCollectionView(withLayout: flow)
        
        pageControl = ProgressPageControl(frame: CGRect(x: 0.0, y: bounds.height - 24.0 - 8.0, width: bounds.width, height: 24.0))
        pageControl.backgroundColor = UIColor.clear
        addSubview(pageControl)
        
        pageControl.selectedAction = { [weak self] (_ control: ProgressPageControl, _ atIndex: Int) -> () in
            /// cancel current animation
            control.cancelAnimation()
            guard let sself = self else {
                return
            }
            sself.invalidTimer()
            
            let curr = sself.currentIndex()
            let itemIndex = sself.itemIndex(with: curr)
            var target = 0
            if itemIndex > atIndex  {
                target = curr - (itemIndex - atIndex)
            } else {
                target = curr + (atIndex - itemIndex)
            }
            
            sself.update(to: target, false)
            
            sself.fireTimer()
        }
    }
    /// create a new UICollectionView instance, and add it to super view(self)
    private func setupCollectionView<T: UICollectionViewLayout>(withLayout layout: T) -> UICollectionView where T: BannerLayout {
        let cv: UICollectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.clear
        cv.isPagingEnabled = true
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false
        cv.scrollsToTop = false
        cv.dataSource = self
        cv.delegate = self
        addSubview(cv)
        return cv
    }
    /// clean up refercence
    private func cleanupCollectionView() {
        if let cv = collectionView {
            cv.dataSource = nil
            cv.delegate = nil
            cv.removeFromSuperview()
        }
        collectionView = nil
    }
    private func cleanupPageControl() {
        if let _ = pageControl {
            pageControl.selectedAction = nil
            pageControl.removeFromSuperview()
            pageControl = nil
        }
    }
    private func cleanupLayout() {
        layout = nil
    }
    /// Register cell class
    ///
    /// Make collectionView register cell classes from items
    ///
    private func registerCells() {
        guard let c = collectionView else {
            return
        }
        items.forEach { (configurator) in
            c.register(configurator.cellClass, forCellWithReuseIdentifier: configurator.reuseIdentifier)
        }
    }
    /// Update to new layout
    ///
    /// This function will recreate a collectionView instance with new layout type
    ///
    private func updateLayout() {
        guard let c = collectionView, layout is UICollectionViewLayout else {
            return
        }
        invalidTimer()
        c.collectionViewLayout = (layout as! UICollectionViewLayout)
        c.reloadData()
        fireTimer()
    }
    
    /// scroll
    ///
    /// Begin scroll depends on items: show its images or texts
    ///
    func scroll() {
        guard let c = collectionView, let p = pageControl, items.count > 0 else {
            print("scroll: invalid parameter")
            return
        }
        invalidTimer()
        
        p.numberOfpages = items.count
        
        if items.count == 1 {
            c.isScrollEnabled = false
            registerCells()
            c.reloadData()
            p.hideForSingle = true
        } else {
            itemCount = items.count * contentExpendFactor
            
            c.isScrollEnabled = true
            registerCells()
            c.reloadData()
            
            p.hideForSingle = false
            
            fireTimer()
        }
    }
    /// Reset layout and reload data
    func update<T: UICollectionViewLayout>(bannerLayout newLayout: T) where T: BannerLayout {
        layout = newLayout
    }
    /// Reset items and begin scroll
    func update(items newItems: [CellConfigurable]) {
        items = newItems
    }
    /// scroll collectionView to target index
    func update(to targetIndex: Int, _ animated: Bool = true) {
        guard collectionView != nil else {
            return
        }
        var targetIndex = targetIndex
        var animated = animated
        let pos: UICollectionViewScrollPosition = layout.scrollDirection == .horizontal ?
            .centeredHorizontally :
            .centeredVertically
        if targetIndex >= itemCount {
            targetIndex = itemCount / 2
            animated = false
        }
        
        collectionView.scrollToItem(at: IndexPath(item: targetIndex, section: 0), at: pos, animated: animated)
    }
    
    /// calculate index for cell
    func currentIndex() -> Int {
        guard collectionView != nil else {
            return 0
        }
        var index: CGFloat = 0.0
        guard collectionView.bounds.width > 0.0 && collectionView.bounds.height > 0.0 else {
            return Int(index)
        }
        index = layout.scrollDirection == .horizontal ?
            ((collectionView.contentOffset.x + layout.itemSize.width * 0.5) / layout.itemSize.width) :
            ((collectionView.contentOffset.y + layout.itemSize.height * 0.5) / layout.itemSize.height)
        return max(0, Int(index))
    }
    
    /// calculate index for data
    func itemIndex(with cellIndex: Int) -> Int {
        return cellIndex % items.count
    }
}


/// UICollectionViewDataSource
///
/// Layout cells with data source
///
extension ScrollBannerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let configurator = items[itemIndex(with: indexPath.item)]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: configurator.reuseIdentifier, for: indexPath)
        
        configurator.update(cell: cell)
        
        return cell
    }
}

/// UICollectionViewDelegate
///
/// Handle select action;
/// Handle scroll drag action;
///
extension ScrollBannerView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard items.isEmpty == false else {
            return
        }
        pageControl.currentPage = itemIndex(with: currentIndex() )
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
