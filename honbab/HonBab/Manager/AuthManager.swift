//
//  AuthManager.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/20.
//

import Foundation
import RxSwift
import FirebaseAuth

class AuthManager {
    
    static let shared = AuthManager()
    let bag = DisposeBag()
    
    func login_Auth(loginInfo: LoginModel) -> Completable {
        return Completable.create() { [unowned self] completable in
            Auth.auth().signIn(withEmail: loginInfo.email, password: loginInfo.pswd) { [unowned self] (result, error) in
                guard result != nil, error == nil else {
                    completable(.error(error!))
                    return
                }
                completable(.completed)
            }
            return Disposables.create()
        }
    }
    
    func register_Auth(loginModel: LoginModel, user: User) -> Completable {
        return Completable.create() { [unowned self] completable in
            
            Auth.auth().createUser(withEmail: loginModel.email, password: loginModel.pswd) { [unowned self] (result, error) in
                guard let result = result, error == nil else {
                    completable(.error(error!))
                    return
                }
                let uid = result.user.uid

                Service.shared.insertNewUser(uid: uid, user: user)
                    .subscribe({ [unowned self] success in
                        switch success {
                        case .completed:
                            completable(.completed)
                        case .error(let error):
                            completable(.error(error))
                        }
                    })
                    .disposed(by: self.bag)
            }
            return Disposables.create()
        }
    }

    func logOut_Auth() -> Completable {
        return Completable.create { [unowned self] completable in
            do {
                try Auth.auth().signOut()
                completable(.completed)
            } catch {
                completable(.error(error))
            }
            return Disposables.create()
        }
    }
    
    func curUid() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func userName() -> String? {
        return Auth.auth().currentUser?.displayName
    }
    
    
}
