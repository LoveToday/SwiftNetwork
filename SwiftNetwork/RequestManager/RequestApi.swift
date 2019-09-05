//
//  RequestApi.swift
//  SwiftNetwork
//
//  Created by ChenJiangLin on 2019/9/5.
//  Copyright © 2019 ChenJiangLin. All rights reserved.
//

import Foundation
import Alamofire
import CryptoSwift
class RequestApi: NSObject {
    static let share: RequestApi = RequestApi()
    static func configRequestRequestHeader(paramter: [String: Any]?) -> [String: String]{
        
        var parms: [String: String] = [:]
        parms["device"] = "ios"
        parms["version"] = "3.7.4"
        parms["company"] = "apple"
        parms["serial-number"] = "6722c4e8ddb5c3faced574ed8c5e847c"
        parms["phone-model"] = "iPhone X"
        parms["lang"] = "en"
        parms["token"] = "1D282D3DBFED5F59905D3153E5FAE8F6"
        parms["uuid"] = "03d68089-18f0-4b96-8aca-94b95cd915be"
        parms["timestamp"] = "1567661007"
        parms["system-version"] = "12.3.1"
        return parms
    }
    /// 判断网络
    ///
    /// - Returns: 返回网络状态
    static func checkInternet() -> Bool{
        if let isReachable = NetworkReachabilityManager()?.isReachable {
            return isReachable
        }
        return false
    }
    static func dictionaryToSortString(paramter: [String: Any]?) -> String{
        var commonParameter: [String: Any] = [:]
        //将接口参数添加到字典中
        if let paramter = paramter {
            for (key, value) in paramter {
                commonParameter[key] = value
            }
        }
        //将字典拼接成字符串类似 key=value&key=value
        var components: [(String, Any)] = []
        let sorted = commonParameter.sorted(by: {$0.key < $1.key})
        for (key, value) in sorted {
            components.append((key,value))
        }
        let component = components.map { "\($0)=\($1)" }.joined(separator: "&")
        return component
    }
    static func configRequestCacheStrKey(paramterStr: String?, url: String = RD_Request_BaseURL) -> String{
        var parmString = paramterStr ?? ""
        var login = "151038"
        parmString = parmString + login + url
        return parmString.md5()
    }
}


