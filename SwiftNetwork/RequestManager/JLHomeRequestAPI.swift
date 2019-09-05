//
//  JLHomeRequestAPI.swift
//  SwiftNetwork
//
//  Created by ChenJiangLin on 2019/9/5.
//  Copyright © 2019 ChenJiangLin. All rights reserved.
//

import Foundation

import UIKit
import Moya


let HomeRequestProvider = MoyaProvider<JLHomeRequestAPI>(manager: JLAlamofireManager.sharedManager,plugins: [NetworkLoggerPlugin(verbose: true), ResponseLoggerPlugin()])

public enum JLHomeRequestAPI {
    
    //广告页
    case ads(ratio: String, advert: String?)
    
    
    
}

//首页的
extension JLHomeRequestAPI: JLTargetType {
    
    // The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        
        switch self {
        case .ads:
            return "/ads"
        }
    }
    
    /// The parameters to be incoded in the request.
    public var parameters: [String: Any]? {
        switch self {
        case .ads(ratio: let ratio, advert: let advert):
            if let vert = advert{
                return ["ratio": ratio, "advert": vert]
            }else{
                return ["ratio": ratio]
            }
        }
    }
}

