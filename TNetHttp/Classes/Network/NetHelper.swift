//
//  TNetHelper.swift
//  Gallery
//
//  Created by tang on 15.7.21.
//

import Foundation
import Moya
import FCUUID
import RxSwift
import RxCocoa
import SwifterSwift
import SwiftyJSON
import TUtilExt
import TAppBase

// MARK: - Global

public typealias JSONType = [String: Any]
public typealias ApiHeaderType = [String: String]
public typealias ApiBodyType = JSONType
public typealias ApiRequestNumber = Int
public typealias ApiTargetType = TargetType
public typealias ApiMethod = Moya.Method
public typealias ApiTask = Moya.Task
public typealias ApiJSONEncoding = Moya.JSONEncoding
public typealias ApiURLEncoding = Moya.URLEncoding
public typealias ApiParameterEncoding = Moya.ParameterEncoding

public class TNetHelper {
    private init() {}
}

public extension ApiTargetType {
    
    var baseURL: URL {
        return URL(string: "http://localhost:8080/didNotImplement")!
    }
    
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    var headers: [String: String]? {
        return nil
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}

public protocol TNetKeys {
    
    /// 配置
    var shouldAesEncrypt: Bool { get set }
    
    /// Api各种Key.
    var apiKeySignature: String { get set }
    var apiRespKeyCode: String { get set }
    var apiRespKeyMsg: String { get set }
    var apiRespKeyData: String { get set }
    
    /// 响应码.
    /// 通用成功.
    var apiRespCodeSuccess: String { get set }
    /// token过期.
    var apiRespCodeTokenExpire: String { get set }
    /// 当前版本小于最低可用版本.
    var apiRespCodeLowVersion: String { get set }
}

public struct ApiListModelWrapper<T> {
    
    public let totalPages: Int
    public let totalElements: Int
    public let currentPage: Int
    public let data: [T]
}

public extension Observable {
    
    func model<T>(_ modelType: T.Type, key: TNetKeys) -> Observable<T> where T: Decodable {
        return self.flatMap { e -> Observable<T> in
            let dataKey = key.apiRespKeyData
            guard
                let json = e as? JSON,
                let model = T.fromMap(JSONObject: (dataKey.isEmpty ? json.dictionaryObject : json[dataKey].dictionaryObject) ?? [:])
            else {
                return .error(AppError.NetError(ApiParseError(data: e)))
            }
            return .just(model)
        }
    }
    
    func listModel<T>(_ modelType: T.Type, key: TNetKeys) -> Observable<ApiListModelWrapper<T>> where T: Decodable {
        return self.flatMap { e -> Observable<ApiListModelWrapper<T>> in
            let dataKey = key.apiRespKeyData
            guard
                let json = e as? JSON,
                let modelsJson = (dataKey.isEmpty ? json : json[dataKey]).array
            else {
                return .error(AppError.NetError(ApiParseError(data: e)))
            }
            let models = modelsJson.compactMap { json -> T? in
                return T.fromMap(JSONObject: json.dictionaryObject ?? [:])
            }
            return .just(ApiListModelWrapper(
                totalPages: json["paginator"]["totalPages"].intValue,
                totalElements: json["paginator"]["totalElements"].intValue,
                currentPage: json["paginator"]["currentPage"].intValue,
                data: models
            ))
        }
    }
}
