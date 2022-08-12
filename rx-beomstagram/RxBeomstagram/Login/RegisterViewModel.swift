//
//  RegisterViewModel.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/09/06.
//

import Foundation
import RxSwift

class RegisterViewModel {
    
    let emailObserver = BehaviorSubject<String>(value: "")
    let idObserver = BehaviorSubject<String>(value: "")
    let nameObserver = BehaviorSubject<String>(value: "")
    let passwordObserver = BehaviorSubject<String>(value: "")
    
    var isValid: Observable<Bool> {
        Observable.combineLatest(emailObserver, idObserver, nameObserver, passwordObserver)
            .map { email, id, name, password in
                return email.contains("@") && email.contains(".") && id.count >= 3 && name.count >= 3 && password.count >= 8
            }
    }
    
}
