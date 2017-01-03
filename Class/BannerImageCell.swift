//
//  ScrollBannerCell.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/27.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import UIKit

/// Struct
///
/// Data type for image cell
///
/// @discussion 
///     Change UIImage to String type, then we can handle http image and local image using imageView,
///     but create specific cell and cell data would be better.
///
public struct BannerImageCellData {
    public let image: UIImage
}


/// Class 
///
/// Default cell with a single image view
///
public class BannerImageCell: UICollectionViewCell {
    weak var imageView: UIImageView?
    
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
        let imgView = UIImageView()
        imgView.backgroundColor = UIColor.clear
        imgView.clipsToBounds = true
        imgView.contentMode = .scaleAspectFill
        self.contentView.addSubview(imgView)
        imageView = imgView
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        imageView?.frame = bounds
    }
}

extension BannerImageCell: Updatable {
    public typealias ViewData = BannerImageCellData
    
    public func update(viewData: BannerImageCellData) {
        imageView?.image = viewData.image
    }
}

