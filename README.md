# SwiftNetwork
基于RxSwift的网络请求（网络请求缓存等功能，耦合性比较低）
使用方式
1.RequestURLMacro.swift 文件中设置基本地址 
eg let RD_Request_BaseURL = "https://api.***.com"
2.URL设置：
JLTargetType.swift 中设置自己的 网络请求方式 moya中有对应的path 其网络请求的地址是 baseURL + path的形式  在JLHomeRequestAPI中设置自己的path  eg 本项目中 的path 设的是 “/path”  对应到fullpath是  https://api.***.com/path
3.参数设置：
JLHomeRequestAPI中的
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
   4.header设置
   JLHomeRequestAPI中
   public var headers: [String: String]? {
        return RequestApi.configRequestRequestHeader(paramter: self.parameters)
    }
5.使用：
a.不需要缓存
    HomeRequestProvider.tryUserIsOffline(token: .ads(ratio: "0.5625", advert: "appstart")).mapBaseModel([TestModel].self).subscribe(onNext: {[weak self] (baseModel) in
            guard let `self` = self else { return }
            if let data = baseModel.data{
                /// baseModel的data的类型对应 mapBaseModel([TestModel].self). 中的 [TestModel].self
                /// 可以根据的自己的情况进行配置
            }
            }, onError: {[weak self] (error) in
                guard let `self` = self else { return }
            }, onCompleted: nil, onDisposed: nil).disposed(by: bag) 
     
     
    HomeRequestProvider.tryUserIsOffline(token: .ads(ratio: "0.5625", advert: "appstart")).mapBaseModel([String: Any].self).subscribe(onNext: {[weak self] (baseModel) in
            guard let `self` = self else { return }
            if let data = baseModel.data{
                /// baseModel的data的类型对应 mapBaseModel([String: Any].self). 中的 Any.self
                /// 可以根据的自己的情况进行配置
            }
            }, onError: {[weak self] (error) in
                guard let `self` = self else { return }
            }, onCompleted: nil, onDisposed: nil).disposed(by: bag)
b.需要缓存
//// 可以根据自己的实际情况是否需要缓存以及是否需要取用缓存
var isCache = false
if !(NetworkReachabilityManager()?.isReachable ?? false) {
    isCache = true
}
HomeRequestProvider.tryUserIsOffline(token: .ads(ratio: "0.5625", advert: "appstart"), needCache: true, isCache: isCache).mapBaseModel([String: Any].self).subscribe(onNext: {[weak self] (baseModel) in
    guard let `self` = self else { return }
    if let data = baseModel.data{
        /// baseModel的data的类型对应 mapBaseModel([String: Any].self). 中的 Any.self
        /// 可以根据的自己的情况进行配置
    }
}, onError: {[weak self] (error) in
    guard let `self` = self else { return }
}, onCompleted: nil, onDisposed: nil).disposed(by: bag)
如果有不懂或是觉得需要改进的同学可以留言，一起进步
