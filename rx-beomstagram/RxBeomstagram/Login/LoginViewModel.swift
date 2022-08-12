//
//  LoginViewModel.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/09/06.
//

import Foundation
import RxSwift

class LoginViewModel: CommonViewModel {
    
    let emailObserver = BehaviorSubject<String>(value: "")
    let passwordObserver = BehaviorSubject<String>(value: "")
    
    var isValid: Observable<Bool> {
        return Observable.combineLatest(emailObserver, passwordObserver)
            .map { email, password in
                return email.contains("@") && email.contains(".") && password.count >= 8
            }
    }

    
    override init(sceneCoordinator: SceneCoordinatorType) {
        super.init(sceneCoordinator: sceneCoordinator)
    }
 
    func modalTabBar() {
        let homeVM = HomeViewModel(sceneCoordinator: self.sceneCoordinator)
        let searchVM = SearchViewModel(sceneCoordinator: self.sceneCoordinator)
        let profileVM = ProfileViewModel(sceneCoordinator: self.sceneCoordinator)
        
        let tabbarVC = Scene.tabbar(homeVM, searchVM, profileVM)
        
        sceneCoordinator.transition(to: tabbarVC, using: .modal, animated: true)
    }
    
}
