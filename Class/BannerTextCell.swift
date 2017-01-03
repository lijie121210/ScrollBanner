//
//  BannerTextCell.swift
//  ScrollBanner
//
//  Created by jie on 2017/1/1.
//  Copyright © 2017年 HTIOT.Inc. All rights reserved.
//

import UIKit

public struct BannerTextCellData {
    public let text: String
}

public class BannerTextCell: UICollectionViewCell {
    
    weak var textLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override public func awakeFromNib() {
        super.awakeFromNib()
        createViews()
    }
    private func createViews() {
        let label = UILabel()
        contentView.addSubview(label)
        textLabel = label
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        guard let label = textLabel else {
            return
        }
        label.textAlignment = .center
        label.sizeToFit()
        textLabel?.frame = CGRect(x: (bounds.width - label.bounds.width) * 0.5,
                                  y: (bounds.height - label.bounds.height) * 0.5,
                                  width: label.bounds.width,
                                  height: label.bounds.height)
    }
}

extension BannerTextCell: Updatable {
    public typealias ViewData = BannerTextCellData
    
    public func update(viewData: BannerTextCellData) {
        textLabel?.text = viewData.text
    }
}
