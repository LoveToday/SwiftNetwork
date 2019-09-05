//
//  VPRequestTool.swift
//  SwiftNetwork
//
//  Created by ChenJiangLin on 2019/9/5.
//  Copyright © 2019 ChenJiangLin. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import HandyJSON
import Alamofire
import Cache

extension ObservableType where E == Response {
    
    public func mapBaseModel<T>(_ type: T.Type) -> Observable<MapBaseModel<T>> {
        return flatMap { response -> Observable<MapBaseModel<T>> in
            
            let ele: MapBaseModel<T> = try response.mapBaseModel(T.self)
            return Observable.just(ele)
        }
    }
    
}
private struct AssociatedKeys {
    static var cacheKey = "vaffle-cache-key"
}
extension Response {
    var cacheKey: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.cacheKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.cacheKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    func mapBaseModel<T>(_ type: T.Type) throws -> MapBaseModel<T>{
        
        
        // check http status
        guard -1001 != self.statusCode else {
            throw RxSwiftMoyaError.RXSwiftMoyaNoNetwork
        }
        
        if let _ = self.response {
            guard ((200...209) ~= self.statusCode) else {
                throw RxSwiftMoyaError.RxSwiftMoyaNotSuccessfulHTTP
            }
        }
        
        let jsonString = String.init(data: data, encoding: .utf8)
        // print(jsonString)
        guard let baseModel = JSONDeserializer<MapBaseModel<T>>.deserializeFrom(json: jsonString) else {
            
            throw RxSwiftMoyaError.RxSwiftMoyaCouldNotMakeObjectError
        }
        
        guard baseModel.success else{
            
            throw RxSwiftMoyaError.RxSwiftMoyaBizError(resultCode:baseModel.code,resultMsg:baseModel.message)
        }
        
        return baseModel
        
    }
    
}

extension MoyaProvider {
    
    
    
    /// 先判断有没有网络 新版网络请求 needCache 本次结果是否需要缓存， isCache 本次结果是否要获取缓存
    func tryUserIsOffline(token: Target, cacheKey: String = "", needCache: Bool = false, isCache: Bool = false) -> Observable<Moya.Response> {
        
        return Observable.create { [weak self] observer -> Disposable in
            if isCache {
                if let target = token as? JLTargetType{
                    let urlStr = target.baseURL.absoluteString + target.path
                    let parms = RequestApi.dictionaryToSortString(paramter: target.parameters)
                    let key = RequestApi.configRequestCacheStrKey(paramterStr: parms, url: urlStr)
                    if let cacheModel = CacheManager.default.getSyncCache(key: key), let dataDict = cacheModel?.dataDict, let result = dataDict["cacheKey"], let url = URL(string: urlStr){
                        let customResponse = Response(statusCode: 10000, data: result, request: URLRequest(url: url), response: nil)
                        observer.onNext(customResponse)
                        observer.onCompleted()
                    }
                }
                
            }
            
            if !(NetworkReachabilityManager()?.isReachable ?? false) {
                observer.onError(RxSwiftMoyaError.RXSwiftMoyaNoNetwork)
            }
            let cancellableToken = self?.request(token) { result in
                switch result {
                case let .success(response):
                    
                    if needCache, let target = token as? JLTargetType{
                        let urlStr = target.baseURL.absoluteString + target.path
                        let parms = RequestApi.dictionaryToSortString(paramter: target.parameters)
                        let key = RequestApi.configRequestCacheStrKey(paramterStr: parms, url: urlStr)
                        var model = CacheModel()
                        model.dataDict = ["cacheKey":response.data]
                        CacheManager.default.setObject(model, forKey: key)
                        response.cacheKey = key
                    }
                    
                    observer.onNext(response)
                    observer.onCompleted()
                    
                case let .failure(error):
                    
                    
                    if !NetworkReachabilityManager()!.isReachable {
                        // 没有网络
                        observer.onError(RxSwiftMoyaError.RXSwiftMoyaNoNetwork)
                    }else {
                        if (error as NSError).code == -1001 {
                            observer.onError(RxSwiftMoyaError.RXSwiftMoyaNoNetwork)
                        }else {
                            observer.onError(RxSwiftMoyaError.RxSwiftMoyaNotSuccessfulHTTP)
                        }
                    }
                }
            }
            
            return Disposables.create {
                cancellableToken!.cancel()
            }
        }
    }
}
