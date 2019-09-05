//
//  MapBaseModel.swift
//  SwiftNetwork
//
//  Created by ChenJiangLin on 2019/9/5.
//  Copyright © 2019 ChenJiangLin. All rights reserved.
//

import UIKit
import HandyJSON

enum RxSwiftMoyaError: Error {
    case RxSwiftMoyaNoRepresentor
    case RxSwiftMoyaNotSuccessfulHTTP
    case RxSwiftMoyaNoData
    case RxSwiftMoyaCouldNotMakeObjectError
    case RxSwiftMoyaBizError(resultCode: Int?, resultMsg: String?)
    case RXSwiftMoyaNoNetwork
}

public class MapBaseModel<T>: HandyJSON {
    
    var code: Int?
    var message: String?
    var data: T?
    var success: Bool {
        guard let co = code, co == 10000 else {
            return false
        }
        return true
    }
    required public init() {}
}
