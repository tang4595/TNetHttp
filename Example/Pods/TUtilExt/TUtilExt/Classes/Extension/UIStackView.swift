//
//  UIStackView.swift
//  TUtilExt
//
//  Created by tang on 2023/12/7.
//

import UIKit

extension Array where Iterator.Element == UIView {
    
    public func asStackView(axis: NSLayoutConstraint.Axis = .horizontal,
                            distribution: UIStackView.Distribution = .fill,
                            spacing: CGFloat = 0,
                            contentHuggingPriority: UILayoutPriority? = nil,
                            perpendicularContentHuggingPriority: UILayoutPriority? = nil,
                            alignment: UIStackView.Alignment = .fill) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: self)
        stackView.axis = axis
        stackView.distribution = distribution
        stackView.alignment = alignment
        stackView.spacing = spacing
        
        if let contentHuggingPriority = contentHuggingPriority {
            switch axis {
            case .horizontal:
                stackView.setContentHuggingPriority(contentHuggingPriority, for: .horizontal)
            case .vertical:
                stackView.setContentHuggingPriority(contentHuggingPriority, for: .vertical)
            default:
                break
            }
        }
        
        if let perpendicularContentHuggingPriority = perpendicularContentHuggingPriority {
            switch axis {
            case .horizontal:
                stackView.setContentHuggingPriority(perpendicularContentHuggingPriority, for: .vertical)
            case .vertical:
                stackView.setContentHuggingPriority(perpendicularContentHuggingPriority, for: .horizontal)
            default:
                break
            }
        }
        return stackView
    }
}

extension UIStackView {
    
    public func addArrangedSubviews(_ views: [UIView]) {
        for each in views {
            addArrangedSubview(each)
        }
    }

    func removeAllArrangedSubviews() {
        for view in arrangedSubviews {
            view.removeFromSuperview()
        }
    }
}
