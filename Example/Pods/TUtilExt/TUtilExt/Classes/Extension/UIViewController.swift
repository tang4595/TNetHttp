//
//  UIViewController.swift
//  Gallery
//
//  Created by tang on 5.7.21.
//

import UIKit
import RxSwift
import TAppBase

extension UIViewController {
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}

// MARK: - BarItem

public extension UIViewController {
    
    func hideBackBarButton() {
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)]
    }
    
    func addLeftItems(imgs: [UIImage?], clicked: @escaping(Int) -> Void) {
        var itemArr: [UIBarButtonItem] = []
        for (i, image) in imgs.enumerated() {
            let btn = UIButton()
            btn.frame = CGRect.init(origin: .zero, size: CGSize.init(width: 20, height: 25))
            btn.setImage(image, for: .normal)
            _ = btn.rx.controlEvent(.touchUpInside)
                .take(until: self.rx.deallocated)
                .subscribe(onNext: { (_) in
                    clicked(i)
                })
            itemArr.append(UIBarButtonItem.init(customView: btn))
        }
        self.navigationItem.leftBarButtonItems = itemArr
    }
    
    func addRightItem(title: String?, clicked: @escaping() -> Void) {
        let item = UIBarButtonItem()
        item.title = title
        _ = item.rx.tap.asControlEvent()
            .take(until: self.rx.deallocated)
            .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { (_) in
                clicked()
            })
        item.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: AppStyle.barMenu.color,
            NSAttributedString.Key.font: AppStyle.barMenu.font
        ], for: .normal)
        self.navigationItem.rightBarButtonItems = [item]
    }
    
    func addRightItem(img: UIImage?, clicked: @escaping(UIButton) -> Void) {
        let btn = UIButton()
        btn.frame = CGRect.init(origin: .zero, size: CGSize.init(width: 25, height: 25))
        btn.setImage(img, for: .normal)
        _ = btn.rx.controlEvent(.touchUpInside)
            .take(until: self.rx.deallocated)
            .subscribe(onNext: { (_) in
                clicked(btn)
            })
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(customView: btn)]
    }
    
    func addRightItems(imgs: [UIImage?], clicked: @escaping((Int) -> Void)) {
        var itemArr: [UIBarButtonItem] = []
        for (i, image) in imgs.enumerated() {
            let btn = UIButton()
            btn.frame = CGRect.init(origin: .zero, size: CGSize.init(width: 25, height: 25))
            btn.setImage(image, for: .normal)
            _ = btn.rx.controlEvent(.touchUpInside)
                .take(until: self.rx.deallocated)
                .subscribe(onNext: { (_) in
                    clicked(i)
                })
            itemArr.append(UIBarButtonItem.init(customView: btn))
        }
        self.navigationItem.rightBarButtonItems = itemArr.reversed()
    }
    
    func addRightItems(titles: [String?], clicked: @escaping((Int) -> Void)) {
        var itemArr: [UIBarButtonItem] = []
        for (i, title) in titles.enumerated() {
            let btn = UIButton()
            btn.frame = CGRect.init(origin: .zero, size: CGSize.init(width: 25, height: 25))
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(AppStyle.barMenu.color, for: .normal)
            btn.titleLabel?.font = AppStyle.barMenu.font
            _ = btn.rx.controlEvent(.touchUpInside)
                .take(until: self.rx.deallocated)
                .subscribe(onNext: { (_) in
                    clicked(i)
                })
            itemArr.append(UIBarButtonItem.init(customView: btn))
        }
        self.navigationItem.rightBarButtonItems = itemArr.reversed()
    }
}
