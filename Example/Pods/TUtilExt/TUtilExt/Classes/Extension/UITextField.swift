//
//  UITextField.swift
//  TUtilExt
//
//  Created by tang on 19.10.22.
//

import UIKit

fileprivate var kStorageKeyMaxLength: Void?
fileprivate var kStorageKeyDoubleCountChinese: Void?
fileprivate var kStorageKeyObserver: Void?

public class AppTextField: UITextField {
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

public extension AppTextField {
    
    var maxLength: Int? {
        get { objc_getAssociatedObject(self, &kStorageKeyMaxLength) as? Int }
        set {
            addObserve()
            objc_setAssociatedObject(self, &kStorageKeyMaxLength, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var doubleCountChinese: Bool? {
        get { objc_getAssociatedObject(self, &kStorageKeyDoubleCountChinese) as? Bool }
        set { objc_setAssociatedObject(self, &kStorageKeyDoubleCountChinese, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func addObserve() {
        guard objc_getAssociatedObject(self, &kStorageKeyObserver) == nil else {
            return
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textFieldEditChanged(notification:)),
            name: UITextField.textDidChangeNotification,
            object: self
        )
    }
    
    @objc func textFieldEditChanged(notification: NSNotification) {
        if doubleCountChinese ?? false {
            
        } else {
            guard let text = self.text else {return}
            let maxLen = maxLength ?? 999999999
            if maxLen > 0 && text.count > maxLen {
                if let _ = markedTextRange {
                    return
                }
                let range = text.rangeOfComposedCharacterSequence(at: text.index(text.startIndex, offsetBy: maxLen))
                self.text = String(text[text.startIndex..<range.lowerBound])
            }
        }
    }
}
