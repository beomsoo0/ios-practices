//
//  RegisterViewModel.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/20.
//

import Foundation
import RxSwift
import RxCocoa
import Action



class RegisterViewModel: CommonViewModel {
    
    let bag = DisposeBag()
    
    // IdSet Property
    let loginModelRelay = BehaviorRelay<LoginModel>(value: LoginModel(email: "", pswd: ""))
    let emailRelay = BehaviorRelay<String>(value: "")
    let pswdRelay = BehaviorRelay<String>(value: "")
    var loginValid: Observable<Bool> {
        return loginModelRelay.map { $0.loginValid }
    }
    
    // NameSet Property
    let nameSubject = BehaviorRelay<String>(value: "")
    let birthSubject = PublishRelay<String>()
    let genderSubject = PublishRelay<String>()
    
    var nameValid: Observable<Bool> {
        return nameSubject.map { return $0.count >= 2 }
    }
    
    // ImgSet Property
    let imgSubject = BehaviorSubject<UIImage>(value: UIImage(named: "Default_Profile")!)

    let userSubject = BehaviorSubject<User>(value: User())
    
    // Page Moving
    var subViewSubject = BehaviorSubject<RegisterSubView>(value: .idSet)
    
    // Btn
    let back = PublishRelay<Void>()
    var complete = PublishRelay<Void>()

    override init(sceneCoordinator: SceneCoordinator) {
        super.init(sceneCoordinator: sceneCoordinator)
        print("@@@@@@ RegisterViewModel Init @@@@@@")
        
        // userModel Binding
        Observable.combineLatest(emailRelay, pswdRelay)
            .subscribe(onNext: { [unowned self] email, pswd in
                let loginInfo = LoginModel(email: email, pswd: pswd)
                self.loginModelRelay.accept(loginInfo)
            })
            .disposed(by: bag)
        
        Observable.combineLatest(imgSubject, nameSubject, birthSubject, genderSubject)
            .subscribe(onNext: { [unowned self] img, name, birth, gender in
                let user = User(img: img, imgURL: nil, uid: "No", name: name, birth: birth, gender: gender)
                self.userSubject.onNext(user)
            })
            .disposed(by: bag)
        
        
        // SubView Paging
        complete.withLatestFrom(subViewSubject)
            .subscribe(onNext: { [unowned self] in
                self.subViewSubject.onNext( RegisterSubView(rawValue: $0.rawValue + 1) ?? .complete)
            })
            .disposed(by: bag)
        
        back.withLatestFrom(subViewSubject)
            .subscribe(onNext: { [unowned self] in
                self.subViewSubject.onNext(RegisterSubView(rawValue: $0.rawValue - 1) ?? .complete)
            })
            .disposed(by: bag)

    }

    func register() -> Completable {
        return Completable.create { [unowned self] completable in
            Observable.combineLatest(self.loginModelRelay, self.userSubject)
                .subscribe(onNext: { [unowned self] login, user in
                    print(login, user)
                    AuthManager.shared.register_Auth(loginModel: login, user: user)
                        .subscribe { [unowned self] result in
                            switch result {
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
    
    func pushTabbarVC() -> CocoaAction {
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
    
    deinit {
        print("@@@@@@ RegisterViewModel Deinit @@@@@@")
    }
}

