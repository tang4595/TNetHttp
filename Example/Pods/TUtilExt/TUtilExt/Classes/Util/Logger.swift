//
//  Logger.swift
//  Gallery
//
//  Created by tang on 9.7.21.
//

import Foundation

public let enableLog = isDebug
public let enableApiLog = isDebug

public let logLevel: LogLevel = isRelease ? logLevelRelease : .debug
public let logLevelRelease: LogLevel = .error

public enum LogLevel: Int {
    case debug = 0
    case info
    case warn
    case error
    case none
}

public func log(content: String, level: LogLevel) {
    guard enableLog else {return}
    guard level.rawValue >= (isRelease ? logLevelRelease.rawValue : logLevel.rawValue) else {return}
    print("Logger::[\(level)] \(Date()) \(content)")
}

public func logDebug(file: String = #file, line: Int = #line, content: String) {
    log(content: "🔗 \(URL(string: file)?.lastPathComponent ?? file)[\(line)] : \(content)", level: .debug)
}

public func logInfo(file: String = #file, line: Int = #line, content: String) {
    log(content: "♻️ \(URL(string: file)?.lastPathComponent ?? file)[\(line)] : \(content)", level: .info)
}

public func logWarn(file: String = #file, line: Int = #line, content: String) {
    log(content: "⚠️ \(URL(string: file)?.lastPathComponent ?? file)[\(line)] : \(content)", level: .warn)
}

public func logError(file: String = #file, line: Int = #line, content: String) {
    log(content: "❌ \(URL(string: file)?.lastPathComponent ?? file)[\(line)] : \(content)", level: .error)
}
