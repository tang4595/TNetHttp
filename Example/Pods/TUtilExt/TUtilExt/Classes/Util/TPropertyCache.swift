//
//  TPropertyCache.swift
//  Gallery
//
//  Created by tang on 12.7.21.
//

import Foundation
import CryptoSwift

public struct TPropertyCache {
    
    public enum CacheType {
        /// 读写同步
        case userDefaults
        /// 暂未实现
        case db
        /// 读同步，写异步（构造方法入参可支持同步内存写入，文件固定异步）
        case file
    }
    
    public enum EncryptType {
        case none
        case md5
        case base64
        case aes
    }
    
    public static let defaultCacheType: CacheType = .userDefaults
    public static let defaultEncryptType: EncryptType = .none
    
    /// 同时使用内存缓存
    public static let defaultLoadMemory: Bool = false
    /// 文件缓存写操作同步写入内存缓存
    public static let defaultSyncMemoryWrite: Bool = false
    
    fileprivate static let handleQueue = DispatchQueue(label: "tylcache.property", qos: .background)
    fileprivate static let fileCacheDirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("TPropertyCache/")
    
    @propertyWrapper public struct Effect<T> {
        private let type: CacheType
        private let key: String
        private let encrypt: EncryptType
        private let loadMemory: Bool
        private let syncMemoryWrite: Bool
        private let defaultValue: T?
        
        public init(_ type: CacheType = TPropertyCache.defaultCacheType,
                    key: String,
                    encrypt: EncryptType = TPropertyCache.defaultEncryptType,
                    loadMemory: Bool = TPropertyCache.defaultLoadMemory,
                    syncMemoryWrite: Bool = TPropertyCache.defaultSyncMemoryWrite,
                    defaultValue: T? = nil) {
            self.type = type
            self.key = key
            self.encrypt = encrypt
            self.loadMemory = loadMemory
            self.syncMemoryWrite = syncMemoryWrite
            self.defaultValue = defaultValue
        }
        
        public var wrappedValue: T? {
            get {
                switch type {
                case .userDefaults:
                    guard let ret = decryptValueIfNeeded(UserDefaults.standard.object(forKey: key)) else {
                        return defaultValue
                    }
                    return ret as? T ?? defaultValue
                case .db:
                    return defaultValue
                case .file:
                    return readFromFile(withKey: key)
                }
            }
            set {
                switch type {
                case .userDefaults:
                    guard let newValue = newValue else {
                        UserDefaults.standard.removeObject(forKey: key)
                        UserDefaults.standard.synchronize()
                        return
                    }
                    UserDefaults.standard.set(encryptValueIfNeeded(newValue), forKey: key)
                    UserDefaults.standard.synchronize()
                case .db:
                    break
                case .file:
                    saveAsFile(newValue)
                }
            }
        }
    }
}

// MARK: Encrypt

private extension TPropertyCache.Effect {
    
    private func encryptValueIfNeeded(_ original: Any?) -> Any? {
        guard let originalValue = original as? String else {
            return original
        }
        switch encrypt {
        case .md5:
            return originalValue.md5()
        case .base64:
            guard let ret: String = originalValue.toBase64() else {
                return original
            }
            return ret
        case .aes:
            guard let ret: String = originalValue.aesEncoded(EncryptorKeyPair.local) else {
                return original
            }
            return ret
        default:
            return original
        }
    }
    
    private func decryptValueIfNeeded(_ original: Any?) -> Any? {
        guard let originalValue = original as? String else {
            return original
        }
        switch encrypt {
        case .base64:
            guard let ret: String = originalValue.fromBase64() else {
                return original
            }
            return ret
        case .aes:
            guard let ret: String = originalValue.aesDecoded(EncryptorKeyPair.local) else {
                return original
            }
            return ret
        default:
            return original
        }
    }
}

// MARK: File cache

private extension TPropertyCache.Effect {
    
    private func saveAsFile(_ newValue: T?) {
        if loadMemory && syncMemoryWrite {
            let fileName = key.md5()
            saveAsMemory(fileName, value: newValue)
        }
        
        TPropertyCache.handleQueue.async {
            let fileName = key.md5()
            let path = TPropertyCache.fileCacheDirPath.appendingPathComponent(fileName)
            if loadMemory && !syncMemoryWrite {
                saveAsMemory(fileName, value: newValue)
            }
            
            guard let newValue = newValue else {
                try? FileManager.default.removeItem(at: path)
                return
            }
            
            var fileStringValue: String?
            if let value = newValue as? [Codable] {
                guard let cacheDataJson = value.listToJson() else {return}
                fileStringValue = cacheDataJson
            } else if let value = newValue as? Codable {
                guard let cacheDataJson = value.toJSONString() else {return}
                fileStringValue = cacheDataJson
            } else {
                fileStringValue = "\(newValue)"
            }
            
            let encryptedResult = encryptValueIfNeeded(fileStringValue)
            let fileData = (encryptedResult as? String)?.data(using: .utf8)
            guard let fileData = fileData else {
                return
            }
            try? fileData.write(to: path)
        }
    }
    
    private func readFromFile(withKey key: String) -> T? {
        let fileName = key.md5()
        let path = TPropertyCache.fileCacheDirPath.appendingPathComponent(fileName)
        if loadMemory, let mCache = readFromMemory(withKey: fileName) {
            return mCache
        }
        
        if T.self is Decodable.Type {
            if let data = try? Data(contentsOf: path),
               let encryptedDataJson = data.string(encoding: .utf8),
               let dataJson = decryptValueIfNeeded(encryptedDataJson) as? String,
               let ret = (T.self as! Decodable.Type).fromMap(JSONString: dataJson) {
                return ret as? T ?? defaultValue
            }
        }
        
        let data = try? Data(contentsOf: path)
        let encryptedDataStringValue = data?.string(encoding: .utf8)
        let dataStringValue = decryptValueIfNeeded(encryptedDataStringValue)
        return dataStringValue as? T ?? defaultValue
    }
}

// MARK: Memory cache

private extension TPropertyCache.Effect {
    
    private func saveAsMemory(_ key: String, value: T?) {
        TYLPropertyMemoryCache.shared.setValue(key, value: value)
    }
    
    private func readFromMemory(withKey key: String) -> T? {
        guard let cache = TYLPropertyMemoryCache.shared.getValue(key) as? T else {
            return nil
        }
        return cache
    }
}

// MARK:  Container

/** 缓存容器宿主实例必须是引用类型，值类型无法使用let修饰单例从而修改内部值均会重新拷贝实例，多线程下可能存在数据安全问题 */
fileprivate class TYLPropertyMemoryCache {
    
    static let shared = TYLPropertyMemoryCache()
    
    /// 内存缓存容器，不做加解密处理（后期注意OOM）
    fileprivate var memoryCache = [String:Any]()
    private init() {}
    
    public func setValue(_ key: String, value: Any?) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        guard let value = value else {
            memoryCache.removeValue(forKey: key)
            return
        }
        memoryCache[key] = value
    }
    
    public func getValue(_ key: String) -> Any? {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        return memoryCache[key]
    }
}

// MARK: - Config

public extension TPropertyCache {
    
    static func config() {
        debugPrint("TPropertyCache path: \(fileCacheDirPath)")
        guard !FileManager.default.fileExists(atPath: fileCacheDirPath.absoluteString) else {
            return
        }
        try? FileManager.default.createDirectory(at: fileCacheDirPath, withIntermediateDirectories: true, attributes: nil)
    }
}
