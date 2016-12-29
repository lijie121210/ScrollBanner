//
//  Compatible.swift
//  ScrollBanner
//
//  Created by jie on 2016/12/27.
//  Copyright © 2016年 HTIOT.Inc. All rights reserved.
//

import Foundation
import UIKit

/// Thanks to https://github.com/fastred/ConfigurableTableViewController
///
/// Protocal
///
/// Requirement for cell
///
protocol Updatable: class {
    
    associatedtype ViewData
    
    func update(viewData: ViewData)
}


/// Protocal
/// 
/// Requirement for cell configurator
///
protocol CellConfigurable {
    var reuseIdentifier: String { get }
    var cellClass: AnyClass { get }
    
    func update(cell: UICollectionViewCell)
}

/// Struct
///
/// Basic configurator for cell
///
struct CellConfigurator<Cell> where Cell: Updatable, Cell: UICollectionViewCell {
    
    let reuseIdentifier: String = "\(Cell.self)"
    let cellClass: AnyClass = Cell.self
    
    /// need init
    let viewData: Cell.ViewData
    
    func update(cell: UICollectionViewCell) {
        if let cell = cell as? Cell {
            cell.update(viewData: viewData)
        }
    }
}

extension CellConfigurator: CellConfigurable {
}






