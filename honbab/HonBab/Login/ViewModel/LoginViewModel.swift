//
//  LoginViewModel.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/20.
//

import Foundation
import RxSwift
import RxCocoa
import Action

final class LoginViewModel: CommonViewModel {
    
    private let bag = DisposeBag()
    public let loginModelRelay: BehaviorRelay<LoginModel>
    public let emailRelay: BehaviorRelay<String>
    public let pswdRelay: BehaviorRelay<String>
    public var loginValid: Observable<Bool> {
        return loginModelRelay.map { $0.loginValid }
    }
    
    override init(sceneCoordinator: SceneCoordinator) {
        loginModelRelay = BehaviorRelay<LoginModel>(value: LoginModel())
        emailRelay = BehaviorRelay<String>(value: "")
        pswdRelay = BehaviorRelay<String>(value: "")
        
        
        super.init(sceneCoordinator: sceneCoordinator)
        
        Observable.combineLatest(emailRelay, pswdRelay)
            .subscribe(onNext: { [weak self] email, pswd in
                let loginInfo = LoginModel(email: email, pswd: pswd)
                self?.loginModelRelay.accept(loginInfo)
            })
            .disposed(by: bag)
    
    }
    
    public func login() -> Completable {
        return Completable.create { [unowned self] completable in
            self.loginModelRelay
                .subscribe(onNext: { [unowned self] loginInfo in
                    AuthManager.shared.login_Auth(loginInfo: loginInfo)
                        .subscribe { success in
                            switch success {
                            case .completed:
                                completable(.completed)
                            case .error(let error):
                                completable(.error(error))
                            }
                        }
                        .disposed(by: self.bag)
                })
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }
    
    public func pushTabbarVC() -> CocoaAction {
        return CocoaAction { [unowned self] _ in
            let homeVM = HomeViewModel(sceneCoordinator: self.sceneCoordinator)
            let peopleVM = PeopleViewModel(sceneCoordinator: self.sceneCoordinator)
            let nearVM = NearViewModel(sceneCoordinator: self.sceneCoordinator)
            let chatVM = ChatViewModel(sceneCoordinator: self.sceneCoordinator)
            let profileVM = ProfileViewModel(sceneCoordinator: self.sceneCoordinator)
            
            let tabbarScene = Scene.tabbar(homeVM, peopleVM, nearVM, chatVM, profileVM)
            return self.sceneCoordinator.transition(to: tabbarScene, using: .push, animated: true).asObservable().map { _ in }
        }
    }
    
    public func pushRegisterVC() -> CocoaAction {
        return CocoaAction { [unowned self] _ in
            let registerVM = RegisterViewModel(sceneCoordinator: self.sceneCoordinator)
            let registerScene = Scene.register(registerVM)
            return self.sceneCoordinator.transition(to: registerScene, using: .push, animated: true).asObservable().map { _ in }
        }
    }

}
