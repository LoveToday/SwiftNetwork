//
//  CacheManager.swift
//  MQZHot
//
//  Created by MQZHot on 2017/10/17.
//  Copyright © 2017年 MQZHot. All rights reserved.
//
//  https://github.com/MQZHot/DaisyNet
//
import Foundation
import Cache
import SwiftyUserDefaults
//软件版本号
let RD_CurrentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String

class VPCacheKeys: NSObject, NSCoding {
    var key: String?
    var timeStamp: String?
    var version: String?
    
    override init() {
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(key, forKey: "key")
        aCoder.encode(timeStamp, forKey: "timeStamp")
        aCoder.encode(version, forKey: "version")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.key = aDecoder.decodeObject(forKey: "key") as? String
        self.timeStamp = aDecoder.decodeObject(forKey: "timeStamp") as? String
        self.version = aDecoder.decodeObject(forKey: "version") as? String
    }
    
    
}



struct CacheModel: Codable {
    var data: Data?
    var dataDict: Dictionary<String, Data>?
    init() {
        
    }
}

class CacheManager {
    /// 此时要对缓存的key进行处理
    @objc private func applicationWillTerminate(_ notify: Notification) {
        let source = Defaults[.storeSourceKeys]
        var allKeys = [String]()
        var dupliteKeys = [String]()
        source.reversed().forEach { (model) in
            guard let key = model.key else { return }
            if allKeys.contains(key){
                dupliteKeys.append(key)
            }else{
                allKeys.append(key)
            }
        }
        
        self.keys.forEach { (model) in
            if let index = source.firstIndex(where: {$0.key == model.key}){
                Defaults[.storeSourceKeys][index] = model
            }else{
                Defaults[.storeSourceKeys].append(model)
            }
        }
        dupliteKeys.forEach { (key) in
            Defaults[.storeSourceKeys].removeAll(where: { $0.key == key } )
        }
    }
    
    func checkOverExpairedDate(){
        let system_version = RD_CurrentVersion
        var expairedKeys:[String] = []
        let models = Defaults[.storeSourceKeys]
        models.forEach { (model) in
            let nowTime = Date().timeIntervalSince1970
            let dValue: TimeInterval = 7 * 24 * 60 * 60
            
            if let key = model.key, let timeStamp = model.timeStamp, let resultTime = TimeInterval(timeStamp), nowTime - resultTime >= dValue{
                expairedKeys.append(key)
            }
            if let key = model.key, let version = model.version,  version != system_version{
                expairedKeys.append(key)
            }
        }
        expairedKeys.forEach { (key) in
            self.keys.removeAll(where: {$0.key == key})
            self.removeObjectCache(key, completion: { (finished) in
                
            })
        }
    }
    
    
    
    static let `default` = CacheManager()
    /// Manage storage
    private var storage: Storage<CacheModel>?
    
    private var keys: [VPCacheKeys] = []
    
    /// init
    init() {
        let diskConfig = DiskConfig(name: "DaisyCache")
        let memoryConfig = MemoryConfig(expiry: .never)
        do {
            storage = try Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forCodable(ofType: CacheModel.self))
        } catch {
            DaisyLog(error)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate(_:)), name: UIApplication.willTerminateNotification, object: nil)
        DispatchQueue.global().async {
            self.checkOverExpairedDate()
        }
    }
    /// 获取缓存
    func getSyncCache(key: String) -> CacheModel??{
        try? self.storage?.removeExpiredObjects()
        let obj = try? self.storage?.object(forKey: key)
        return obj
    }
    
    
    /// 清除所有缓存
    ///
    /// - Parameter completion: 完成闭包
    func removeAllCache(completion: @escaping (Bool)->()) {
        storage?.async.removeAll(completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .value: completion(true)
                case .error: completion(false)
                }
            }
        })
    }
    /// 根据key值清除缓存
    func removeObjectCache(_ cacheKey: String, completion: @escaping (Bool)->()) {
        storage?.async.removeObject(forKey: cacheKey, completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .value: completion(true)
                case .error: completion(false)
                }
            }
        })
    }
    /// 异步读取缓存
    func object(forKey key: String, completion: @escaping (Cache.Result<CacheModel>)->Void) {
        storage?.async.object(forKey: key, completion: completion)
    }
    /// 读取缓存
    func objectSync(forKey key: String) -> CacheModel? {
        
        do {
            return (try storage?.object(forKey: key)) ?? nil
        } catch {
            return nil
        }
    }
    /// 异步存储
    func setObject(_ object: CacheModel, forKey: String) {
        addObject(key: forKey)
        storage?.async.setObject(object, forKey: forKey, completion: { _ in
        })
    }
    
    func addObject(key: String){
        DispatchQueue.global().async {
            let index = self.keys.firstIndex(where: {$0.key == key})
            if index == nil {
                let model = VPCacheKeys()
                model.key = key
                model.timeStamp = VPTimestamp.share
                model.version = RD_CurrentVersion
                self.keys.append(model)
            }
        }
    }
    
}

class VPTimestamp: NSObject {
    //获得当前时间的时间戳
    class var share: String {
        let internalTime = Date().timeIntervalSince1970
        return "\(Int64(internalTime))"
    }
    
    class var imageTimestap: String {
        let internalTime = Date().timeIntervalSince1970*100000
        return "\(Int64(internalTime))"
    }
}
