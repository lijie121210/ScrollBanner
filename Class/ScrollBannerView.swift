//
//  ScrollBannerView.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/26.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import UIKit


enum BannerIndicatorAsidePosition: Equatable {
    
    case top(tOffset: CGFloat)
    
    case bottom(bOffset: CGFloat)
    
    case left(lOffset: CGFloat)
    
    case right(rOffset: CGFloat)
    
    static func ==(lhs: BannerIndicatorAsidePosition, rhs: BannerIndicatorAsidePosition) -> Bool {
        switch (lhs, rhs) {
        case (.top(let a), .top(let b)) where a == b: return true
        case (.bottom(let a), .bottom(let b)) where a == b: return true
        case (.left(let a), .left(let b)) where a == b: return true
        case (.right(let a), .right(let b)) where a == b: return true
        default:
            return false
        }
    }
}


extension BannerIndicatorAsidePosition {
    
    func asideFrame(baseSize size: CGSize) -> CGRect {
        var result: CGRect = CGRect.zero
        let len: CGFloat = 20.0
        switch self {
        case .top(let tOffset): result = CGRect(x: 0.0, y: tOffset, width: size.width, height: len)
        case .bottom(let bOffset): result = CGRect(x: 0.0, y: size.height - len - bOffset, width: size.width, height: len)
        case .left(let lOffset): result = CGRect(x: lOffset, y: 0, width: len, height: size.height)
        case .right(let rOffset): result = CGRect(x: size.width - len - rOffset, y: 0, width: len, height: size.height)
        }
        return result
    }
    
}


/// - banner: Scroll banner view
/// - index : Selected this index or scrolled to this index
typealias BannerAction = (_ banner: ScrollBannerView, _ index: Int) -> ()



/// Banner
///
class ScrollBannerView: UIView {
    
    private var timer: Timer!
    
    var selectedAction: BannerAction?
    
    var scrolledACtion: BannerAction?
    
    /// itemCount = items.count * contentExpendFactor
    
    fileprivate var itemCount: Int = 0
    
    fileprivate let contentExpendFactor: Int = 50
    
    var items: [CellConfigurable] = [] {
        didSet {
            scroll()
        }
    }
    
    var collectionView: UICollectionView!
    
    var layout: BannerLayout! {
        didSet {
            updateLayout()
        }
    }
    
    var pageControl: ProgressPageControl!
    
    fileprivate var isSkip: Bool = false
    
    var pageControlAsidePosition: BannerIndicatorAsidePosition = .bottom(bOffset: 8.0) {
        willSet {
            isSkip = pageControlAsidePosition == newValue
        }
        didSet {
            guard isSkip == false else {
                return
            }
            updatePageControlPosition()
        }
    }
    
    /// calculate page control's frame depends on pageControlAsidePosition
    fileprivate var pageControlFrame: CGRect {
        return pageControlAsidePosition.asideFrame(baseSize: bounds.size)
    }
    
    
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
        scroll(to: itemCount / 2, false)
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
        scroll(to: currentIndex() + 1)
    }
    
    /// Collection View
    ///
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
    private func setupPageControl() -> ProgressPageControl {
        let control = ProgressPageControl(frame: pageControlFrame)
        control.backgroundColor = UIColor.clear
        addSubview(control)
        
        control.selectedAction = { [weak self] (_ control: ProgressPageControl, _ atIndex: Int) -> () in
            /// cancel current animation
            control.disableAnimation()
            
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
            
            sself.scroll(to: target, false)
            
            sself.fireTimer()
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
    
    
    private func updatePageControlPosition() {
        guard let p = pageControl, isSkip == false else {
            return
        }
        p.disableAnimation()
        
        p.frame = pageControlFrame
        
        p.enableAnimation()
    }
    
    
    /// Reset layout and reload data
    func update<T: UICollectionViewLayout>(bannerLayout newLayout: T) where T: BannerLayout {
        layout = newLayout
    }
    
    
    /// Reset items and begin scroll
    func update(items newItems: [CellConfigurable]) {
        items = newItems
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
        } else {
            itemCount = items.count * contentExpendFactor
            
            c.isScrollEnabled = true
            registerCells()
            c.reloadData()
            
            fireTimer()
        }
    }
    
    /// calculate index for cell : 0..<itemCount
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
    
    /// calculate index for data : 0..<items.count
    func itemIndex(with cellIndex: Int) -> Int {
        return cellIndex % items.count
    }
    
    /// scroll collectionView to target index
    func scroll(to targetIndex: Int, _ animated: Bool = true) {
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



extension ScrollBannerView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    /// UICollectionViewDataSource
    ///
    /// Layout cells with data source
    ///
    
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
        pageControl.disableAnimation()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        fireTimer()
        pageControl.enableAnimation()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollingAnimation(scrollView)
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard items.isEmpty == false, let action = scrolledACtion else {
            return
        }
        action(self, itemIndex(with: currentIndex()))
    }
    
}
