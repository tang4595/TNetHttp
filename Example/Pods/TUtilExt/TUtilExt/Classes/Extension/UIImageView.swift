//
//  UIImageView.swift
//  TUtilExt
//
//  Created by tang on 18.10.22.
//

import UIKit

public extension UIImageView {
    
    convenience init(_ imageName: String, contentMode: UIView.ContentMode = .scaleAspectFit) {
        self.init()
        self.image = UIImage(named: imageName)
        self.contentMode = contentMode
    }
}
