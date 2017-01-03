//
//  ScrollBanner.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/31.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import UIKit


public struct Banner {
    
    public static var defaultFrame: CGRect {
        let width = UIScreen.main.bounds.width
        return CGRect(x: 0.0, y: 20.0, width: width, height: 300.0)
    }
    
    public struct `default` {
        
        public static var system: BannerView<UIPageControl> {
            return BannerView<UIPageControl>(frame: defaultFrame)
        }
        
        public static var linear: BannerView<LinearPageControl<LinearProgressView > > {
            return BannerView<LinearPageControl<LinearProgressView > >(frame: defaultFrame)
        }
        
        public static var circle: BannerView<CirclePageControl<CircleProgressView > > {
            return BannerView<CirclePageControl<CircleProgressView > >(frame: defaultFrame)
        }
    }
}

extension UIPageControl: BannerControlItem {
    
    open var jumpToIndex: Int {
        get {
            return currentPage
        }
        set {
            currentPage = newValue
        }
    }
    
    open func endResponseDragging() { }
    
    open func startResponseDragging() { }
    
}

open class BannerView <T: UIControl> : UIView, UICollectionViewDataSource, UICollectionViewDelegate where T: BannerControlItem {
    
    open var timer: Timer!
    open var pageControl: T!
    open var collectionView: UICollectionView!

    /// Touch event callback
    
    open var selectedAction: ( (_ banner: BannerView<T>, _ index: Int) -> () )?
    open var scrolledAction: ( (_ banner: BannerView<T>, _ index: Int) -> () )?
    
    
    /// itemCount = items.count * contentExpendFactor
    
    open var itemCount: Int = 0
    open let contentExpendFactor: Int = 50
    
    open var items: [CellConfigurable] = [] {
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
    
    open override var frame: CGRect {
        didSet {
            guard let c = collectionView, let p = pageControl else {
                return
            }
            c.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
//            (c.collectionViewLayout as! BannerLayout).itemSize = frame.size
            p.frame = pageControlFrame
            
        }
    }
    
    /// Issues
    ///
    /// Setting collectionView.collectionViewLayout.scrollDirection will make collection view scroll to the first page
    ///
    
    open var itemSize: CGSize {
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
    
    open var scrollDirection: BannerScrollDirection {
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
    
    open var pageControlAsidePosition: BannerControlAsidePosition = .bottom(offset: 8.0) {
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
    
    /// Fixed
    ///
    /// If the creation work is done in viewDidLoad(), then the view controller is rendered, the first animation is not displayed.
    /// So, call this method in viewWillAppear(_:) or viewDidAppear(_:) to force the first animation to be displayed.
    func forceAnimationAfterPresenting() {
        let index = itemIndex(with: cellIndex())
        if index >= 0, index < items.count, let p = pageControl {
            if p.currentPage == index {
                p.currentPage = -1
            }
            p.currentPage = index
        }
    }
    
    
    
    /// Life cycle
    
    deinit {
        print(collectionView == nil ? "collectionView.deinit" : "Error collectionView!")
        print(pageControl == nil ? "pageControl.deinit" : "Error pageControl!")
        print("BannerView.deinit")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialization()
    }
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        initialization()
    }
    override open func layoutSubviews() {
        super.layoutSubviews()
//        if let c = collectionView {
//            c.frame = bounds
//        }
        guard let c = collectionView, let p = pageControl else {
            return
        }
        c.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        (c.collectionViewLayout as! BannerLayout).itemSize = frame.size
        p.frame = pageControlFrame
    }
    override open func willMove(toSuperview newSuperview: UIView?) {
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
    
    open func scroll(items newItems: [CellConfigurable]) {
        items = newItems
    }
    
    open func update<U: UICollectionViewLayout>(bannerLayout newLayout: U) where U: BannerLayout {
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
    open func validTimer() {
        invalidTimer()
        timer = Timer.scheduledTimer(timeInterval: 3.0,
                                     target: self,
                                     selector: #selector(BannerView.timerAction),
                                     userInfo: nil,
                                     repeats: true)
    }
    /// destroy this timer
    open func invalidTimer() {
        if let t = timer, t.isValid {
            timer.invalidate()
            timer = nil
        }
    }
    /// call back method
    open func timerAction() {
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
    
    open func setupPageControl() -> T {
        let control = T(frame: pageControlFrame)
        control.addTarget(self, action: #selector(BannerView.didReceiveEvent(_:)), for: UIControlEvents.valueChanged)
        addSubview(control)
        return control
    }
    
    open func didReceiveEvent(_ sender: Any?) {
        guard let sender = sender as? T else {
            return
        }
        invalidTimer()
        sender.startResponseDragging()
        let jumpResult = jumpIndex(to: sender.jumpToIndex)
        sender.endResponseDragging()
        if jumpResult.isJumpped {
            scroll(to: jumpResult.index, isAnimated: true)
        } else {
            sender.currentPage = -1
            sender.currentPage = itemIndex(with: jumpResult.index)
        }
        validTimer()
    }
    
    /// Clean up refercence
    
    open func cleanupCollectionView() {
        if let cv = collectionView {
            cv.dataSource = nil
            cv.delegate = nil
            cv.removeFromSuperview()
        }
        collectionView = nil
    }
    private func cleanupPageControl() {
        if let p = pageControl {
            p.removeTarget(self, action: nil, for: .valueChanged)
            p.removeFromSuperview()
        }
        pageControl = nil
    }
    
    
    /// Index calculation
    
    /// It's strange that layout.scrollDirection will be a sudden error,
    /// although this will cause nothing (cellIndex % items.count not change)
    /// - return Cell Index between 0...itemCount-1
    open func cellIndex() -> Int {
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
    open func itemIndex(with cellIndex: Int) -> Int {
        guard cellIndex >= 0, items.isEmpty == false else {
            return 0
        }
        return cellIndex % items.count
    }
    
    /// Invoke when user selected page control indicator
    /// - item Target item index in items, between 0..<items.count
    /// - return New cell index between 0...itemCount-1
    open func jumpIndex(to item: Int) -> (isJumpped: Bool, index: Int) {
        let curr = cellIndex()
        let currItemIndex = itemIndex(with: curr)
        var target = curr
        var isJumpped = true
        if currItemIndex > item  {
            target = curr - (currItemIndex - item)
        } else if currItemIndex < item {
            target = curr + (item - currItemIndex)
        } else {
            isJumpped = false
        }
        return (isJumpped, target)
    }
    
    /// scroll collectionView to target cell index
    /// - targetIndex Should between 0...itemCount-1
    open func scroll(to targetIndex: Int, isAnimated animated: Bool = true) {
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
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let action = selectedAction {
            action(self, itemIndex(with: indexPath.item))
        }
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
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
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let p = pageControl else {
            return
        }
        /// See isEndDragging defination
        isEndDragging = true
        p.endResponseDragging()
        validTimer()
    }
    
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard items.isEmpty == false, let action = scrolledAction else {
            return
        }
        action(self, itemIndex(with: cellIndex()))
    }
    
}
