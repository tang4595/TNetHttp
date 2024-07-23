//
//  UIView.swift
//  Gallery
//
//  Created by tang on 9.7.21.
//

import UIKit
import RxSwift
import RxCocoa
import TAppBase
import SnapKit

// MARK: Layout

public extension UIView {
    enum LayoutAction {
        case make
        case update
        case remake
    }
}

public protocol ViewProtocol {}

extension UIView: ViewProtocol {}

public extension ViewProtocol where Self: UIView {
    
    @discardableResult
    func add(to superview: UIView) -> Self {
        superview.addSubview(self)
        return self
    }

    @discardableResult
    func layout(_ action: LayoutAction = .make, _ closure: (ConstraintMaker) -> Void) -> Self {
        let v: ((ConstraintMaker) -> Void) -> Void
        switch action {
        case .make:
           v =  self.snp.makeConstraints
        case .update:
           v = self.snp.updateConstraints
        case .remake:
           v = self.snp.remakeConstraints
        }
        v(closure)
        return self
    }

}

public extension ViewProtocol where Self: UIView {
    
    @discardableResult
    func set<Value>(_ path: ReferenceWritableKeyPath<Self, Value>, value: Value) -> Self {
        self[keyPath: path] = value
        return self
    }

    @discardableResult
    func `do`(_ handler: (Self) -> Void) -> Self {
        handler(self)
        return self
    }
}

public extension UIView {
    
    enum ConstraintPriorityDirection {
        case v, h
        var axis: NSLayoutConstraint.Axis {
            switch self {
            case .v: return .vertical
            case .h: return .horizontal
            }
        }
    }
    
    @discardableResult
    func setHigherHugging(_ direction: UIView.ConstraintPriorityDirection, more: Float = 0) -> Self {
        self.setContentHuggingPriority(.defaultHigh + more, for: direction.axis)
        return self
    }
    
    @discardableResult
    func setLowerHugging(_ direction: UIView.ConstraintPriorityDirection, less: Float = 0) -> Self {
        self.setContentHuggingPriority(.defaultLow - less, for: direction.axis)
        return self
    }
    
    @discardableResult
    func setHigherCompress(_ direction: UIView.ConstraintPriorityDirection, more: Float = 0) -> Self {
        self.setContentCompressionResistancePriority(.defaultHigh + more, for: direction.axis)
        return self
    }
    
    @discardableResult
    func setLowerCompress(_ direction: UIView.ConstraintPriorityDirection, less: Float = 0) -> Self {
        self.setContentCompressionResistancePriority(.defaultLow - less, for: direction.axis)
        return self
    }
}

// MARK: Util

public extension UIView {
    
    var layoutGuide: UILayoutGuide {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide
        } else {
            return layoutMarginsGuide
        }
    }

    var layoutInsets: UIEdgeInsets {
        if #available(iOS 11, *) {
            return safeAreaInsets
        } else {
            return layoutMargins
        }
    }
}

public extension UIView {
    
    enum GradientLayerDirection {
        case topToBottom
        case leftToRight
        
        var points: (CGPoint, CGPoint) {
            switch(self) {
            case .topToBottom:
                return (CGPoint(x: 0.5, y: 0), CGPoint(x: 0.5, y: 1.0))
            case .leftToRight:
                return (CGPoint(x: 0, y: 0.5), CGPoint(x: 1, y: 0.5))
            }
        }
    }
    
    func addGradientLayer(_ direction: GradientLayerDirection = .topToBottom, 
                          colors: [UIColor],
                          sendToBack: Bool = false) {
        guard let cf = colors.first?.cgColor else {return}
        let cs = colors.last?.cgColor ?? cf
        let gradientLayer = CAGradientLayer()
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = direction.points.0
        gradientLayer.endPoint = direction.points.1
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [cf, cs]
        for case let gls in layer.sublayers ?? [] where gls is CAGradientLayer {
            gls.removeFromSuperlayer()
        }
        if sendToBack {
            layer.insertSublayer(gradientLayer, at: 0)
        } else {
            layer.addSublayer(gradientLayer)
        }
    }
}

public extension UIView {
    
    @discardableResult
    func addDashedBorder(width: CGFloat,
                         length: CGFloat,
                         space: CGFloat,
                         cornerRadius: CGFloat,
                         color: UIColor) -> CAShapeLayer {
        self.layer.cornerRadius = cornerRadius
        let borderLayer =  CAShapeLayer()
        borderLayer.bounds = self.bounds
        
        borderLayer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY);
        borderLayer.path = UIBezierPath(roundedRect: borderLayer.bounds, cornerRadius: cornerRadius).cgPath
        borderLayer.lineWidth = width / UIScreen.main.scale
        
        borderLayer.lineDashPattern = [length,space]  as [NSNumber]?
        borderLayer.lineDashPhase = 0.1
        
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = color.cgColor
        self.layer.addSublayer(borderLayer)
        return borderLayer
   }
}

public class CenterContentView<T>: UIView where T: UIView {
    
    public let contentView: T
    
    public init(_ contentView: T, offset: CGPoint = .zero) {
        self.contentView = contentView
        super.init(frame: .zero)
        backgroundColor = .white
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(offset.x)
            make.centerY.equalToSuperview().offset(offset.y)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Event

public extension UIView {
    
    var tapEvent: ControlEvent<Bool> {
        let events = Observable<Bool>.create { [weak self] ob in
            guard let self = self else {
                return Disposables.create()
            }
            self.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer()
            tap.numberOfTapsRequired = 1
            let disposable = tap.rx.event.subscribe(onNext: { _ in
                ob.onNext(true)
            })
            self.addGestureRecognizer(tap)
            return Disposables.create([disposable])
        }
        return ControlEvent(events: events)
    }
    
    var doubleTapEvent: ControlEvent<Bool> {
        let events = Observable<Bool>.create { [weak self] ob in
            guard let self = self else {
                return Disposables.create()
            }
            self.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer()
            tap.numberOfTapsRequired = 2
            let disposable = tap.rx.event.subscribe(onNext: { _ in
                ob.onNext(true)
            })
            self.addGestureRecognizer(tap)
            return Disposables.create([disposable])
        }
        return ControlEvent(events: events)
    }
    
    var longPressEvent: ControlEvent<Bool> {
        let events = Observable<Bool>.create { [weak self] ob in
            guard let self = self else {
                return Disposables.create()
            }
            self.isUserInteractionEnabled = true
            let tap = UILongPressGestureRecognizer()
            let disposable = tap.rx.event.subscribe(onNext: { e in
                guard e.state == .ended else {return}
                ob.onNext(true)
            })
            self.addGestureRecognizer(tap)
            return Disposables.create([disposable])
        }
        return ControlEvent(events: events)
    }
}

// MARK: Component

public extension UIView {
    
    static func lineC6() -> UIView {
        let view = UIView()
        view.backgroundColor = .c6
        return view
    }
    
    static func lineFFF012() -> UIView {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.12)
        return view
    }
}

public class SpaceView: UIView {
    
    struct Const {
        static let height: CGFloat = 1
        static let width: CGFloat = 1
    }
    
    init(width: CGFloat = Const.width, height: CGFloat = Const.height) {
        super.init(frame: .zero)
        self.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: width, height: height))
        }
    }

    init(width: CGFloat = Const.width) {
        super.init(frame: .zero)
        self.snp.makeConstraints { make in
            make.width.equalTo(width)
        }
    }

    init(height: CGFloat = Const.height) {
        super.init(frame: .zero)
        self.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
