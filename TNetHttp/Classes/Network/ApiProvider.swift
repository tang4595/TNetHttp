//
//  ApiProvider.swift
//  Gallery
//
//  Created by tang on 15.7.21.
//

import Foundation
import Alamofire
import Moya
import SwiftyJSON
import RxSwift
import TAppBase
import TUtilExt
import SwifterSwift

// TODO: 缓存
public let sessionManager: Alamofire.Session = {
    let manager = Alamofire.Session(
        configuration: URLSessionConfiguration.default,
        delegate: SessionDelegate(),
        startRequestsImmediately: false,
        serverTrustManager: nil
    )
    manager.session.configuration.timeoutIntervalForRequest = 60
    manager.session.configuration.httpShouldSetCookies = true
    return manager
}()

fileprivate let credentialPlugin = ApiCredentialPlugin()
fileprivate let responseUnwrapPlugin = ApiResponseUnwrapPlugin()

public class ApiProvider<T: TargetType>: MoyaProvider<T> {
    
    public var netKeys: TNetKeys?
    
    private var cancelTokens: [Moya.Cancellable] = []
    
    func addToken(_ token: Moya.Cancellable) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        cancelTokens.append(token)
    }
    
    deinit {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        cancelTokens.forEach { $0.cancel() }
    }
    
    public convenience init(
        endpointClosure: @escaping MoyaProvider<T>.EndpointClosure = MoyaProvider.defaultEndpointMapping,
        requestClosure: @escaping MoyaProvider<T>.RequestClosure = MoyaProvider<T>.defaultRequestMapping,
        stubClosure: @escaping MoyaProvider<T>.StubClosure = MoyaProvider.neverStub,
        callbackQueue: DispatchQueue? = nil,
        session: Session = sessionManager,
        plugins: [PluginType] = [],
        trackInflights: Bool = false,
        netKeys: TNetKeys
    ) {
        /// Customizing plugins.
        var newPlugins = plugins
        /// Plugin - Credentials.
        newPlugins.append(credentialPlugin.withConfig(netKeys: netKeys))
        /// Plugin - Response unwrap.
        newPlugins.append(responseUnwrapPlugin.withConfig(netKeys: netKeys))
        /// Plugin -  Network indicator.
        newPlugins.append(
            NetworkActivityPlugin(networkActivityClosure: { (changeType, _) in
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = changeType == .began
                }
            })
        )
        /// Plugin - Logger.
        if enableApiLog {
            let requestLogFormatter = { (data: Data) -> String in
                let ret = try? JSON(data: data).string
                return ret ?? ""
            }
            let responseLogFormatter = { (data: Data) -> String in
                guard let ret = try? JSON(data: data) else {
                    return ""
                }
                guard !netKeys.apiRespKeyData.isEmpty else {
                    return ret.toJSONString() ?? "--"
                }
                let respData = ret[netKeys.apiRespKeyData].toJSONString() ?? "--"
                return respData
            }
            newPlugins.append(
                NetworkLoggerPlugin(configuration: NetworkLoggerPlugin.Configuration(
                    formatter: NetworkLoggerPlugin.Configuration.Formatter(
                        requestData: requestLogFormatter,
                        responseData: responseLogFormatter
                    ),
                    logOptions: .verbose
                ))
            )
        }
        
        self.init(endpointClosure: endpointClosure,
                   requestClosure: requestClosure,
                   stubClosure: stubClosure,
                   callbackQueue: callbackQueue,
                   session: session,
                   plugins: newPlugins,
                   trackInflights: trackInflights)
        self.netKeys = netKeys
    }
    
    public func request(
        _ target: T,
        showError: Bool = true,
        whitelistOfErrorCode: [Int] = [],
        callbackQueue: DispatchQueue? = .none,
        progress: ProgressBlock? = .none
    ) -> Observable<JSON> {
        guard let netKeys = netKeys else {
            return .just([:])
        }
        return Observable<JSON>.create { [weak self] ob -> Disposable in
            guard let self = self else {
                return Disposables.create()
            }
            
            let completion: Completion = { (result) in
                switch result {
                case let .success(response):
                    guard let plainJson = try? JSON(data: response.data) else {
                        ob.onError(AppError.NetError(ApiDecryptError(data: response)))
                        break
                    }
                    
                    /// Response code validation.
                    guard !netKeys.apiRespCodeSuccess.isEmpty else {
                        ob.onNext(plainJson)
                        ob.onCompleted()
                        break
                    }
                    let respCode = plainJson[netKeys.apiRespKeyCode].intValue
                    guard netKeys.apiRespCodeSuccess == "\(respCode)" else {
                        let msg = plainJson[netKeys.apiRespKeyMsg].stringValue
                        if showError {
                            if msg.isEmpty {
                                Toast.error("Error with response code: \(respCode)")
                            } else {
                                Toast.error(msg)
                            }
                        } else {
                            ob.onError(AppError.NetError.failure(
                                message: msg,
                                code: respCode,
                                data: plainJson
                            ))
                        }
                        break
                    }
                    ob.onNext(plainJson)
                    ob.onCompleted()
                case let .failure(error):
                    ob.onError(AppError.NetError.failure(
                        message: error.failureReason,
                        code: error.errorCode,
                        data: error.response
                    ))
                    break
                }
            }
            
            let cancelToken = self.request(
                target,
                callbackQueue: callbackQueue,
                progress: progress,
                completion: completion)
            
            self.cancelTokens.append(cancelToken)
            return Disposables.create()
        }
    }
}
