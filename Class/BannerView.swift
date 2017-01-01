//
//  ScrollBanner.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/31.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import UIKit

class BannerView <T: UIControl> : UIView, UICollectionViewDataSource, UICollectionViewDelegate where T: BannerPageControlItem {
    
    fileprivate var timer: Timer!
    
    fileprivate var pageControl: T!

    fileprivate var collectionView: UICollectionView!


    /// Touch event callback
    
    var selectedAction: ( (_ banner: BannerView<T>, _ index: Int) -> () )?
    
    var scrolledAction: ( (_ banner: BannerView<T>, _ index: Int) -> () )?
    
    
    /// itemCount = items.count * contentExpendFactor
    
    fileprivate var itemCount: Int = 0
    
    fileprivate let contentExpendFactor: Int = 50
    
    fileprivate var items: [CellConfigurable] = [] {
        didSet {
            invalidTimer()

            guard let c = collectionView, let p = pageControl, items.isEmpty == false else {
                print("scroll: invalid parameter")
                return
            }
            p.numberOfPages = items.count
            items.forEach {
                c.register($0.cellClass, forCellWithReuseIdentifier: $0.reuseIdentifier)
            }
            if items.count == 1 {
                c.isScrollEnabled = false
                c.reloadData()
            } else {
                itemCount = items.count * contentExpendFactor
                c.isScrollEnabled = true
                c.reloadData()
                scroll(to: itemCount / 2, isAnimated: false)
                validTimer()
            }
        }
    }
    
    var itemSize: CGSize {
        get {
            if let c = collectionView.collectionViewLayout as? BannerLayout {
                return c.itemSize
            } else {
                return CGSize.zero
            }
        }
        set {
            if let c = collectionView.collectionViewLayout as? BannerLayout {
                c.itemSize = newValue
            }
        }
    }
    
    /// Issues
    /// Setting c.scrollDirection will make collection view scroll to the first page
    var scrollDirection: BannerScrollDirection {
        get {
            if let c = collectionView.collectionViewLayout as? BannerLayout {
                return c.scrollDirection
            } else {
                return .horizontal
            }
        }
        set {
            if let c = collectionView.collectionViewLayout as? BannerLayout {
                c.scrollDirection = newValue
            }
        }
    }
    
    var pageControlAsidePosition: BannerIndicatorAsidePosition = .bottom(offset: 8.0) {
        didSet {
            guard let p = pageControl, pageControlAsidePosition != oldValue else {
                return
            }
            p.frame = pageControlFrame
        }
    }
    
    fileprivate var pageControlFrame: CGRect {
        return pageControlAsidePosition.asideFrame(baseSize: bounds.size)
    }
    
    /// Fixed
    ///
    /// Sometimes, scrollView.isDragging still be true even after endDraging method has been called.
    /// - isEndDragging = false   : scrollViewWillBeginDragging(_:) be called
    /// - isEndDragging = true    : scrollViewDidEndDragging(_:) be called
    fileprivate var isEndDragging: Bool = true
    
    /// Fixed
    ///
    /// When the user just drags a little, the cellIndex() returns the same value.
    /// This cause pageControl to ignore the setting, and the animation does not start again.
    /// Set (beginDraggingIndex = -1) will force animation replay.
    /// - beginDraggingIndex = cellIndex()   : scrollViewWillBeginDragging(_:) be called
    /// - beginDraggingIndex = -1               : scrollViewDidScroll(_:) be called
    fileprivate var beginDraggingIndex: Int = -1
    
    
    
    
    
    
    /// Life cycle
    
    deinit {
        print(collectionView == nil ? "collectionView.deinit" : "Error collectionView!")
        print(pageControl == nil ? "pageControl.deinit" : "Error pageControl!")
        print("ScrollBannerView.deinit")
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
        if let c = collectionView {
            c.frame = bounds
        }
//        scroll(to: itemCount / 2, isAnimated: false)
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        /// removed from superview
        
        guard newSuperview == nil else {
            return
        }
        invalidTimer()
        cleanupCollectionView()
        cleanupPageControl()
        selectedAction = nil
        scrolledAction = nil
    }
    
    func scroll(items newItems: [CellConfigurable]) {
        items = newItems
    }
    
    func update<U: UICollectionViewLayout>(bannerLayout newLayout: U) where U: BannerLayout {
        guard let c = collectionView else {
            return
        }
        invalidTimer()
        c.collectionViewLayout = newLayout
        c.reloadData()
        validTimer()
    }
    
    
    
    /// timer
    
    /// recreate a new timer instance
    func validTimer() {
        invalidTimer()
        timer = Timer.scheduledTimer(timeInterval: 3.0,
                                     target: self,
                                     selector: #selector(BannerView.timerAction),
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
        scroll(to: cellIndex() + 1)
    }
    
    
    

    /// Set up views
    
    
    /// This function will only be called when initializing this class.
    /// So, it will initialize self.layout, self.collectionView and add self.collectionView to subviews;
    /// No cell class will register on collection view, because itemCount == 0;
    ///
    private func initialization() {
        collectionView = setupCollectionView()
        pageControl = setupPageControl()
    }
    
    private func setupCollectionView() -> UICollectionView {
        let flow = UICollectionViewFlowLayout()
        flow.itemSize = frame.size
        flow.minimumLineSpacing = 0.0
        flow.scrollDirection = .horizontal
        
        let cv: UICollectionView = UICollectionView(frame: bounds, collectionViewLayout: flow)
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
    
    private func setupPageControl() -> T {
        let control = T(frame: pageControlFrame)
        control.selectedAction = { [weak self] (control, atIndex) -> () in
            guard let sself = self else {
                return
            }
            control.startResponseDragging()
            sself.invalidTimer()
            sself.scroll(to: sself.jumpIndex(to: atIndex), isAnimated: true)
            control.endResponseDragging()
            sself.validTimer()
        }
        
        addSubview(control)
        
        return control
    }
    
    /// Clean up refercence
    
    private func cleanupCollectionView() {
        if let cv = collectionView {
            cv.dataSource = nil
            cv.delegate = nil
            cv.removeFromSuperview()
        }
        collectionView = nil
    }
    private func cleanupPageControl() {
        if let p = pageControl {
            p.selectedAction = nil
            p.removeFromSuperview()
        }
        pageControl = nil
    }
    
    
    /// Index calculation
    
    /// It's strange that layout.scrollDirection will be a sudden error,
    /// although this will cause nothing (cellIndex % items.count not change)
    /// - return Cell Index between 0...itemCount-1
    fileprivate func cellIndex() -> Int {
        guard let c = collectionView, c.bounds.width > 0.0, c.bounds.height > 0.0 else {
            return 0
        }
        if scrollDirection == .horizontal {
            return max(0, Int( (collectionView.contentOffset.x + itemSize.width * 0.5) / itemSize.width) )
        } else {
            return max(0, Int( (collectionView.contentOffset.y + itemSize.height * 0.5) / itemSize.height) )
        }
    }
    
    /// - cellIndex Cell index between 0...itemCount-1
    /// - return Item index between 0..<items.count
    fileprivate func itemIndex(with cellIndex: Int) -> Int {
        guard cellIndex >= 0, items.isEmpty == false else {
            return 0
        }
        return cellIndex % items.count
    }
    
    /// Invoke when user selected page control indicator
    /// - item Target item index in items, between 0..<items.count
    /// - return New cell index between 0...itemCount-1
    fileprivate func jumpIndex(to item: Int) -> Int {
        let curr = cellIndex()
        let currItemIndex = itemIndex(with: curr)
        var target = 0
        if currItemIndex > item  {
            target = curr - (currItemIndex - item)
        } else {
            target = curr + (item - currItemIndex)
        }
        return target
    }
    
    /// scroll collectionView to target cell index
    /// - targetIndex Should between 0...itemCount-1
    fileprivate func scroll(to targetIndex: Int, isAnimated animated: Bool = true) {
        guard collectionView != nil else {
            return
        }
        var targetIndex = targetIndex
        var animated = animated
        let pos: UICollectionViewScrollPosition = scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically
        if targetIndex >= itemCount {
            targetIndex = itemCount / 2
            animated = false
        }
        collectionView.scrollToItem(at: IndexPath(item: targetIndex, section: 0), at: pos, animated: animated)
    }
    
    
    
    
    
    /// UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let configurator = items[itemIndex(with: indexPath.item)]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: configurator.reuseIdentifier, for: indexPath)
        configurator.update(cell: cell)
        return cell
    }
    
    /// UICollectionViewDelegate
    ///
    /// Handle select action;
    /// Handle scroll drag action;
    ///
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let action = selectedAction {
            action(self, itemIndex(with: indexPath.item))
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard items.isEmpty == false, isEndDragging, let p = pageControl else {
            return
        }
        
        /// See beginDraggingIndex defination
        if beginDraggingIndex >= 0, beginDraggingIndex < itemCount, beginDraggingIndex == cellIndex() {
            p.currentPage = -1
            beginDraggingIndex = -1
        }
        
        p.currentPage = itemIndex(with: cellIndex() )
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard itemCount > 1, scrollView.isScrollEnabled, let p = pageControl else {
            return
        }
        
        /// See isEndDragging defination
        isEndDragging = false
        
        /// See beginDraggingIndex defination
        beginDraggingIndex = cellIndex()
        p.startResponseDragging()
        invalidTimer()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let p = pageControl else {
            return
        }
        /// See isEndDragging defination
        isEndDragging = true
        p.endResponseDragging()
        validTimer()
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard items.isEmpty == false, let action = scrolledAction else {
            return
        }
        action(self, itemIndex(with: cellIndex()))
    }
    
}
