//
//  ScreenUtils.swift
//  TUtilExt
//
//  Created by tang on 13.10.22.
//

import UIKit

// MARK: Generic Util

public let kPScale = UIScreen.main.bounds.size.width / 375.0
public let kBottomBarHeight = UIScreen.safeAreaInsetsBottom + 49
public func k375(_ value: CGFloat) -> CGFloat { value * kPScale }

public extension UIScreen {
    static let height: CGFloat = UIScreen.main.bounds.height
    static let width: CGFloat = UIScreen.main.bounds.width
    static var navigationBarHeight: CGFloat { 44.0 + statusBarHeight }
    
    static var safeAreaInsertsTop: CGFloat {
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let window = windowScene.windows.first else { return 0 }
            return window.safeAreaInsets.top
        } else if #available(iOS 11.0, *) {
            guard let window = UIApplication.shared.windows.first else { return 0 }
            return window.safeAreaInsets.top
        }
        return 0
    }
    
    static var safeAreaInsetsBottom: CGFloat {
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let window = windowScene.windows.first else { return 0 }
            return window.safeAreaInsets.bottom
        } else if #available(iOS 11.0, *) {
            guard let window = UIApplication.shared.windows.first else { return 0 }
            return window.safeAreaInsets.bottom
        }
        return 0
    }
    
    static var statusBarHeight: CGFloat {
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return 0 }
            guard let statusBarManager = windowScene.statusBarManager else { return 0 }
            statusBarHeight = statusBarManager.statusBarFrame.height
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        return statusBarHeight
    }
}

// MARK: Safe Area Util

public struct SafeAreaUtilWrapper<T> {
    var base: T
    init(_ base: T) {
        self.base = base
    }
}

public protocol SafeAreaUtilConvertable {}
public extension SafeAreaUtilConvertable {
    var safeArea: SafeAreaUtilWrapper<Self> { SafeAreaUtilWrapper(self) }
}

extension CGFloat: SafeAreaUtilConvertable {}
public extension SafeAreaUtilWrapper where T == CGFloat {
    var topOffset: CGFloat { UIScreen.safeAreaInsertsTop > 0 ? UIScreen.safeAreaInsertsTop + base : base }
    var bottomInset: CGFloat { UIScreen.safeAreaInsetsBottom > 0 ? UIScreen.safeAreaInsetsBottom + base : base }
}

extension Double: SafeAreaUtilConvertable {}
public extension SafeAreaUtilWrapper where T == Double {
    var topOffset: Double { UIScreen.safeAreaInsertsTop > 0 ? UIScreen.safeAreaInsertsTop + base : base }
    var bottomInset: Double { UIScreen.safeAreaInsetsBottom > 0 ? UIScreen.safeAreaInsetsBottom + base : base }
}
