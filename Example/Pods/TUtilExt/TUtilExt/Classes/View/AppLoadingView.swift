//
//  AppLoadingView.swift
//  TUtilExt
//
//  Created by tang on 17.10.22.
//

import UIKit
import SnapKit

extension UIActivityIndicatorView.Style {
    
    var containerSize: CGFloat {
        switch(self) {
        case .medium:
            return 50.0
        case .large:
            return 80.0
        case .whiteLarge:
            return 80.0
        case .white:
            return 50.0
        case .gray:
            return 50.0
        @unknown default:
            return 80.0
        }
    }
}

public class AppLoadingView: UIView {
    
    private var style: UIActivityIndicatorView.Style = .white
    
    convenience init(style: UIActivityIndicatorView.Style = .white) {
        self.init()
        self.style = style
        isUserInteractionEnabled = true
        uiSetup()
        binds()
    }
    
    private func uiSetup() {
        container.backgroundColor = .black.withAlphaComponent(0.9)
        container.layer.cornerRadius = 10.0
        container.layer.masksToBounds = true
        container.add(to: self).layout { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: style.containerSize, height: style.containerSize))
        }
        indicator.add(to: container).layout { make in
            make.center.equalToSuperview()
        }
    }
    
    private func binds() {
        
    }
    
    // MARK: - Widgets
    
    private let container = UIView()
    private lazy var indicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: style)
        view.hidesWhenStopped = true
        view.startAnimating()
        return view
    }()
}

public extension AppLoadingView {
    
    func dismiss() {
        indicator.stopAnimating()
        isHidden = true
        removeFromSuperview()
    }
}
