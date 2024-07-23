//
//  UIScrollView+Refresh.swift
//  TUtilExt
//
//  Created by tang on 29.10.22.
//

import UIKit
import RxSwift
import RxCocoa
import MJRefresh

public extension Reactive where Base: MJRefreshComponent {
    
    var refreshing: ControlEvent<Void> {
        let source: Observable<Void> = Observable.create {
            [weak control = self.base] observer  in
            if let control = control {
                control.refreshingBlock = {
                    observer.on(.next(()))
                }
            }
            return Disposables.create()
        }
        return ControlEvent(events: source)
    }
    
    var refreshCompleted: ControlEvent<Void> {
        let source: Observable<Void> = Observable.create {
            [weak control = self.base] observer  in
            if let control = control {
                control.endRefreshingCompletionBlock = {
                    observer.on(.next(()))
                }
            }
            return Disposables.create()
        }
        return ControlEvent(events: source)
    }

    var endRefreshing: Binder<Bool> {
        return Binder(base) { refresh, isEnd in
            if isEnd {
                refresh.endRefreshing()
            }
        }
    }
}

public extension Reactive where Base: UIScrollView {
    
    /// Reactive wrapper for `isScrolling`.
    var isScrolling: ControlProperty<Bool> {
        let bindingObserver = Binder<Bool>(self.base) { scrollView, isScrolling in
            
        }
        let source1 = didScroll.map({_ in true})
        let source2 = didScrollToTop.map({ _ in false})
        let source3 = didEndScrollingAnimation.map({_ in false })
        let source4 = didEndDecelerating.map({_ in false})
        let source5 = didEndDragging.map({$0})
        return ControlProperty(values: Observable<Bool>.merge([source1, source2, source3, source4, source5]), valueSink: bindingObserver)
    }
}

public extension UIScrollView {
    
    func addSystemStyleRefreshHeader(autoEnd: Bool = false, startRefreshingCallback: (() -> Void)? = nil) {
        let refreshHeader = SystemStyleRefreshHeader { [weak self] in
            startRefreshingCallback?()
            guard let self = self, autoEnd else {return}
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.mj_header?.endRefreshing()
            })
        }
        mj_header = refreshHeader
    }
}
