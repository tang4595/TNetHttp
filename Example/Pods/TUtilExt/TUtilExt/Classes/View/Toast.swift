//
//  Toast.swift
//  Gallery
//
//  Created by tang on 21.7.21.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import TAppBase

fileprivate let dismissDelaySec: TimeInterval = 3
fileprivate let loadingTimeoutSec: TimeInterval = 15

public struct ActionSheetDataItem {
    
    public let title: String
    public let icon: UIImage?
}

public extension String {
    
    static var defaultError: String { "Failed" }
    static var defaultSuccess: String { "Succeed" }
}

public class Toast: UIView {
    
    public enum Icon {
        case info
        case error
        case custom(icon: UIImage)
    }
    
    public enum Animation {
        case centerScale
        case topToCenter
        case bottomToCenter
    }
    
    public enum `Type` {
        case info(message: String)
        case error(message: String)
        case custom(message: String, icon: Icon, animation: Animation = .centerScale)
        case alert(message: String, title: String? = nil, confirmButton: String = "确定", cancelButton: String? = "取消")
        case actionSheet(title: String? = nil, items: [ActionSheetDataItem], cancelButton: String? = "取消")
        
        public var message: String? {
            switch self {
            case .info(let msg), .error(let msg), .custom(let msg, _, _), .alert(let msg, _, _, _):
                return msg
            default: return nil
            }
        }
        
        public var icon: UIImage? {
            switch self {
            case let .custom(_, icon, _):
                switch icon {
                case .info:
                    return UIImage(named: "info")
                case .error:
                    return UIImage(named: "inferror")
                case let .custom(iconImg):
                    return iconImg
                }
            default: return nil
            }
        }
        
        public var animation: Animation? {
            switch self {
            case .info(_), .error(_):
                return .centerScale
            case let .custom(_, _, animation):
                return animation
            default: return nil
            }
        }
        
        public var title: String? {
            switch self {
            case .alert(_, let title, _, _), .actionSheet(let title, _, _):
                return title
            default: return nil
            }
        }
        
        public var confirmButton: String? {
            switch self {
            case let .alert(_, _, confirmButton, _):
                return confirmButton
            default: return nil
            }
        }
        
        public var cancelButton: String? {
            switch self {
            case .alert(_, _, _, let cancelButton), .actionSheet(_, _, let cancelButton):
                return cancelButton
            default: return nil
            }
        }
        
        public var actions: [ActionSheetDataItem]? {
            switch self {
            case let .actionSheet(_, items, _):
                return items
            default: return nil
            }
        }
    }
    
    public enum Container {
        case window
        case topView(includeNavigationBar: Bool = true)
        
        public var value: UIView {
            switch self {
            case .window:
                return UIApplication.topView()
            case .topView(_):
                return UIApplication.topWindow()
            }
        }
        
        public var includeNavigationBar: Bool {
            switch self {
            case let .topView(includeNavigationBar):
                return includeNavigationBar
            default: return true
            }
        }
    }
    
    private var type: `Type` = .info(message: "")
    private var icon: UIImage?
    private var animation: Animation?
    private var container: Container!
    private static var loadingView: AppLoadingView?
    
    private lazy var label: UILabel = {
        let label = UILabel(text: nil, textColor: .white, font: AppStyle.title.font, textAlignment: .center)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.8)
        view.layer.cornerRadius = 4.0
        view.layer.masksToBounds = true
        label.add(to: view).layout { make in
            make.left.right.equalToSuperview().inset(LayoutStyle.sideMargin)
            make.top.bottom.equalToSuperview().inset(8.0)
        }
        return view
    }()
    
    convenience init(_ type: `Type`, container: Container!) {
        self.init()
        self.type = type
        self.container = container
        self.icon = type.icon
        self.uiSetup()
    }
    
    private func uiSetup() {
        guard let message = type.message else {
            return
        }
        backgroundColor = .clear
        isUserInteractionEnabled = false
        
        label.text = message
        contentView.add(to: self).layout { [weak self] make in
            guard let self = self else {return}
            switch self.type.animation {
            case .centerScale, .none:
                make.center.equalToSuperview()
                make.left.greaterThanOrEqualTo(self.snp.left)
                make.left.lessThanOrEqualTo(self.snp.right)
            case .topToCenter:
                make.centerX.equalToSuperview()
                make.bottom.equalTo(self.snp.top)
                make.left.greaterThanOrEqualTo(self.snp.left)
                make.left.lessThanOrEqualTo(self.snp.right)
            case .bottomToCenter:
                make.centerX.equalToSuperview()
                make.top.equalTo(self.snp.bottom)
                make.left.greaterThanOrEqualTo(self.snp.left)
                make.left.lessThanOrEqualTo(self.snp.right)
            }
        }
    }
    
    func show(_ toast: Toast, animation: Bool = true) {
        toast.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + dismissDelaySec) { [weak self] in
            self?.dismiss()
        }
    }
    
    func dismiss() {
        self.removeFromSuperview()
    }
    
    static func addToWindow(view: UIView) -> Void {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        view.add(to: window).layout { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - Info

public extension Toast {
    
    private static func doCustom(_ type: `Type`, container: Container = .window) {
        guard DispatchQueue.isMainQueue else {return}
        loading(false)
        let toast = Toast(type, container: container)
        toast.isHidden = true
        toast.add(to: container.value).layout { make in
            make.edges.equalToSuperview()
        }
        toast.show(toast)
    }
    
    static func custom(_ type: `Type`, container: Container = .window) {
        if DispatchQueue.isMainQueue {
            doCustom(type, container: container)
        } else {
            DispatchQueue.main.async {
                doCustom(type, container: container)
            }
        }
    }
    
    static func info(_ message: String, container: Container = .window) {
        custom(.info(message: message), container: container)
    }
    
    static func error(_ message: String?, container: Container = .window) {
        custom(.error(message: message ?? .defaultError), container: container)
    }
    
    static func error(_ error: Error?, container: Container = .window) {
        custom(.error(message: error?.localizedDescription ?? .defaultError), container: container)
    }
    
    static func custom(_ message: String, icon: Icon, animation: Animation, container: Container = .window) {
        custom(.custom(message: message, icon: icon, animation: animation), container: container)
    }
}

// MARK: - ActionSheet

// MARK: - Loading

public extension Toast {
    
    private static func doLoading(_ show: Bool = true) {
        loadingView?.dismiss()
        if show {
            loadingView = AppLoadingView(style: .white)
            guard let loadingView = loadingView else {return}
            addToWindow(view: loadingView)
            DispatchQueue.main.asyncAfter(deadline: .now() + loadingTimeoutSec, execute: {
                loadingView.dismiss()
            })
        }
    }
    
    static func loading(_ show: Bool = true) {
        if DispatchQueue.isMainQueue {
            doLoading(show)
        } else {
            DispatchQueue.main.async {
                doLoading(show)
            }
        }
    }
}
