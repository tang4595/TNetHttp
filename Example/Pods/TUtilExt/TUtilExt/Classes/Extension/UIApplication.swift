//
//  UIApplication.swift
//  Gallery
//
//  Created by tang on 12.7.21.
//

import UIKit
import RTRootNavigationController
import TAppBase
import SafariServices
import TAppBase

public extension UIApplication {
    
    static func visibleController() -> UIViewController {
        var window = UIApplication.shared.keyWindow
        if window?.windowLevel != UIWindow.Level.normal {
            window = UIApplication.shared.windows.filter({$0.windowLevel == UIWindow.Level.normal}).first
        }
        var ctr = fetchTopController(controller: window?.rootViewController ?? UIViewController())
        while (ctr.presentedViewController != nil) {
            ctr = fetchTopController(controller: ctr.presentedViewController!)
        }
        return ctr
    }
    
    static func fetchTopController(controller: UIViewController) -> UIViewController {
        if controller is RTRootNavigationController {
            return fetchTopController(controller: (controller as! RTRootNavigationController).rt_topViewController)
        } else if controller is UINavigationController {
            return fetchTopController(controller: (controller as! UINavigationController).topViewController ?? controller)
        } else if controller is UITabBarController {
            return fetchTopController(controller: (controller as! UITabBarController).selectedViewController ?? controller)
        }
        return controller
    }
    
    static func topController() -> UIViewController {
        guard var root = UIApplication.shared.delegate?.window??.rootViewController else {
            return UIViewController()
        }
        
//        if let selectedVc = AppDelegate.shared().menus?.selectedViewController {
//            root = selectedVc
//        }

        while root.presentedViewController != nil {
            root = root.presentedViewController!
        }
        return root
    }
    
    static func topView() -> UIView {
        return topController().view
    }
    
    static func topWindow() -> UIWindow {
        guard let window = UIApplication.shared.windows.reversed().filter({$0.windowLevel == UIWindow.Level.normal}).first else {
            return UIWindow()
        }
        return window
    }
    
    static func pushController(_ controller: UIViewController, flutter:Bool = false) -> Void {
        var navController = self.topController()
//        if !navController.isKind(of: UINavigationController.self) , navController.navigationController != nil {
//            navController = navController.navigationController!
//        } else if !navController.isKind(of: UINavigationController.self) , let nav = AppDelegate.shared().menus?.navigationController {
//            navController = nav
//        }
        
        if (flutter) {
            if navController is RTRootNavigationController {
//                ( navController as! RTRootNavigationController).pushFlutterViewController(controller, animated: true, complete: nil);
            } else if navController is UINavigationController {
                (navController as! UINavigationController).pushViewController(controller, animated: true)
            } else if navController is AppBaseTabbBarController {
                let selectedNavController = (navController as! AppBaseTabbBarController).selectedViewController as? RTRootNavigationController
                selectedNavController?.pushViewController(controller, animated: true, complete: { _ in
                    
                })
            }
        } else {
            if navController is UINavigationController {
                (navController as! UINavigationController).pushViewController(controller, animated: true)
            } else if navController is AppBaseTabbBarController {
                let selectedNavController = (navController as! AppBaseTabbBarController).selectedViewController as? RTRootNavigationController
                selectedNavController?.pushViewController(controller, animated: true, complete: { _ in
                    
                })
            }
        }
    }
    
    static func presentController(_ controler: UIViewController) -> Void {
        self.topController().present(controler, animated: true) {
            
        }
    }
    
    static func push(_ controller: UIViewController, login: Bool = false, flutter: Bool = false) -> Void {
        if !login {
            UIApplication.pushController(controller,flutter: flutter)
            return
        }
        ///todo: router注册登录模块解耦，调用router登录模块
    }
    
    static func present(_ controller: UIViewController, login: Bool = false) -> Void {
        if !login {
            UIApplication.presentController(controller)
            return
        }
        ///todo: router注册登录模块解耦，调用router登录模块
    }
    
    static func pop(animated: Bool = true, toRoot: Bool = false, completion: ((Bool) -> Void)? = nil) -> Void {
        let topController = topController()
        if let controller = topController as? RTRootNavigationController {
            if toRoot {
                controller.popToRootViewController(animated: animated, complete: completion)
            } else {
                controller.popViewController(animated: animated) { status in
                    completion?(status)
                }
            }
        } else if let controller = topController as? UINavigationController {
            if toRoot {
                controller.popToRootViewController(animated: animated)
                completion?(true)
            } else {
                controller.popViewController(animated: animated) {
                    completion?(true)
                }
            }
        } else if let controller = topController as? UITabBarController {
            if let ctr = controller.selectedViewController as? RTRootNavigationController {
                if toRoot {
                    ctr.popToRootViewController(animated: animated, complete: completion)
                } else {
                    ctr.popViewController(animated: animated) { status in
                        completion?(status)
                    }
                }
            } else if let ctr = controller.selectedViewController as? UINavigationController {
                if toRoot {
                    ctr.popToRootViewController(animated: animated)
                    completion?(true)
                } else {
                    ctr.popViewController(animated: animated) {
                        completion?(true)
                    }
                }
            } else {
                if toRoot {
                    controller.navigationController?.popToRootViewController(animated: animated)
                    completion?(true)
                } else {
                    controller.navigationController?.popViewController(animated: animated) {
                        completion?(true)
                    }
                }
            }
        } else {
            if toRoot {
                topController.navigationController?.popToRootViewController(animated: animated)
                completion?(true)
            } else {
                topController.navigationController?.popViewController(animated: animated) {
                    completion?(true)
                }
            }
        }
    }
}

public extension UIApplication {
    
    static func showSafariBrowser(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        let controller = UIApplication.topController()
        let browser = SFSafariViewController(url: url)
        controller.present(browser, animated: true)
    }
}

public extension UIViewController {
    
    func pop(withLevel level: Int, animated: Bool = true) {
        guard level > 0 else {return}
        if level == 1 {
            UIApplication.pop()
            return
        }
        guard
            let vcs: [UIViewController] = self.navigationController?.viewControllers.reversed(), vcs.count > level
        else {return}
        self.navigationController?.popToViewController(vcs[level], animated: animated)
    }
}
