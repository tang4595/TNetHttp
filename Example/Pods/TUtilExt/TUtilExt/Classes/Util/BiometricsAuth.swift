//
//  BiometricsAuth.swift
//  TUtilExt
//
//  Created by tang on 14.1.23.
//

import Foundation
import LocalAuthentication

public class BiometricsAuth {
    
    public enum AuthResult {
        case failure ,cancel ,success ,authFailed, userFallback
    }

    public class func auth(_ reason: String, 
                           fallBackTitle: String = "Password",
                           completeClosure: ((AuthResult) -> Void)?) -> Void {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error = error as? LAError, (error.code == .biometryLockout || error.code == .authenticationFailed) {
                completeClosure?(.authFailed)
                return
            }
            completeClosure?(.failure)
            return
        }
        
        context.localizedFallbackTitle = fallBackTitle
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
            DispatchQueue.main.sync {
                if success {
                    completeClosure?(.success)
                    return
                }

                guard let code = error as? LAError else {
                    completeClosure?(.authFailed)
                    return
                }
                switch code.code {
                case LAError.Code.systemCancel, .userCancel:
                    completeClosure?(.cancel)
                case .authenticationFailed, .biometryLockout:
                    completeClosure?(.authFailed)
                case LAError.Code.userFallback:
                    completeClosure?(.userFallback)
                default:
                    completeClosure?(.failure)
                }
            }
        }
    }

    public static func supportBiometricsAuth() -> Bool {
        var error: NSError?
        guard LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error = error as? LAError, (error.code == .biometryLockout || error.code == .authenticationFailed) {
                return true
            }
            return false
        }
        return true
    }

    public static func isFaceID() -> Bool {
        if #available(iOS 11, *) {
            let context = LAContext()
            guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
                return false
            }
            return context.biometryType == .faceID
        }
        return false
    }
}
