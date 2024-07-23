//
//  Alert.swift
//  TUtilExt
//
//  Created by tang on 17.10.22.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import TAppBase

public enum AppAlertAnimationStyle {
    case center(scale: Double = AppAlertAnimationStyle.scaleFactorDefault)
    case bottom
}

public extension AppAlertAnimationStyle {
    
    static var scaleFactorDefault: Double { 0.8 }
}

public protocol AppAlertProtocol {
    
    var dismissWhenTapBackground: Bool  { get set }
    var subject: PublishSubject<Any>? { get set }
    var animate: AppAlertAnimationStyle { get set }
    
    func viewDidAppear() -> Void
}

public class AppAlertView: UIView {
    
    private let keyboardPadding: CGFloat = 5.0
    private let disposeBag = DisposeBag()
    private var alertView: (AppAlertProtocol & UIView)?
    private let subject = PublishSubject<Any>()
    
    private lazy var container: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor.clear
        container.clipsToBounds = true
        container.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        container.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return container
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        binds()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: Private

private extension AppAlertView {
    
    func binds() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillDismiss(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.subject.subscribe(onNext: { [weak self] _ in
            self?.hideSelf()
        }).disposed(by: self.disposeBag)
    }
    
    func addContent(alert: AppAlertProtocol & UIView) {
        self.alertView = alert
        self.alertView?.subject = subject
        self.container.addSubview(alert)
        let control = UIButton()
        control.setContentHuggingPriority(.defaultLow, for: .vertical)
        control.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        self.addSubview(control)
        self.addSubview(self.container)
        control.layout { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        control.rx.tap.subscribe(onNext: { [weak self] _ in
            if self?.alertView?.dismissWhenTapBackground ?? false {
                self?.subject.onError(AppError.ui(.custom(error: "Canceled")))
                self?.hideSelf()
            }
        }).disposed(by: self.disposeBag)
        
        alert.layout { (make) in
            make.edges.equalToSuperview()
        }
        
        switch self.alertView?.animate {
        case .center:
            self.container.layout { (make) in
                make.center.equalToSuperview()
            }
        case .bottom:
            self.container.layout { (make) in
                make.left.right.bottom.equalToSuperview()
            }
        case .none:
            break
        }
    }
    
    func show(withAnimation animation: Bool = true) {
        guard animation else {
            self.container.alpha = 1.0
            self.container.transform = CGAffineTransform.identity
            self.alertView?.viewDidAppear()
            return
        }
        
        self.backgroundColor = .clear
        switch self.alertView?.animate {
        case .center(let scale):
            self.container.alpha = 0.0
            self.container.transform = CGAffineTransform(scaleX: scale, y: scale)
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.backgroundColor = UIColor(white: 0, alpha: 0.5)
                self.container.alpha = 1.0
                self.container.transform = CGAffineTransform.identity
            }) { _ in
                self.alertView?.viewDidAppear()
            }
        case .bottom:
            self.container.transform = CGAffineTransform(translationX: 0, y: UIScreen.height)
            self.container.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundColor = UIColor(white: 0, alpha: 0.5)
                self.container.transform = .identity
                self.container.alpha = 1.0
            }) { _ in
                self.alertView?.viewDidAppear()
            }
        case .none:
            break
        }
    }
    
    func hideSelf() {
        switch self.alertView?.animate {
        case .center:
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                self.backgroundColor = .clear
                self.container.alpha = 0.0
                self.container.transform = CGAffineTransform(scaleX: 0, y: 0)
            }) { _ in
                self.removeFromSuperview()
            }
        case .bottom:
            UIView.animate(withDuration: 0.2, animations: {
                self.backgroundColor = .clear
                self.container.transform = CGAffineTransform(translationX: 0, y: UIScreen.height)
                self.container.alpha = 0
            }) { _ in
                self.removeFromSuperview()
            }
        case .none:
            break
        }
    }
}

// MARK: Public

public extension AppAlertView {
    
    @objc func keyboardWillShow(notification:Notification) -> Void {
        guard let info = notification.userInfo else {
            return
        }
        let keyboardRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardH = keyboardRect?.size.height ?? 0
        
        var contentMaxY: CGPoint = .zero
        if let contentView = self.container.subviews.first {
            let window = UIApplication.shared.keyWindow
            contentMaxY = contentView.convert(CGPoint(x: 0, y: contentView.bounds.height), to: window)
        }
        
        var offsetY = -keyboardH + CGFloat(UIScreen.safeAreaInsetsBottom)
        if let keyboardMinY = keyboardRect?.minY {
            if contentMaxY.y <= keyboardMinY {
                offsetY = -keyboardPadding
            } else {
                offsetY = -(contentMaxY.y - keyboardMinY) - keyboardPadding
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            self.container.transform = CGAffineTransform(translationX: 0, y: offsetY)
        }
    }
    
    @objc func keyboardWillDismiss(notification:Notification) -> Void {
        UIView.animate(withDuration: 0.3) {
            self.container.transform = .identity
        }
    }
}

public extension AppAlertView {
    
    static func show(content: AppAlertProtocol & UIView) -> PublishSubject<Any> {
        var contained = false
        let window = UIApplication.shared.keyWindow
        _ = window?.subviews.map({ (view) -> UIView in
            if view is AppAlertView {
                contained = true
                view.removeFromSuperview()
            }
            return view
        })
        let alert = AppAlertView(frame: UIScreen.main.bounds)
        alert.addContent(alert: content)
        window?.addSubview(alert)
        alert.show(withAnimation: !contained)
        return alert.subject
    }
    
    func hide() {
        hideSelf()
    }
}
