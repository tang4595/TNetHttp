//
//  Date.swift
//  TUtilExt
//
//  Created by tang on 2023/9/14.
//

import Foundation
import TAppBase

extension Date {
    
    enum Formatter: String {
        case YEAR               = "yyyy"
        case MONTH              = "MM"
        case DAY                = "dd"
        case WEEK               = "EEE"
        case HOUR_FORMAT_24     = "HH"
        case HOUR_FORMAT_12     = "hh"
        case MINUTE             = "mm"
        case SECOND             = "ss"
        case MILLISECOND        = "SSS"
        case YYYY_MM            = "yyyy-MM"
        case YYYYMMdd           = "yyyyMMdd"
        case YYYY_MM_dd         = "yyyy-MM-dd"
        case MM_dd_HH_mm        = "MM-dd HH:mm"
        case YYYY_MM_dd_HH_mm   = "yyyy-MM-dd HH:mm"
        case FULL_DATE          = "yyyy-MM-dd HH:mm:ss"
        case ISO_DATE           = "yyyy-MM-dd'T'HH:mm:ss.SSS"

        func string(from date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = rawValue
            return dateFormatter.string(from: date)
        }
    }
}

extension Date {
    
    func format(_ formatter: Formatter) -> String {
        formatter.string(from: self)
    }
}

extension Date {
    
    func convertGMTToCurrentZone() -> Date {
        return convertToTimeZone(initTimeZone: TimeZone(identifier: "GMT") ?? TimeZone.current, timeZone: TimeZone.current)
    }

    func diffOfGMTBetweenCurrentZone() -> Int64 {
        Int64(diffOfTimeZone(initTimeZone: TimeZone(identifier: "GMT") ?? TimeZone.current, timeZone: TimeZone.current).rounded())
    }

    private func convertToTimeZone(initTimeZone: TimeZone, timeZone: TimeZone) -> Date {
        return addingTimeInterval(diffOfTimeZone(initTimeZone: initTimeZone, timeZone: timeZone))
    }

    private func diffOfTimeZone(initTimeZone: TimeZone, timeZone: TimeZone) -> TimeInterval {
         return TimeInterval(timeZone.secondsFromGMT(for: self) - initTimeZone.secondsFromGMT(for: self))
    }
}

extension Date {
    
    static var secondsSince1970: Int64 {
        Int64((Date().timeIntervalSince1970).rounded())
    }

    static var millisecondsSince1970: Int64 {
        Int64((Date().timeIntervalSince1970 * 1000.0).rounded())
    }

    var secondsSince1970: Int64 {
        Int64((timeIntervalSince1970).rounded())
    }

    var millisecondsSince1970: Int64 {
        Int64((timeIntervalSince1970 * 1000.0).rounded())
    }

    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }

    init(seconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(seconds))
    }
}
