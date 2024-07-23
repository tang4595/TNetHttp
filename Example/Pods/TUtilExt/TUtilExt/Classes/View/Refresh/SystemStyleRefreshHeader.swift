//
//  SystemStyleRefreshHeader.swift
//  TUtilExt
//
//  Created by tang on 29.10.22.
//

import UIKit
import MJRefresh
import SnapKit

let kDefaultRefreshViewHeight = 65.0
let kDefaultAnimationViewWidth = 65.0
let kDefaultAnimationViewHeight = 44.0

public class SystemStyleRefreshHeader: MJRefreshStateHeader {
    
    var pullJsonFileName: String = ""
    var refreshJsonFileName: String = ""
    var refreshIndicator: UIActivityIndicatorView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(refreshingBlock: @escaping () -> Void) {
        self.init()
        self.refreshingBlock = refreshingBlock
    }
    
    convenience init(refreshingTarget: Any!, refreshingAction: Selector!) {
        self.init()
        self.setRefreshingTarget(refreshingTarget!, refreshingAction: refreshingAction)
    }
    
    public override func placeSubviews() {
        super.placeSubviews()
        setupViews()
    }
    
    public override var pullingPercent: CGFloat {
        didSet {
            if state != .idle || pullingPercent == -0 {
                return
            }
            /** 下拉比例 */
            guard let view = refreshIndicator else {return}
            view.transform = CGAffineTransform(rotationAngle: CGFloat.pi * pullingPercent)
        }
    }
    
    public override func endRefreshing() {
        if state != .refreshing {
            return
        }
        endRefreshingAction()
    }
}

private extension SystemStyleRefreshHeader {
    
    private func startRefreshingAnimation() {
        refreshIndicator?.isHidden = false
        refreshIndicator?.startAnimating()
    }
    
    private func endRefreshingAction() {
        state = .idle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.refreshIndicator?.stopAnimating()
            self.refreshIndicator?.isHidden = true
            self.refreshIndicator?.removeFromSuperview()
            self.refreshIndicator = nil
        }
    }
    
    private func setupViews() {
        refreshContentViewSetup()
        stateLabel?.isHidden = true
        lastUpdatedTimeLabel?.isHidden = true
        mj_h = CGFloat(kDefaultRefreshViewHeight)
        if state == .idle {
            refreshIndicator?.isHidden = false
        } else if state == .pulling {
            
        } else if state == .refreshing {
            startRefreshingAnimation()
        }
    }
    
    private func refreshContentViewSetup() {
        guard refreshIndicator == nil else {return}
        if #available(iOS 13.0, *) {
            refreshIndicator = UIActivityIndicatorView(style: .large)
        } else {
            refreshIndicator = UIActivityIndicatorView(style: .gray)
        }
        guard let refreshIndicator = refreshIndicator else {return}
        refreshIndicator.add(to: self).layout { make in
            make.center.equalToSuperview()
        }
    }
}

public extension SystemStyleRefreshHeader {
    
    func set(state: MJRefreshState) {
        self.state = state
    }
}
