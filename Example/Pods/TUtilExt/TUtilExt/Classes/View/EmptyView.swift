//
//  EmptyView.swift
//  TUtilExt
//
//  Created by tang on 5.1.23.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import TAppBase

open class EmptyView: UIView {
    
    public enum Style {
        case normal(titleColor: UIColor, titleFont: UIFont)
    }
    
    public var titleStr: String = "No data" {
        didSet {
            updateContents()
        }
    }
    public var iconName: String = "emptyIcon" {
        didSet {
            updateContents()
        }
    }
    private var style: Style = .normal(titleColor: .c2, titleFont: .rg(14.0)) {
        didSet {
            updateLabelStyle(label: titleLbl, style: style)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        uiSetup()
        binds()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public convenience init(withTitle title: String, icon: String, style: Style? = nil) {
        self.init()
        self.titleStr = title
        self.iconName = icon
        if let style = style {
            self.style = style
        }
        uiSetup()
        binds()
    }
    
    private func uiSetup() {
        backgroundColor = .clear
        iconImageView.add(to: self).layout { make in
            make.centerX.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 215.0, height: 193.0))
        }
        titleLbl.add(to: self).layout { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(12.0)
            make.left.right.equalToSuperview().inset(LayoutStyle.sideMargin)
        }
    }
    
    private func binds() {
        
    }
    
    private func updateLabelStyle(label: UILabel, style: Style) {
        switch style {
        case let .normal(titleColor, titleFont):
            label.textColor = titleColor
            label.font = titleFont
        }
    }
    
    private func updateContents() {
        titleLbl.text = titleStr
        iconImageView.image = UIImage(named: iconName)
    }
    
    // MARK: - Widgets
    
    private lazy var iconImageView: UIImageView = {
        let img = UIImageView(image: UIImage(named: iconName))
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    fileprivate lazy var titleLbl: UILabel = {
        let label = UILabel(text: titleStr, textColor: .c4, font: .rg(14.0), textAlignment: .center, multiLines: true)
        updateLabelStyle(label: label, style: style)
        return label
    }()
}

public extension Reactive where Base: EmptyView {
    
    var title: Binder<String> {
        return Binder<String>(base) { (base, value) in
            base.titleLbl.text = value
        }
    }
}
