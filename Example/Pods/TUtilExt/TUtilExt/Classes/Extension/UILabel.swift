//
//  UILabel.swift
//  Gallery
//
//  Created by tang on 31.7.21.
//

import UIKit

public extension UILabel {
    
    @objc convenience init(text: String? = nil, 
                           textColor: UIColor,
                           font: UIFont,
                           textAlignment:NSTextAlignment = .left,
                           multiLines: Bool = false) {
        self.init(frame: .zero)
        self.text = text
        self.textColor = textColor
        self.font = font
        self.textAlignment = textAlignment
        self.numberOfLines = multiLines ? 0 : 1
    }
    
    @objc convenience init(text: String? = nil, 
                           textColor: UIColor,
                           font: UIFont,
                           multiLines: Bool = false) {
        self.init(frame: .zero)
        self.text = text
        self.textColor = textColor
        self.font = font
        self.numberOfLines = multiLines ? 0 : 1
    }
    
    convenience init(backgroundColor: UIColor, multiLines: Bool = false) {
        self.init(frame: .zero)
        self.backgroundColor = backgroundColor
        self.numberOfLines = multiLines ? 0 : 1
    }
    
    static func separater() -> UILabel {
        return UILabel(backgroundColor: UIColor.gray)
    }
}
