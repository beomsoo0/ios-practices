//
//  EndPoint+.swift
//  MVVMRxTest
//
//  Created by 김범수 on 2022/05/10.
//

import Moya

extension Endpoint {
    // Mock 데이터를 쉽게 만들기 위해서 다음과 같은 확장
    class func succeedEndpointClosure<T: TargetType, E: Encodable>(_ targetType: T.Type, with object: E) -> (T) -> Endpoint {
        return { (target: T) -> Endpoint in
            let data = try! JSONEncoder().encode(object)
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: {.networkResponse(200, data)},
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }
    }
}
