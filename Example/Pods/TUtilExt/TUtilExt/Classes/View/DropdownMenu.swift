//
//  DropdownMenu.swift
//  TUtilExt
//
//  Created by tang on 16.1.23.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

import TAppBase

public class DropdownMenuView: UIView {
    
    private lazy var bgView: UIView = {
        let view = UIView()
        view.layer.shadowRadius = 10.0
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .c4
        view.layer.cornerRadius = 5.0
        view.layer.masksToBounds = true
        stackView.add(to: view).layout { make in
            make.edges.equalToSuperview()
        }
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        var items: [DropdownMenuViewItem] = []
        for (i, str) in titles.enumerated() {
            let item = DropdownMenuViewItem()
            item.titleLabel.text = str
            item.isSelected = (selectedIndex ?? -1) == i
            items.append(item)
            item.onTap = { [weak self] in
                self?.subject.onNext(i)
                self?.dismiss()
            }
        }
        items.last?.line.isHidden = true
        stackView.addArrangedSubviews(items)
        return stackView
    }()
    
    private let disposeBag = DisposeBag()
    private var tapBtn: UIView!
    
    private let subject = PublishSubject<Int>()
    private let dismissSubject = PublishSubject<Void>()
    private var titles: [String] = []
    private var selectedIndex: Int?
    private var customMenuWidth: Float?
    private var isLeft: Bool = true
    private var topOffset: CGFloat = 0.0
    
    public init(titles: [String] = [], 
                tapBtn: UIView,
                customMenuWidth: Float? = nil,
                selectedIndex: Int? = nil,
                isLeft: Bool = true,
                topOffset: CGFloat = 0) {
        super.init(frame: .zero)
        self.titles = titles
        self.tapBtn = tapBtn
        self.customMenuWidth = customMenuWidth
        self.selectedIndex = selectedIndex
        self.isLeft = isLeft
        self.topOffset = topOffset
        uiSetup()
        binds()
    }
    
    public func show() -> PublishSubject<Int> {
        UIApplication.shared.keyWindow?.addSubview(self)
        self.layout { make in
            make.edges.equalToSuperview()
        }
        return subject
    }
    
    public func dismiss() {
        self.dismissSubject.onNext(())
        self.dismissSubject.onCompleted()
        self.removeFromSuperview()
    }
    
    private func uiSetup() {
        backgroundColor = .clear
        let point = tapBtn?.convert(tapBtn.bounds, to: UIApplication.shared.keyWindow)
        bgView.add(to: self).layout { make in
            if self.isLeft == true {
                make.left.equalTo(point?.minX ?? 0)
            } else {
                make.right.equalTo((point?.maxX ?? 0) - UIScreen.width)
            }
            if let customMenuWidth = customMenuWidth {
                make.width.equalTo(customMenuWidth)
            }
            make.top.equalTo((point?.maxY ?? 0 ) + topOffset)
        }
        contentView.add(to: bgView).layout { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func binds() {
        let tap = UITapGestureRecognizer()
        addGestureRecognizer(tap)
        tap.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss()
            })
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class DropdownMenuViewItem: UIView {
    
    let titleLabel = UILabel(text: "-", textColor: .c1, font: .md(14), textAlignment: .left, multiLines: false)
    let line = UIView.lineC6()
    var onTap: (() -> Void)?
    let disposeBag = DisposeBag()
    
    var isSelected: Bool = false {
        didSet {
            titleLabel.textColor = isSelected ? .c7 : .c1
        }
    }
    
    init() {
        super.init(frame: .zero)
        uiSetup()
        binds()
        let tap = UITapGestureRecognizer()
        addGestureRecognizer(tap)
        tap.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.onTap?()
            })
            .disposed(by: disposeBag)
    }
    
    func uiSetup() {
        titleLabel.add(to: self).layout { make in
            make.left.right.equalToSuperview().inset(8.0)
            make.top.bottom.equalToSuperview()
            make.width.lessThanOrEqualTo(UIScreen.width * 0.8)
            make.width.greaterThanOrEqualTo(100.0)
            make.height.equalTo(44.0)
        }
        line.add(to: self).layout { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func binds() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
