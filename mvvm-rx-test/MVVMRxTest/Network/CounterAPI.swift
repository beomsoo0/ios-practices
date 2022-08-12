//
//  CounterAPI.swift
//  MVVMRxTest
//
//  Created by 김범수 on 2022/05/10.
//

import Moya

class CounterAPI: TargetType {
    var baseURL: URL {
        URL(string: "[https://swift.org](https://swift.org)")!
    }
    
    var path: String {
        ""
    }
    
    var method: Method {
        .get
    }
    
    var task: Task {
        .requestPlain
    }
    
    var headers: [String : String]? {
        nil
    }
    
}
