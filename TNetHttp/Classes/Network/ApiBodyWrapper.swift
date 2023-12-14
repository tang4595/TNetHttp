//
//  ApiBodyWrapper.swift
//  Gallery
//
//  Created by tang on 15.7.21.
//

import Foundation

public let defaultPage = 1
public let defaultPageSize = 20

public protocol ApiBodyWrapperable {
    var body: ApiBodyType { get }
}

public protocol ApiBodyPageable {
    
    var page: ApiRequestNumber { get }
    var size: ApiRequestNumber { get }
}

public struct ApiRequestBody: ApiBodyWrapperable {
    
    var _data: ApiBodyType
    public var body: ApiBodyType { _data }
    
    public init(_ data: ApiBodyType = ApiBodyType()) {
        _data = data
    }
}

public struct ApiRequestPageableBody: ApiBodyWrapperable & ApiBodyPageable {
    
    var _data: ApiBodyType
    public var body: ApiBodyType { _data }
    
    var _page: ApiRequestNumber
    public var page: ApiRequestNumber { _page }
    
    var _size: ApiRequestNumber
    public var size: ApiRequestNumber { _size }
    
    public init(_ data: ApiBodyType = ApiBodyType(), page: ApiRequestNumber = defaultPage, size: ApiRequestNumber = defaultPageSize) {
        _data = data
        _page = page
        _size = size
    }
}

/** Business Sample Code.
public struct ApiBodyWrapper {
    var _bodyValue: ApiBodyWrapperable
    public var value: ApiBodyType {
        var value: ApiBodyType = [TNetKeys.apiRespKeyData: _bodyValue.body]
        if let body = _bodyValue as? ApiBodyPageable {
            value["page"] = body.page
            value["size"] = body.size
        }
        return value
    }
    
    public init(_ body: ApiBodyWrapperable) {
        _bodyValue = body
    }
}*/
