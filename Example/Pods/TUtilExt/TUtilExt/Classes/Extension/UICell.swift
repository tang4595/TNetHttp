//
//  UICell.swift
//  Gallery
//
//  Created by tang on 31.7.21.
//

import UIKit

public extension UITableViewCell {
    
    var tableView: UITableView? {
        return superview as? UITableView
    }
    
    static var identifier: String {
        return String(describing: self.classForCoder())
    }
}

public extension UICollectionViewCell {
    
    var collectionView: UICollectionView? {
        return superview as? UICollectionView
    }
    
    static var identifier: String {
        return String(describing: self.classForCoder())
    }
}
