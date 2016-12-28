//
//  ProgressControl.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/27.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import UIKit


typealias ProgressPageControlAction = (_ control: ProgressPageControl, _ atIndex: Int) -> ()

/// ProgressPageControl
///
/// Using UIProgressView to indicate number of pages and animation
///
class ProgressPageControl: UIControl {
    
    var selectedAction: ProgressPageControlAction?
    var animateDuration: TimeInterval = 2.8
    var isAnimating: Bool = true
    var isSkip: Bool = false
    var hideForSingle: Bool = true {
        didSet {
            if hideForSingle, items.count == 1 {
                self.isHidden = true
            } else {
                self.isHidden = false
            }
        }
    }
    
    var lineSpace: CGFloat = 8.0 {
        didSet {
            if items.isEmpty {
                return
            }
            for index in 0 ..< items.count {
                items[index].frame = frame(at: index)
            }
        }
    }
    
    var numberOfpages: Int = 0 {
        willSet {
            cleanupIndicator()
        }
        didSet {
            for index in 0 ..< numberOfpages {
                let p = createProgressView()
                p.frame = frame(at: index)
                items.append(p)
            }
        }
    }
    
    var currentPage: Int = -1 {
        willSet {
            isSkip = currentPage == newValue
        }
        didSet {
            guard isSkip == false, currentPage >= 0, currentPage < items.count else {
                return
            }
            items[currentPage].animate()
        }
    }
    
    var indicatorHeight: CGFloat = 2.0
    var indicatorContentWidthLimit: CGFloat = 60.0
    
    /// calculate indicator size depends on items.count
    var indicatorSize: CGSize {
        if (numberOfpages == 0) {
            return CGSize.zero
        } else {
            let width = max( 0.0, ( bounds.width - lineSpace * CGFloat(numberOfpages + 1) ) ) / CGFloat(numberOfpages)
            
            return CGSize(width: min(width, indicatorContentWidthLimit), height: indicatorHeight)
        }
    }
    
    /// Help calculate originX of first indicator
    var indicatorContentWidth: CGFloat {
        if numberOfpages == 0 {
            return 0.0
        } else {
            return CGFloat(numberOfpages) * (indicatorSize.width + lineSpace) - lineSpace
        }
    }
    
    private var items:[ProgressView] = []

    
    deinit {
        print("ProgressPageControl.deinit")
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
    
    func cancelAnimation() {
        guard items.isEmpty == false, currentPage >= 0, currentPage < items.count else {
            return
        }
        items[currentPage].cancelAllAnimation()
    }
    
    /// calculate frame of indicator and update it's frame
    private func frame(at index: Int) -> CGRect {
        let size = indicatorSize
        let y = (bounds.height - size.height) * 0.5
        let x = (bounds.width - indicatorContentWidth) * 0.5 + (lineSpace + size.width) * CGFloat(index)
        
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
    
    /// create a UIProgressView instance and add it to super view (self)
    private func createProgressView() -> ProgressView {
        let p = ProgressView(frame: CGRect(origin: CGPoint.zero, size: indicatorSize))
        addSubview(p)
        return p
    }
    
    private func cleanupIndicator() {
        guard items.isEmpty == false, numberOfpages > 0 else {
            return
        }
        items.forEach { $0.removeFromSuperview() }
        items.removeAll()
    }
    
}






