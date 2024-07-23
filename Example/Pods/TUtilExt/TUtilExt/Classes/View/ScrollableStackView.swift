//
//  ScrollableStackView.swift
//  TUtilExt
//
//  Created by tang on 4.11.22.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

public class ScrollableStackView: UIView {
    
    public var arrangedSubviews: [UIView] = []
    public var distribution: UIStackView.Distribution = .fill
    public var alignment: UIStackView.Alignment = .fill
    public var axis: NSLayoutConstraint.Axis = .vertical
    public var spacing: CGFloat = 0
    public var showIndicator: Bool = true
    
    public convenience init(withArrangedSubviews arrangedSubviews: [UIView],
                            distribution: UIStackView.Distribution,
                            alignment: UIStackView.Alignment,
                            axis: NSLayoutConstraint.Axis,
                            spacing: CGFloat,
                            showIndicator: Bool = true) {
        self.init()
        self.arrangedSubviews = arrangedSubviews
        self.arrangedSubviews = arrangedSubviews
        self.distribution = distribution
        self.alignment = alignment
        self.axis = axis
        self.spacing = spacing
        self.showIndicator = showIndicator
        uiSetup()
        binds()
    }
    
    private func uiSetup() {
        scrollView.add(to: self).layout { make in
            make.edges.equalToSuperview()
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func binds() {
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.updateContentSize()
        }
    }
    
    // MARK: - Widgets
    
    lazy var scrollView: TKeyboardAvoidingScrollView = {
        let view = TKeyboardAvoidingScrollView()
        view.showsVerticalScrollIndicator = self.showIndicator
        view.showsHorizontalScrollIndicator = self.showIndicator
        stackView.add(to: view.contentView).layout { make in
            make.top.left.right.equalToSuperview()
            make.width.equalToSuperview()
        }
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: arrangedSubviews)
        view.distribution = .fill
        view.alignment = .fill
        view.axis = .vertical
        view.spacing = spacing
        return view
    }()
}

// MARK: - Public
public extension ScrollableStackView {
    
    func updateContentSize() {
        scrollView.contentView.layout(.update) { make in
            make.height.equalToSuperview().offset(stackView.height - scrollView.height)
        }
    }
    
    func addArrangedSubviews(subviews: [UIView]) {
        guard !subviews.isEmpty else {return}
        arrangedSubviews.append(contentsOf: subviews)
        stackView.addArrangedSubviews(subviews)
        setNeedsLayout()
        layoutIfNeeded()
        updateContentSize()
    }
    
    func removeArrangedSubviews(subviews: [UIView]) {
        guard !subviews.isEmpty else {return}
        subviews.forEach { view in
            arrangedSubviews.removeAll(view)
            stackView.removeArrangedSubview(view)
        }
        setNeedsLayout()
        layoutIfNeeded()
        updateContentSize()
    }
    
    func removeArrangedSubviews() {
        stackView.removeArrangedSubviews()
        setNeedsLayout()
        layoutIfNeeded()
        updateContentSize()
    }
    
    func setArrangedSubviews(subviews: [UIView]) {
        removeArrangedSubviews()
        addArrangedSubviews(subviews: subviews)
    }
}

public extension Reactive where Base: ScrollableStackView {
    
    var dataSource: Binder<[UIView]> {
        return Binder<[UIView]>(base) { (base, value) in
            base.setArrangedSubviews(subviews: value)
        }
    }
}
