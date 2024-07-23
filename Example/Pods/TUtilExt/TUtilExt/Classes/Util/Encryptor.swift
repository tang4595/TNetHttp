//
//  Encryptor.swift
//  Gallery
//
//  Created by tang on 15.7.21.
//

import Foundation
import CryptoSwift

public struct EncryptorKeyPair {
    
    public struct ECKeyPair {
        var aesKey: String
        var aesIv: String
        
        public init(aesKey: String, aesIv: String) {
            self.aesKey = aesKey
            self.aesIv = aesIv
        }
    }
    
    public static var api: ECKeyPair = .apiDefault
    public static var local: ECKeyPair = .localDefault
}

private extension EncryptorKeyPair.ECKeyPair {
    static var apiDefault: Self = .init(aesKey: "a[-f..^xAha_L1-.", aesIv: "_a6]/-a`j-.|yunb")
    static var localDefault: Self = .init(aesKey: "a[,c.?^RDhn_T6-1", aesIv: "-A1]-/r`er.|jkfa")
}

public extension String {
    
    func toBase64() -> Data? {
        return self.data(using: .utf8)?.base64EncodedData()
    }
    
    func toBase64() -> String? {
        return self.data(using: .utf8)?.base64EncodedString()
    }
    
    func fromBase64() -> Data? {
        return Data(base64Encoded: self)
    }
    
    func fromBase64() -> String? {
        guard let data: Data = self.fromBase64() else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    func aesEncoded(_ keyPair: EncryptorKeyPair.ECKeyPair) -> String? {
        do {
            let aes = try AES(key: keyPair.aesKey, iv: keyPair.aesIv)
            let ret = try aes.encrypt(Array(self.utf8))
            return Data(ret).base64EncodedString()
        } catch {
            logError(content: error.localizedDescription)
            return nil
        }
    }
    
    func aesEncoded(_ keyPair: EncryptorKeyPair.ECKeyPair) -> Data? {
        let ret: String? = self.aesEncoded(keyPair)
        return ret?.data(using: .utf8)
    }
    
    func aesDecoded(_ keyPair: EncryptorKeyPair.ECKeyPair) -> Data? {
        do {
            let aes = try AES(key: keyPair.aesKey, iv: keyPair.aesIv)
            guard let data: Data = self.fromBase64() else {
                return nil
            }
            let ret = try aes.decrypt(Array(data))
            return Data(ret)
        } catch {
            logError(content: error.localizedDescription)
            return nil
        }
    }
    
    func aesDecoded(_ keyPair: EncryptorKeyPair.ECKeyPair) -> String? {
        guard let ret: Data = self.aesDecoded(keyPair) else {
            return nil
        }
        return String(data: ret, encoding: .utf8)
    }
}

public extension Data {
    
    func aesEncoded(_ keyPair: EncryptorKeyPair.ECKeyPair) -> String? {
        do {
            let aes = try AES(key: keyPair.aesKey, iv: keyPair.aesIv)
            let ret = try aes.encrypt(self.bytes)
            return Data(ret).base64EncodedString()
        } catch {
            logError(content: error.localizedDescription)
            return nil
        }
    }
    
    func aesEncoded(_ keyPair: EncryptorKeyPair.ECKeyPair) -> Data? {
        let ret: String? = self.aesEncoded(keyPair)
        return ret?.data(using: .utf8)
    }
    
    func aesDecoded(_ keyPair: EncryptorKeyPair.ECKeyPair) -> Data? {
        do {
            let aes = try AES(key: keyPair.aesKey, iv: keyPair.aesIv)
            let ret = try aes.decrypt(Array((String(data: self, encoding: .utf8) ?? "").utf8))
            return Data(ret)
        } catch {
            logError(content: error.localizedDescription)
            return nil
        }
    }
    
    func aesDecoded(_ keyPair: EncryptorKeyPair.ECKeyPair) -> String? {
        guard let ret: Data = self.aesDecoded(keyPair) else {
            return nil
        }
        return String(data: ret, encoding: .utf8)
    }
}
