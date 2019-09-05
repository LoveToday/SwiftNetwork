//
//  ViewController.swift
//  SwiftNetwork
//
//  Created by ChenJiangLin on 2019/9/5.
//  Copyright © 2019 ChenJiangLin. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
class ViewController: UIViewController {
    var bag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        testRequest()
    }
    
    func testRequest(){
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
    }


}

