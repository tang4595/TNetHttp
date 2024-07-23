//
//  DispatchQueue.swift
//  Gallery
//
//  Created by tang on 13.7.21.
//

import Foundation
import Dispatch
import RxSwift
import TAppBase

public func DispatchAQueue(
    _ label: String, qos: DispatchQoS = .unspecified,
    attributes: DispatchQueue.Attributes = [],
    autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency = .inherit,
    target: DispatchQueue? = nil
) -> DispatchQueue {
    return DispatchQueue(
        label: "\(Bundle.main.bundleIdentifier ?? "dispatch").\(label)",
        attributes: attributes,
        autoreleaseFrequency: autoreleaseFrequency,
        target: target
    )
}

public func DispatchARxSerialScheduler(_ queue: DispatchQueue) -> SerialDispatchQueueScheduler {
    return SerialDispatchQueueScheduler(queue: queue, internalSerialQueueName: "internal.\(queue.label)")
}

public func DispatchARxSerialScheduler(_ label: String) -> SerialDispatchQueueScheduler {
    let queue = DispatchQueue(label: label)
    return DispatchARxSerialScheduler(queue)
}

public func DispatchARxConcurrentScheduler(
    _ queue: DispatchQueue,
    leeway: DispatchTimeInterval = DispatchTimeInterval.nanoseconds(0)
) -> ConcurrentDispatchQueueScheduler {
    return ConcurrentDispatchQueueScheduler(queue: queue, leeway: leeway)
}

public func DispatchARxConcurrentScheduler(
    _ label: String,
    leeway: DispatchTimeInterval = DispatchTimeInterval.nanoseconds(0)
) -> ConcurrentDispatchQueueScheduler {
    let queue = DispatchQueue(label: label)
    return ConcurrentDispatchQueueScheduler(queue: queue, leeway: leeway)
}

public extension DispatchQueue {
    
    fileprivate static var _onceTokens = [String]()
    
    class func once(token: String, block: () -> Void) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        guard !_onceTokens.contains(token) else {return}
        _onceTokens.append(token)
        block()
    }
    
    class func once(file: String = #file, function: String = #function, line: Int = #line, block: () -> Void) {
        once(token: "\(file)\(function)\(line)", block: block)
    }
}
