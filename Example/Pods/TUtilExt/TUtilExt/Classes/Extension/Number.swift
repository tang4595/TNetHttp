//
//  Number.swift
//  TUtilExt
//
//  Created by tang on 19.10.22.
//

import Foundation
import TAppBase

public let kNumberFormatDecimalLengthMax: Int = 4

// MARK: - Decimal

fileprivate let kAmountKMMaxVal: Decimal = 10000000

public enum NumberFormatStringType {
    case amount, generic
}

public extension Decimal {
    
    var doubleValue: Double {
        return decimalNumber.doubleValue
    }
    
    var decimalNumber: NSDecimalNumber {
        return NSDecimalNumber(decimal: self)
    }
    
    /// 只入不舍
    func roundUp(_ scale: Int) -> Decimal {
        return round(.up, scale: scale)
    }

    /// 只舍不入
    func roundDown(_ scale: Int) -> Decimal {
        return round(.down, scale: scale)
    }
    
    /// 四舍五入
    func roundPlain(_ scale: Int) -> Decimal {
        return round(.plain, scale: scale)
    }

    private func round(_ roundingMode: NSDecimalNumber.RoundingMode, scale: Int) -> Decimal {
        let behaviors = NSDecimalNumberHandler(roundingMode: roundingMode,
                                               scale: Int16(scale),
                                               raiseOnExactness: false,
                                               raiseOnOverflow: false,
                                               raiseOnUnderflow: false,
                                               raiseOnDivideByZero: false)
        return self.decimalNumber.rounding(accordingToBehavior: behaviors).decimalValue
    }
    
    func format(_ minF: Int = 2, 
                maxF: Int = kNumberFormatDecimalLengthMax,
                minI: Int = 1,
                roundingMode: NumberFormatter.RoundingMode = .down,
                stringType: NumberFormatStringType = .generic) -> String {
        let decimalPlacesFormatter = NumberFormatter()
        switch stringType {
        case .amount:
            decimalPlacesFormatter.positiveFormat = "###,##0.00"
        default: break
        }
        decimalPlacesFormatter.roundingMode = roundingMode
        decimalPlacesFormatter.maximumFractionDigits = maxF
        decimalPlacesFormatter.minimumFractionDigits = minF
        decimalPlacesFormatter.minimumIntegerDigits = minI
        decimalPlacesFormatter.locale = Locale(identifier: "en_US")
        
        guard let value = decimalPlacesFormatter.string(from: decimalNumber) else {
            return  "-"
        }
        return value
    }
    
    func amountFormat(_ minF: Int = 2, 
                      maxF: Int = kNumberFormatDecimalLengthMax,
                      minI: Int = 1,
                      roundingMode: NumberFormatter.RoundingMode = .down,
                      stringType: NumberFormatStringType = .generic) -> String {
        return format(minF, maxF: maxF, minI: minI, roundingMode: roundingMode, stringType: .amount)
    }

    func formatKM(_ minF: Int = 2, 
                  maxF: Int = kNumberFormatDecimalLengthMax,
                  minI: Int = 1,
                  roundingMode: NumberFormatter.RoundingMode = .down) -> String {
        return self > 1000000000 ? (self / 1000000000).format(2, maxF: 2, minI: minI,roundingMode: roundingMode) + "Bn" :
            self > 1000000 ? (self / 1000000).format(2, maxF: 2, minI: minI,roundingMode: roundingMode) + "M" :
            self > 1000 ? (self / 1000).format(2, maxF: 2, minI: minI,roundingMode: roundingMode) + "K" :
            self.format(minF, maxF: maxF, minI: minI,roundingMode: roundingMode)
    }
    
    func autoFormatKM(withMaxF maxF: Int = 2) -> String {
        guard self >= kAmountKMMaxVal else {
            return format(maxF: maxF)
        }
        return formatKM(maxF: maxF)
    }
}

// MARK: - Double

public extension Double {
    
    func format(_ minF: Int = 0, 
                maxF: Int = kNumberFormatDecimalLengthMax,
                minI: Int = 1,
                roundingMode: NumberFormatter.RoundingMode = .down,
                stringType: NumberFormatStringType = .generic) -> String {
        let value: Double = String(format: "%.\(maxF+1)f", self).double() ?? self
        let decimalPlacesFormatter = NumberFormatter()
        switch stringType {
        case .amount:
            decimalPlacesFormatter.positiveFormat = "###,##0.00"
        default: break
        }
        decimalPlacesFormatter.roundingMode = roundingMode
        decimalPlacesFormatter.maximumFractionDigits = maxF
        decimalPlacesFormatter.minimumFractionDigits = minF
        decimalPlacesFormatter.minimumIntegerDigits = minI
        decimalPlacesFormatter.locale = Locale(identifier: "en_US")
        
        guard let value = decimalPlacesFormatter.string(from: value.decimalWrapper) else {
            return  "-"
        }
        return value
    }
    
    func amountFormat(_ minF: Int = 2, 
                      maxF: Int = kNumberFormatDecimalLengthMax,
                      minI: Int = 1,
                      roundingMode: NumberFormatter.RoundingMode = .down, stringType: NumberFormatStringType = .generic) -> String {
        return format(minF, maxF: maxF, minI: minI, roundingMode: roundingMode, stringType: .amount)
    }
    
    func formatKM(_ minF: Int = 2, 
                  maxF: Int = kNumberFormatDecimalLengthMax,
                  minI: Int = 1,
                  roundingMode:NumberFormatter.RoundingMode = .down) -> String {
        return self > 1000000000 ? (self/1000000000).format(minF, maxF: 2, minI: minI,roundingMode: roundingMode) + "Bn"
            : self > 1000000 ? (self/1000000).format(minF, maxF: 2, minI: minI,roundingMode: roundingMode) + "M"
            : self > 1000 ? (self/1000).format(minF, maxF: 2, minI: minI,roundingMode: roundingMode) + "K"
            : self.format(minF, maxF: maxF, minI: minI,roundingMode: roundingMode)
    }
    
    /// 精确到15位
    var decimalWrapper: NSDecimalNumber {
        return NSDecimalNumber(string: String(self))
    }
    
    /// 精确到15位
    var decimal:Decimal {
        return Decimal(self)
    }

    static func > (left: Double, right: Double) -> Bool {
        return left.g(right)
    }

    static func < (left: Double, right: Double) -> Bool {
        return left.l(right)
    }

    static func != (left: Double, right: Double) -> Bool {
        return left.ne(right)
    }

    static func >= (left: Double, right: Double) -> Bool {
        return left.ge(right)
    }

    static func <= (left: Double, right: Double) -> Bool {
        return left.le(right)
    }
    
    func g(_ other: Double) -> Bool {
        return self.decimalWrapper.g(other.decimalWrapper)
    }
    
    func l(_ other: Double) -> Bool {
        return self.decimalWrapper.l(other.decimalWrapper)
    }
    
    func e(_ other: Double) -> Bool {
        return self.decimalWrapper.e(other.decimalWrapper)
    }
    
    func ne(_ other: Double) -> Bool {
        return self.decimalWrapper.ne(other.decimalWrapper)
    }
    
    func le(_ other: Double) -> Bool {
        return self.decimalWrapper.le(other.decimalWrapper)
    }
    
    func ge(_ other: Double) -> Bool {
        return self.decimalWrapper.ge(other.decimalWrapper)
    }
}

// MARK: - NSNumber

public extension NSNumber {
    
    static func + (left: NSNumber, right: NSNumber) -> NSNumber {
        return left.add(right)
    }

    static func - (left: NSNumber, right: NSNumber) -> NSNumber {
        return left.sub(right)
    }

    static func * (left: NSNumber, right: NSNumber) -> NSNumber {
        return left.mul(right)
    }

    static func / (left: NSNumber, right: NSNumber) -> NSNumber {
        return left.div(right)
    }

    static func > (left: NSNumber, right: NSNumber) -> Bool {
        return left.g(right)
    }

    static func < (left: NSNumber, right: NSNumber) -> Bool {
        return left.l(right)
    }

    static func != (left: NSNumber, right: NSNumber) -> Bool {
        return left.ne(right)
    }

    static func >= (left: NSNumber, right: NSNumber) -> Bool {
        return left.ge(right)
    }

    static func <= (left: NSNumber, right: NSNumber) -> Bool {
        return left.le(right)
    }

    var decimal: NSDecimalNumber {
        /// 精度最大支持16位
        let doubleString = String(format: "%@", self)
        return NSDecimalNumber(string: doubleString)
    }
    
    ///<
    func l(_ other: NSNumber) -> Bool {
        return self.decimal.compare(other.decimal) == .orderedAscending
    }
    ///>
    func g(_ other: NSNumber) -> Bool {
        return self.decimal.compare(other.decimal) == .orderedDescending
    }
    /// ==
    func e(_ other: NSNumber) -> Bool {
        return self.decimal.compare(other.decimal) == .orderedSame
    }
    ///!=
    func ne(_ other: NSNumber) -> Bool {
        return self.decimal.compare(other.decimal) != .orderedSame
    }
    ///<=
    func le(_ other: NSNumber) -> Bool {
        let result = self.decimal.compare(other.decimal)
        return  result == .orderedSame || result == .orderedAscending
    }
    ///>=
    func ge(_ other: NSNumber) -> Bool {
        let result = self.decimal.compare(other.decimal)
        return  result == .orderedSame || result == .orderedDescending
    }

    func add(_ other: NSNumber) -> NSNumber {
        return self.decimal.adding(other.decimal)
    }

    func sub(_ other: NSNumber) -> NSNumber {
        return self.decimal.subtracting(other.decimal)
    }

    func mul(_ other: NSNumber) -> NSNumber {
        return self.decimal.multiplying(by: other.decimal)
    }

    func div(_ other: NSNumber) -> NSNumber {
        return self.decimal.dividing(by: other.decimal)
    }

    func roundUp(_ scale: Int) -> NSNumber {
        return round(.up, scale: scale)
    }

    func roundDown(_ scale: Int) -> NSNumber {
        return round(.down, scale: scale)
    }

    func roundPlain(_ scale: Int) -> NSNumber {
        return round(.plain, scale: scale)
    }

    func round(_ roundingMode: NSDecimalNumber.RoundingMode, scale: Int) -> NSNumber {
        let behaviors = NSDecimalNumberHandler(roundingMode: roundingMode,
                                               scale: Int16(scale),
                                               raiseOnExactness: false,
                                               raiseOnOverflow: false,
                                               raiseOnUnderflow: false,
                                               raiseOnDivideByZero: false)
        return self.decimal.rounding(accordingToBehavior: behaviors)
    }

    func format(_ minF: Int = 2, 
                maxF: Int = kNumberFormatDecimalLengthMax,
                minI: Int = 1,
                roundingMode: NumberFormatter.RoundingMode = .down,
                stringType: NumberFormatStringType = .generic) -> String {
        let decimalPlacesFormatter = NumberFormatter()
        switch stringType {
        case .amount:
            decimalPlacesFormatter.positiveFormat = "###,##0.00"
        default: break
        }
        decimalPlacesFormatter.roundingMode = roundingMode
        decimalPlacesFormatter.maximumFractionDigits = maxF
        decimalPlacesFormatter.minimumFractionDigits = minF
        decimalPlacesFormatter.minimumIntegerDigits = minI
        decimalPlacesFormatter.locale = Locale(identifier: "en_US")
        
        guard let value = decimalPlacesFormatter.string(from: self.decimal) else {
            return  "-"
        }
        return value
    }
    
    func amountFormat(_ minF: Int = 2, 
                      maxF: Int = kNumberFormatDecimalLengthMax,
                      minI: Int = 1,
                      roundingMode: NumberFormatter.RoundingMode = .down,
                      stringType: NumberFormatStringType = .generic) -> String {
        return format(minF, maxF: maxF, minI: minI, roundingMode: roundingMode, stringType: .amount)
    }

    func formatKM(_ minF: Int = 2, 
                  maxF: Int = kNumberFormatDecimalLengthMax,
                  minI: Int = 1,
                  roundingMode: NumberFormatter.RoundingMode = .down) -> String {
        return self > 1000000000 ? (self / 1000000000).format(2, maxF: 2, minI: minI,roundingMode: roundingMode) + "Bn"
            : self > 1000000 ? (self / 1000000).format(2, maxF: 2, minI: minI,roundingMode: roundingMode) + "M"
            : self > 1000 ? (self / 1000).format(2, maxF: 2, minI: minI,roundingMode: roundingMode) + "K"
            : self.format(minF, maxF: maxF, minI: minI,roundingMode: roundingMode)
    }
    
    func formatK(_ minF: Int = 2, 
                 maxF: Int = kNumberFormatDecimalLengthMax,
                 minI: Int = 1,
                 roundingMode: NumberFormatter.RoundingMode = .down) -> String {
        return self >= 10000 ? (self / 1000).format(minF, maxF: maxF, minI: minI,roundingMode: roundingMode) + "K"
            : self.format(minF, maxF: maxF, minI: minI,roundingMode: roundingMode)
    }
}
