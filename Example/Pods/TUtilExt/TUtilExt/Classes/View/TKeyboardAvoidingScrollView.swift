//
//  TKeyboardAvoidingScrollView.swift
//  Gallery
//
//  Created by tang on 9.7.21.
//

import UIKit
import TPKeyboardAvoiding
import RxSwift
import RxCocoa
import SnapKit

public class TKeyboardAvoidingScrollView: TPKeyboardAvoidingScrollView {
    
    private let disposeBag = DisposeBag()
    
    public var automaticallyUnfocus = true
    public var contentView: UIView = UIView()
    
    public convenience init(showIndicator: Bool = true) {
        self.init()
        self.showsVerticalScrollIndicator = showIndicator
        self.showsHorizontalScrollIndicator = showIndicator
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        contentView.add(to: self).layout { make in
            make.edges.width.height.equalToSuperview()
        }
        
        self.rx.willBeginDragging.subscribe(onNext: { [weak self] (_) in
            guard let self = self, self.automaticallyUnfocus else {return}
            self.endEditing(true)
        }).disposed(by: disposeBag)
    }
}
