//
//  ScrollBanner.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/30.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import UIKit

class ScrollBanner: UIView {
    fileprivate var timer: Timer!
    
    var selectedAction: ( (_ banner: ScrollBanner, _ index: Int) -> () )?
    
    var scrolledAction: ( (_ banner: ScrollBanner, _ index: Int) -> () )?
    
    /// itemCount = items.count * contentExpendFactor
    
    fileprivate var itemCount: Int = 0
    
    fileprivate let contentExpendFactor: Int = 50
    
    var items: [CellConfigurable] = [] {
        didSet {
            guard let c = collectionView, let p = pageControl, items.count > 0 else {
                print("scroll: invalid parameter")
                return
            }
            invalidTimer()
            
            p.numberOfPages = items.count
            
            if items.count == 1 {
                c.isScrollEnabled = false
                registerCells()
                c.reloadData()
            } else {
                itemCount = items.count * contentExpendFactor
                
                c.isScrollEnabled = true
                registerCells()
                c.reloadData()
                
                validTimer()
            }
        }
    }
    
    var collectionView: UICollectionView!
    
    var layout: BannerLayout! {
        didSet {
            guard let c = collectionView, layout is UICollectionViewLayout else {
                return
            }
            invalidTimer()
            c.collectionViewLayout = (layout as! UICollectionViewLayout)
            c.reloadData()
            validTimer()
        }
    }
    
    var pageControl: BannerPageControl<LinearProgressView>!
    
    var pageControlAsidePosition: BannerIndicatorAsidePosition = .bottom(bOffset: 8.0) {
        didSet {
            guard let p = pageControl, pageControlAsidePosition != oldValue else {
                return
            }
            p.disableAnimation()
            
            p.frame = pageControlFrame
            
            p.enableAnimation()
        }
    }
    
    /// calculate page control's frame depends on pageControlAsidePosition
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
        layout.itemSize = frame.size
        scroll(to: itemCount / 2, isAnimated: false)
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        /// removed from superview
        guard newSuperview == nil else {
            return
        }
        invalidTimer()
        cleanupCollectionView()
        cleanupPageControl()
        cleanupLayout()
        selectedAction = nil
        scrolledAction = nil
    }
    
    
    /// timer
    
    /// recreate a new timer instance
    func validTimer() {
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
        scroll(to: cellIndex() + 1)
    }
    
    
    /// This function will only be called when initializing this class.
    /// So, it will initialize self.layout, self.collectionView and add self.collectionView to subviews;
    /// No cell class will register on collection view, because itemCount == 0;
    ///
    private func initialization() {
        
        let flow = setupDefaultLayout()
        layout = flow
        
        collectionView = setupCollectionView(withLayout: flow)
        
        pageControl = setupPageControl()
    }
    
    
    /// Set up views
    
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
    private func setupDefaultLayout() -> UICollectionViewFlowLayout {
        let flow = UICollectionViewFlowLayout()
        flow.itemSize = frame.size
        flow.minimumLineSpacing = 0.0
        flow.scrollDirection = .horizontal
        return flow
    }
    private func setupPageControl() -> BannerPageControl<LinearProgressView> {
        let frame = pageControlFrame
        let control = BannerPageControl<LinearProgressView>(frame: frame)
        addSubview(control)
        
        control.selectedAction = { [weak self] (_ control: BannerPageControl, _ atIndex: Int) -> () in
            guard let sself = self else {
                return
            }
            
            control.disableAnimation()
            
            sself.invalidTimer()
            
            defer {
                control.enableAnimation()
                
                sself.validTimer()
            }
            
            sself.scroll(to: sself.jumpIndex(to: atIndex), isAnimated: true)
        }
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
    private func registerCells() {
        guard let c = collectionView, items.isEmpty == false else {
            return
        }
        items.forEach { c.register($0.cellClass, forCellWithReuseIdentifier: $0.reuseIdentifier) }
    }
    
    
    /// Reset layout and reload data
    func update<T: UICollectionViewLayout>(bannerLayout newLayout: T) where T: BannerLayout {
        layout = newLayout
    }
    
    
    /// Reset items and begin scroll
    func update(items newItems: [CellConfigurable]) {
        items = newItems
    }
    
    /// It's strange that layout.scrollDirection will be a sudden error,
    /// although this will cause nothing (cellIndex % items.count not change)
    /// - return Cell Index between 0...itemCount-1
    func cellIndex() -> Int {
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
    
    /// - cellIndex Cell index between 0...itemCount-1
    /// - return Item index between 0..<items.count
    func itemIndex(with cellIndex: Int) -> Int {
        guard cellIndex >= 0, items.isEmpty == false else {
            return 0
        }
        return cellIndex % items.count
    }
    
    /// Invoke when user selected page control indicator
    /// - item Target item index in items, between 0..<items.count
    /// - return New cell index between 0...itemCount-1
    func jumpIndex(to item: Int) -> Int {
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
    func scroll(to targetIndex: Int, isAnimated animated: Bool = true) {
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
    
    
}


extension ScrollBanner: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
        guard items.isEmpty == false, isEndDragging else {
            return
        }
        
        /// See beginDraggingIndex defination
        if beginDraggingIndex >= 0, beginDraggingIndex < itemCount, beginDraggingIndex == cellIndex() {
            pageControl.currentPage = -1
            beginDraggingIndex = -1
        }
        
        pageControl.currentPage = itemIndex(with: cellIndex() )
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard itemCount > 1 && scrollView.isScrollEnabled else {
            return
        }
        
        /// See isEndDragging defination
        isEndDragging = false
        
        /// See beginDraggingIndex defination
        beginDraggingIndex = cellIndex()
        
        pageControl.disableAnimation()
        
        invalidTimer()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        /// See isEndDragging defination
        isEndDragging = true
        
        pageControl.enableAnimation()
        
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
