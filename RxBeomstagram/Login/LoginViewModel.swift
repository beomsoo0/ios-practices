//
//  LoginViewModel.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/09/06.
//

import Foundation
import RxSwift

class LoginViewModel {
    
    let emailObserver = BehaviorSubject<String>(value: "")
    let passwordObserver = BehaviorSubject<String>(value: "")
    
    var isValid: Observable<Bool> {
        return Observable.combineLatest(emailObserver, passwordObserver)
            .map { email, password in
                return email.contains("@") && email.contains(".") && password.count >= 8
            }
        
    }
    
    
    
}
