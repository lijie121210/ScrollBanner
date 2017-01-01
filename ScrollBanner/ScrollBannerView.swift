//
//  ScrollBannerView.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/26.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import UIKit


extension UIView {
    
    var isHorizontal: Bool {
        return bounds.width >= bounds.height
    }
    
}

extension CALayer {
    
    var isHorizontal: Bool {
        return bounds.width >= bounds.height
    }
    
}


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
    
    fileprivate var timer: Timer!
    
    var selectedAction: BannerAction?
    
    var scrolledAction: BannerAction?
    
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
    
    var pageControl: ProgressPageControl!
    
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
    private func setupPageControl() -> ProgressPageControl {
        let control = ProgressPageControl(frame: pageControlFrame)
        addSubview(control)
        
        control.selectedAction = { [weak self] (_ control: ProgressPageControl, _ atIndex: Int) -> () in
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


extension ScrollBannerView: UICollectionViewDataSource, UICollectionViewDelegate {
    
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






/// type define
///
typealias ProgressPageControlAction = (_ control: ProgressPageControl, _ atIndex: Int) -> ()

/// ProgressPageControl
///
/// Using UIProgressView to indicate number of pages and animation
///
class ProgressPageControl: UIControl {
    
    /// Saving all indicators
    fileprivate var items:[ProgressView] = []
    
    /// Click action callback
    var selectedAction: ProgressPageControlAction?
    
    
    var lineSpace: CGFloat = 8.0 {
        didSet {
            if oldValue != lineSpace {
                updateIndicatorFrame()
            }
        }
    }
    
    /// Update apperence
    
    var hidesForSinglePage: Bool = false {
        didSet {
            checkHidesForSinglePage()
        }
    }
    
    var pageIndicatorTintColor: UIColor? = UIColor(white: 0.9, alpha: 0.9) {
        didSet {
            guard items.isEmpty == false else {
                return
            }
            items.forEach { (p) in
                p.backgroundColor = pageIndicatorTintColor
            }
        }
    }
    
    var currentPageIndicatorTintColor: UIColor? = UIColor.gray {
        didSet {
            guard items.isEmpty == false else {
                return
            }
            items.forEach { (p) in
                p.bar.strokeColor = currentPageIndicatorTintColor?.cgColor
            }
        }
    }
    
    var numberOfPages: Int = 0 {
        willSet {
            cleanupIndicator()
        }
        didSet {
            for _ in 0 ..< numberOfPages {
                items.append( createIndicator() )
            }
            updateIndicatorFrame()
            
            checkHidesForSinglePage()
        }
    }
    
    var currentPage: Int = -1 {
        didSet {
            guard currentPage != oldValue && currentPage >= 0 && currentPage < items.count else {
                return
            }
            items[oldValue > 0 ? oldValue : 0].disableAnimation()
            items[currentPage].enableAnimation()
        }
    }
    
    fileprivate var layoutDirection: BannerScrollDirection {
        return isHorizontal ? .horizontal : .vertical
    }
    
    /// Height for each indicator
    var indicatorLength: CGFloat = 2.0 {
        didSet {
            if oldValue != indicatorLength {
                updateIndicatorFrame()
            }
        }
    }
    
    /// Limit width for each indicator
    var indicatorContentWidthLimit: CGFloat = 60.0 {
        didSet {
            if oldValue != indicatorContentWidthLimit {
                updateIndicatorFrame()
            }
        }
    }
    
    /// Limit height for each indicator
    var indicatorContentHeightLimit: CGFloat = 60.0 {
        didSet {
            if oldValue != indicatorContentHeightLimit {
                updateIndicatorFrame()
            }
        }
    }
    
    /// Size for each indicator
    ///
    /// Calculated depends on items.count and layoutDirection
    var indicatorSize: CGSize {
        var resultW: CGFloat = indicatorLength
        var resultH: CGFloat = indicatorLength
        
        if (numberOfPages == 0) {
            return CGSize.zero
        }
        
        switch layoutDirection {
        case .horizontal:
            let width = max( 0.0, ( bounds.width - lineSpace * CGFloat(numberOfPages + 1) ) ) / CGFloat(numberOfPages)
            resultW = min(width, indicatorContentWidthLimit)
        case .vertical:
            let height = max( 0.0, ( bounds.height - lineSpace * CGFloat(numberOfPages + 1) ) ) / CGFloat(numberOfPages)
            resultH = min(height, indicatorContentHeightLimit)
        }
        
        return CGSize(width: resultW, height: resultH)
    }
    
    /// Help calculate originX of first indicator
    var indicatorContentLength: CGFloat {
        if numberOfPages == 0 {
            return 0.0
        }
        var result: CGFloat = 0.0
        
        switch layoutDirection {
        case .horizontal:
            result = indicatorSize.width
        case .vertical:
            result = indicatorSize.height
        }
        
        return CGFloat(numberOfPages) * ( result + lineSpace) - lineSpace
    }
    
    
    override var frame: CGRect {
        didSet {
            updateIndicatorFrame()
            
            layoutIfNeeded()
        }
    }
    
    
    deinit {
        print("ProgressPageControl.deinit")
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            cleanupIndicator()
        }
    }
    
    /// - return Longest length
    func size(forNumberOfPages pageCount: Int) -> CGSize {
        switch layoutDirection {
        case .horizontal: return CGSize(width: indicatorContentLength, height: indicatorLength)
        case .vertical: return CGSize(width: indicatorLength, height: indicatorContentLength)
        }
    }
    
    /// check should hides
    fileprivate func checkHidesForSinglePage() {
        if numberOfPages == 1 && hidesForSinglePage {
            isHidden = true
        } else {
            isHidden = false
        }
    }
    
    /// Touch event
    ///
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first,
            let posv = touch.view as? ProgressView,
            let index = items.index(of: posv),
            let action = selectedAction {
            
            action(self, index)
        }
        super.touchesEnded(touches, with: event)
    }
    
    func disableAnimation() {
        guard items.isEmpty == false, currentPage >= 0, currentPage < items.count else {
            return
        }
        items.forEach { (p) in
            p.disableAnimation()
            p.isAnimatable = false
        }
    }
    
    func enableAnimation() {
        guard items.isEmpty == false, currentPage >= 0, currentPage < items.count else {
            return
        }
        items.forEach { (p) in
            p.isAnimatable = true
        }
    }
    
    /// create a UIProgressView instance and add it to super view (self)
    fileprivate func createIndicator() -> ProgressView {
        let p = ProgressView(frame: CGRect(origin: CGPoint.zero, size: indicatorSize))
        p.backgroundColor = pageIndicatorTintColor
        p.bar.strokeColor = currentPageIndicatorTintColor?.cgColor
        addSubview(p)
        return p
    }
    
    fileprivate func cleanupIndicator() {
        guard items.isEmpty == false, numberOfPages > 0 else {
            return
        }
        items.forEach { $0.removeFromSuperview() }
        items.removeAll()
        items = []
    }
    
    
    /// Update frame
    
    fileprivate func updateIndicatorFrame() {
        guard items.isEmpty == false else {
            return
        }
        for i in 0 ..< items.count {
            items[i].frame = frame(at: i)
        }
    }
    
    /// calculate frame of indicator and update it's frame
    fileprivate func frame(at index: Int) -> CGRect {
        let size = indicatorSize
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        
        switch layoutDirection {
        case .horizontal:
            x = (bounds.width - indicatorContentLength) * 0.5 + (lineSpace + size.width) * CGFloat(index)
            y = (bounds.height - size.height) * 0.5
        case .vertical:
            x = (bounds.width - size.width) * 0.5
            y = (bounds.height - indicatorContentLength) * 0.5 + (lineSpace + size.height) * CGFloat(index)
        }
        
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
    
    
    
}




class ProgressView: UIView, CAAnimationDelegate {
    
    struct AnimateKey {
        static let strokeEnd = "end_animate_key"
    }
    
    /// Set strokeColor / strokeStart / strokeEnd ...
    var bar: CAShapeLayer
    
    /// Set duration / timingFunction ...
    var endanimate: CABasicAnimation
    
    ///
    var isAnimatable: Bool = true
    
    deinit {
        print("ProgressView.deinit")
    }
    
    override init(frame: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: frame.width, y: 0.0))
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.lineWidth = frame.height
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeEnd = 0.001
        
        let end = CABasicAnimation(keyPath: "strokeEnd")
        end.fromValue = 0.001
        end.toValue = 1.001
        end.duration = 2.7
        end.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        end.isRemovedOnCompletion = true
        
        bar = layer
        
        endanimate = end
        
        super.init(frame: frame)
        
        endanimate.delegate = self
        
        self.layer.addSublayer(bar)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        var f = CGRect.zero
        var w: CGFloat = 0.0
        
        let path = UIBezierPath()
        path.move(to: CGPoint.zero)
        
        if layer.isHorizontal {
            f = CGRect(x: 0, y: layer.bounds.height * 0.5, width: layer.bounds.width, height: layer.bounds.height)
            w = layer.bounds.height
            path.addLine(to: CGPoint(x: layer.bounds.width, y: 0.0))
            
        } else {
            f = CGRect(x: layer.bounds.width * 0.5, y: 0, width: layer.bounds.width, height: layer.bounds.height)
            w = layer.bounds.width
            path.addLine(to: CGPoint(x: 0, y: layer.bounds.height))
        }
        bar.frame = f
        bar.path = path.cgPath
        bar.lineWidth = w
    }
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview == nil {
            
            endanimate.delegate = nil
            
            bar.removeAllAnimations()
            bar.removeFromSuperlayer()
        }
    }
    
    /// For beginning or stopping animation
    
    func enableAnimation() {
        if let _ = bar.animation(forKey: AnimateKey.strokeEnd) {
            bar.removeAnimation(forKey: AnimateKey.strokeEnd)
        }
        if isAnimatable {
            bar.add(endanimate, forKey: AnimateKey.strokeEnd)
        }
    }
    
    func disableAnimation() {
        if let _ = bar.animation(forKey: AnimateKey.strokeEnd) {
            bar.removeAnimation(forKey: AnimateKey.strokeEnd)
        }
    }
    
    /// CAAnimationDelegate
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim is CABasicAnimation {
            bar.strokeEnd = 0.001
        }
    }
}
