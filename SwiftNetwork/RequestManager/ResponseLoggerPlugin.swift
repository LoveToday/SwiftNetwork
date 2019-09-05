//
//  ResponseLoggerPlugin.swift
//  SwiftNetwork
//
//  Created by ChenJiangLin on 2019/9/5.
//  Copyright © 2019 ChenJiangLin. All rights reserved.
//

import UIKit
import Foundation
import Moya
import HandyJSON
import Alamofire
import RxSwift
import enum Result.Result

class ExceptionRequest: NSObject, HandyJSON {
    var requestHeaders: [String : String]!
    var requestBody: String!
    var url: String!
    override required init() {}
    
    public static func == (lhs: ExceptionRequest, rhs: ExceptionRequest) -> Bool {
        return lhs.requestHeaders == rhs.requestHeaders
            && lhs.requestBody == rhs.requestBody && lhs.url == rhs.url
    }
    
}
class ExceptionError: NSObject, HandyJSON {
    var requestHeaders: [String : String]?
    var requestBody: String!
    var url: String!
    var response: String!
    override required init() {}
    
    public static func == (lhs: ExceptionError, rhs: ExceptionError) -> Bool {
        return lhs.requestHeaders == rhs.requestHeaders
            && lhs.response == rhs.response && lhs.requestBody == rhs.requestBody && lhs.url == rhs.url
    }
}

/// Logs network activity (outgoing requests and incoming responses).
public final class ResponseLoggerPlugin: PluginType {
    
    ///特定接口是否上传
    public var isUploadExcetion: Bool = false
    
    //exception request
    var exceptionRequest: ExceptionRequest?
    
    /// Initializes a NetworkLoggerPlugin.
    init(){ }
    
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        isUploadExcetion = true
        //过滤掉特定的接口
        if  target.path == "/error/log" {
            self.exceptionRequest = nil
            isUploadExcetion = false
        }
        guard let vptarget = target as? JLTargetType else {
            self.exceptionRequest = nil
            isUploadExcetion = false
            return
        }
        self.exceptionRequest = handleRequestHeaderAndBody(with: vptarget)
        
        guard isUploadExcetion else {
            return
        }
        
        guard let _ = self.exceptionRequest else {
            return
        }
        responseResultHandler(result, target)
    }
}

fileprivate extension ResponseLoggerPlugin {
    
    //获取response 分析数据，判断是否需要上传
    //1. success && response不是正确的json 2. request failure
    func responseResultHandler(_ result: Result<Moya.Response, MoyaError>, _ target: TargetType) {
        guard isUploadExcetion else {
            return
        }
        guard let exceptionRequest = self.exceptionRequest else {
            return
        }
        let exceptionerror = ExceptionError.init()
        exceptionerror.requestBody = exceptionRequest.requestBody
        exceptionerror.requestHeaders = exceptionRequest.requestHeaders
        exceptionerror.url = exceptionRequest.url
        
        switch result {
        case .success(let response):
            guard response.isValidJSON() else {
                let response = (try? response.mapString()) ?? ""
                //                error.request = exceptionRequest
                exceptionerror.response = response
                return
            }
        case .failure(let error):
            
            //过滤没有网络的错误
            if !(NetworkReachabilityManager()?.isReachable ?? false) {
                return
            }else{
                let code = (error as NSError).code
                //一种是弱网状态 -1001
                //取消网络请求，不管是主动取消还是异常取消都是 -999
                if code == -1001 || code == -999   {
                    return
                }
            }
            if let response = error.response, let mapjson = try? response.mapString(), !mapjson.isEmpty {
                exceptionerror.response = mapjson
            }else{
                exceptionerror.response = result.description
            }
        }
        
    }
    //解析 request 中headers和request body
    func handleRequestHeaderAndBody(with: JLTargetType) -> ExceptionRequest?{
        guard isUploadExcetion else {
            return nil
        }
        let exceptionRequest = ExceptionRequest.init()
        exceptionRequest.url =  RD_Request_BaseURL + with.path
        exceptionRequest.requestBody = ""
        //字典问题，如果字典中有枚举类型，用JSONSerialization.data转换成string过程中崩溃
//        if let body = with.parameters, let stringOutput = body.translateKeyValueStr(){
//            exceptionRequest.requestBody = stringOutput
//        }
        //字典问题，如果字典中有枚举类型，用JSONSerialization.data转换成string过程中崩溃
        //        if let body = with.parameters, let stringOutput = body.jsonString(){
        //            exceptionRequest.requestBody = stringOutput
        //        }
        exceptionRequest.requestHeaders = with.headers
        return exceptionRequest
    }
}


extension Response{
    
    
    //是不是正确的json
    func isValidJSON() -> Bool {
        do {
            try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return true
        } catch {
            return false
        }
    }
    
}
