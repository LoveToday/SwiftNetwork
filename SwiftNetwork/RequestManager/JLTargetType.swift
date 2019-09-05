//
//  JLTargetType.swift
//  SwiftNetwork
//
//  Created by ChenJiangLin on 2019/9/5.
//  Copyright © 2019 ChenJiangLin. All rights reserved.
//

import Foundation
import Moya

public protocol JLTargetType:TargetType{
    
    var parameters: [String: Any]?{ get }
}

public extension JLTargetType {
    
    var baseURL: URL {
        return URL(string: RD_Request_BaseURL)!
    }
    
    var headers: [String: String]? {
        return RequestApi.configRequestRequestHeader(paramter: self.parameters)
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        return .requestParameters(parameters: parameters ?? [:], encoding: URLEncoding.default)
    }
    
    var sampleData: Data {
        return "{\"code\"ok\",\"data\": {}}".data(using: .utf8)!
    }
}

