//
//  DefaultsKeys.swift
//  Vape
//
//  Created by Levin on 2017/3/20.
//  Copyright © 2017年 范国徽. All rights reserved.
//

import SwiftyUserDefaults

extension UserDefaults {

    subscript(key: DefaultsKey<[VPCacheKeys]>) -> [VPCacheKeys] {
        
        set {
            archive(key, newValue)
        }
        get {
            return unarchive(key) ?? []
        }
    }
    

}


extension DefaultsKeys {
    
    
    /// 所有的存储的key
    static let storeSourceKeys = DefaultsKey<[VPCacheKeys]>("store-source-key")

}





