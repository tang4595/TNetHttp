//
//  ApiPlugins.swift
//  Gallery
//
//  Created by tang on 21.7.21.
//

import Foundation
import Moya
import SwiftyJSON
import TAppBase
import TUtilExt

struct ApiCredentialPlugin: PluginType {
    
    var netKeys: TNetKeys?
    
    func withConfig(netKeys: TNetKeys) -> Self {
        var instance = self
        instance.netKeys = netKeys
        return instance
    }
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard request.method == .post, let netKeys = netKeys else {
            return request
        }
        guard
            let encedBodyData: Data = netKeys.shouldAesEncrypt ? request.httpBody?.aesEncoded(EncryptorKeyPair.api) : request.httpBody,
            let sig: String = encedBodyData.aesEncoded(EncryptorKeyPair.api)
        else {
            return request
        }
        var req = request
        req.httpBody = encedBodyData
        req.addValue(sig.md5(), forHTTPHeaderField: netKeys.apiKeySignature)
        return req
    }
}

struct ApiResponseUnwrapPlugin: PluginType {
    
    var netKeys: TNetKeys?
    
    func withConfig(netKeys: TNetKeys) -> Self {
        var instance = self
        instance.netKeys = netKeys
        return instance
    }
    
    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        switch result {
        case let .success(response):
            guard
                let netKeys = netKeys,
                let json = try? JSON(data: response.data),
                let dataJsonStr = json.toJSONString(),
                let plainJsonStr: String = netKeys.shouldAesEncrypt ? dataJsonStr.aesDecoded(EncryptorKeyPair.api) : dataJsonStr,
                let plainJsonData = plainJsonStr.data(using: .utf8)
            else {
                return result
            }
            return .success(Moya.Response(
                statusCode: response.statusCode,
                data: plainJsonData,
                request: response.request,
                response: response.response
            ))
        default:
            return result
        }
    }
}
