//
//  String.swift
//  TUtilExt
//
//  Created by tang on 12.10.22.
//

import UIKit
import TAppBase

public extension String {
    
    func sizeWithConstrained(
        _ font: UIFont,
        constraintRect: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
    ) -> CGSize {
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
        return CGSize.init(width: boundingBox.size.width + 5.0, height: boundingBox.size.height)
    }

    func isEmail() -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
        return predicate.evaluate(with: self)
    }

    func isChinese() -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^[\\u4E00-\\u9FA5]+$")
        return predicate.evaluate(with: self)
    }
    
    func isIncludeChinese() -> Bool {
        for (_, value) in self.enumerated() {
            if ("\u{4E00}" <= value  && value <= "\u{9FA5}") {
                return true
            }
        }
        return false
    }

    func isDigital() -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^[0-9]+(.[0-9]{1,8})?$")
        return predicate.evaluate(with: self)
    }

    func isMobile() -> Bool {
        guard self.count > 1 else {
            return false
        }
        let regular = "^[0-9]*([0-9])?$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regular)
        return predicate.evaluate(with: self)
    }
    
    func xxxString() -> String {
        return self.xxxString(front:3, behind:1)
    }
    
    func xxxString(front: Int, behind: Int) -> String {
        if self.count < front + behind {
            return self
        }
        let range = NSRange(location: front, length: self.count-front-behind)
        return (self.nsString).replacingCharacters(in: range, with: String(repeating: "*", count: range.length))
    }

    func xxxMailString() -> String {
        
        func hideMidChars(s: String) -> String {
            guard s.count > 4 else {
                return s
            }
            return String(self.enumerated().map { index, char in
               return [0, 1, 2, s.count - 1].contains(index) ? char : "*"
            })
        }
        
        let components = self.components(separatedBy: "@")
        guard components.count > 1 else {
            return self
        }
        let result = hideMidChars(s: components.first!) + "@" + components.last!
        return result
    }

    static func isNotBlank(_ string: Any?) -> Bool {
        guard let value = string as? String else {
            return false
        }
        return value.count > 0
    }

    static func isBlank(_ string: Any?) -> Bool {
        return !isNotBlank(string)
    }

    static func isBankCard(_ string: Any?) -> Bool {
        guard let value = string as? String else {
            return false
        }
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^[0-9]{2,20}$")
        return predicate.evaluate(with: value)
    }

    func number() -> NSNumber {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 8
        formatter.minimumFractionDigits = 0
        formatter.roundingMode = .floor
        formatter.locale = Locale(identifier: "en_US")
        return (formatter.number(from: self) ?? 0)
    }
    
    var decimal: Decimal {
        return Decimal(string: self, locale: .current) ?? 0
    }
    
    var decimalNumber: NSDecimalNumber {
        return NSDecimalNumber(string: self)
    }
    
    func subString(start: Int, length: Int = -1) -> String {
        if self == "" {
            return ""
        }
        if self.count < (start + length) {
            return self
        }
        var len = length
        if len == -1 {
            len = self.count - start
        }
        let st = self.index(startIndex, offsetBy:start)
        let en = self.index(st, offsetBy:len)
        return String(self[st ..< en])
    }

    func digits() -> Int {
        let array = self.components(separatedBy: ".")
        if array.count == 2 {
            return array.last?.count ?? 0
        }
        return 0
    }
    
    func timemsFormeted(format: String? ) -> String {
        guard let timeInterval = self.int else { return "" }
        let date = Date.init(timeIntervalSince1970: TimeInterval(timeInterval/1000))
        let formatter = DateFormatter()
        formatter.dateFormat = format ?? "yyyy-MM-dd HH:mm:ss"
        let timeStr = formatter.string(from: date)
        return timeStr
    }
    
    func precision() -> Int {
        if self.contains(".") {
            let separatedArray = self.components(separatedBy: ".")
            let numberStr = separatedArray.last
            return numberStr?.count ?? 0
        }else{
            return -self.count
        }
    }
    
    func disableEmoji() -> String {
        if self == "➊" || self == "➋" || self == "➌" || self == "➍" || self == "➎" || self == "➏" || self == "➐" || self == "➑" || self == "➒" {
            return self
        }
        let regex = try!NSRegularExpression.init(pattern: "[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]", options: .caseInsensitive)
        
        let modifiedString = regex.stringByReplacingMatches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange.init(location: 0, length: self.count), withTemplate: "")
        return modifiedString
    }

    func attributed() -> NSMutableAttributedString {
        return NSMutableAttributedString.init(string: self)
    }
    
    var asQrCode: UIImage? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    var containsLetter: Bool {
        let contains = self.rangeOfCharacter(from: NSCharacterSet.letters)
        return contains != nil
    }
    
    var containsNumber: Bool {
        let contains = self.rangeOfCharacter(from: NSCharacterSet.decimalDigits)
        return contains != nil
    }
}

public extension NSAttributedString {
    
    static func attributed(_ attributeds: [(String ,UIFont, UIColor)]) -> NSAttributedString {
        let attr = NSMutableAttributedString()
        attributeds.forEach { (arg0) in
            let (value, font, color) = arg0
            attr.append(
                NSAttributedString(
                    string: value,
                    attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color]
                )
            )
        }
        return attr
    }
    
    fileprivate func applying(attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        let copy = NSMutableAttributedString(attributedString: self)
        let range = (string as NSString).range(of: string)
        copy.addAttributes(attributes, range: range)
        return copy
    }
    
    func underline(style: NSUnderlineStyle) -> NSAttributedString {
        return applying(attributes: [.underlineStyle: style.union(NSUnderlineStyle.single).rawValue])
    }
}

public extension NSMutableAttributedString {
    
    func lineSpacing(spacing: CGFloat, toRangesMatching pattern: String) -> NSMutableAttributedString {
        guard let pattern = try? NSRegularExpression(pattern: pattern, options: []) else { return self }
        let matches = pattern.matches(in: string, options: [], range: NSRange(0..<length))
        var attr = self
        for match in matches {
            attr = self.lineSpacing(spacing: spacing, range: match.range)
        }
        return attr
    }

    func lineSpacing(spacing: CGFloat, range: NSRange? = nil) -> NSMutableAttributedString {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = spacing
        style.alignment = .left
        if range != nil {
            self.addAttributes([.paragraphStyle: style], range: range!)
        } else {
            self.addAttributes([.paragraphStyle: style], range: NSMakeRange(0, self.string.count))
        }
        return self
    }

    func font(font: UIFont, toRangesMatching pattern: String) -> NSMutableAttributedString {
        guard let pattern = try? NSRegularExpression(pattern: pattern, options: []) else { return self }
        let matches = pattern.matches(in: self.string, options: [], range: NSRange(0..<length))
        var attr = self
        for match in matches {
            attr = self.font(font: font, range: match.range)
        }
        return attr
    }

    func font(font: UIFont, range: NSRange? = nil) -> NSMutableAttributedString {
        if range != nil {
            self.addAttributes([.font:font], range: range!)
        } else {
            self.addAttributes([.font:font], range: NSMakeRange(0, self.string.count))
        }

        return self
    }

    func foregroundColor(color: UIColor, toRangesMatching pattern: String) -> NSMutableAttributedString {
        if string.isEmpty {
            return self
        }
        guard let pattern = try? NSRegularExpression(pattern: pattern, options: []) else { return self }

        let matches = pattern.matches(in: string, options: [], range: NSRange(0..<length))
        var attr = self
        for match in matches {
            attr = self.foregroundColor(color: color, range: match.range)
        }
        return attr
    }


    func foregroundColor(color: UIColor, range: NSRange? = nil) -> NSMutableAttributedString {
        if range != nil {
            self.addAttributes([.foregroundColor: color], range: range!)
        } else {
            self.addAttributes([.foregroundColor: color], range: NSMakeRange(0, self.string.count))
        }
        return self
    }
    
    func textAligment(aligment: NSTextAlignment)  -> NSMutableAttributedString  {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = aligment
        self.addAttributes([.paragraphStyle :paragraph], range: NSMakeRange(0, self.string.count))
        return self
    }

    func addAttribute(_ name: NSAttributedString.Key, value: Any, toRangesMatching pattern: String) -> NSMutableAttributedString {
        guard let pattern = try? NSRegularExpression(pattern: pattern, options: []) else { return self }
        let matches = pattern.matches(in: string, options: [], range: NSRange(0..<length))
        var attr = self
        for match in matches {
            attr = self.addAttribute(name, value: value, range: match.range)
        }
        return attr
    }

    func addAttribute(_ name: NSAttributedString.Key, value: Any, range: NSRange? = nil) -> NSMutableAttributedString {
        if range != nil{
            self.addAttributes([name:value], range: range!)
        } else {
            self.addAttributes([name:value], range: NSMakeRange(0, self.string.count))
        }
        return self
    }

    func append(attr: NSAttributedString) -> NSMutableAttributedString {
        self.append(attr)
        return self
    }
}

extension Array where Iterator.Element == String {
    
    func listAttributedString(font: UIFont,
                              bullet: String = "\u{2022}",
                              indentation: CGFloat = 20,
                              lineSpacing: CGFloat = 6,
                              paragraphSpacing: CGFloat = 0,
                              textColor: UIColor = UIColor.black,
                              bulletColor: UIColor = UIColor.black) -> NSAttributedString {
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor]
        let bulletAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: bulletColor]

        let paragraphStyle = NSMutableParagraphStyle()
        let nonOptions = [NSTextTab.OptionKey: Any]()
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: indentation, options: nonOptions)]
        paragraphStyle.defaultTabInterval = indentation
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = paragraphSpacing
        paragraphStyle.headIndent = indentation

        let bulletList = NSMutableAttributedString()
        for (idx, string) in self.enumerated() {
            let formattedString = "\(bullet)\t\(string)" + (idx == self.endIndex-1 ? "" : "\n")
            let attributedString = NSMutableAttributedString(string: formattedString)
            attributedString.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: attributedString.length))
            attributedString.addAttributes(textAttributes, range: NSRange(location: 0, length: attributedString.length))

            let string: NSString = NSString(string: formattedString)
            let rangeForBullet: NSRange = string.range(of: bullet)
            attributedString.addAttributes(bulletAttributes, range: rangeForBullet)
            bulletList.append(attributedString)
        }
        return bulletList
    }
}

extension Array where Iterator.Element == NSAttributedString {
    
    func listAttributedString(bullet: String = "\u{2022}",
                              indentation: CGFloat = 20,
                              lineSpacing: CGFloat = 8,
                              paragraphSpacing: CGFloat = 0,
                              bulletColor: UIColor = UIColor.black) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        let nonOptions = [NSTextTab.OptionKey: Any]()
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: indentation, options: nonOptions)]
        paragraphStyle.defaultTabInterval = indentation
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = paragraphSpacing
        paragraphStyle.headIndent = indentation

        let bullet = NSAttributedString(string: "\(bullet)\t", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: bulletColor])
        let sep = NSAttributedString(string: "\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.paragraphStyle : paragraphStyle])

        let exceptLast = self[..<endIndex]
        let doneExceptLast = exceptLast.map {
            let attributedString = NSMutableAttributedString(attributedString: bullet)
            attributedString.append($0)
            attributedString.addAttributes([NSAttributedString.Key.paragraphStyle : paragraphStyle], range: NSMakeRange(0, attributedString.length))
            attributedString.append(sep)
            return attributedString
        }

        let lastOne = NSMutableAttributedString(attributedString: bullet)
        lastOne.append(self[endIndex])
        lastOne.addAttributes([NSAttributedString.Key.paragraphStyle : paragraphStyle], range: NSMakeRange(0, self[endIndex].length))

        let all = doneExceptLast + [lastOne]
        let bulletList = all.reduce(NSMutableAttributedString()) { partialResult, attr in
            partialResult.append(attr)
            return partialResult
        }
        return bulletList
    }
}
