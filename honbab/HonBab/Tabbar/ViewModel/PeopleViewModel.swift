//
//  PeopleViewModel.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/25.
//

import Foundation
import RxSwift
import RxCocoa
import Action

class PeopleViewModel: CommonViewModel {
    let bag = DisposeBag()
    let curUserSubject: BehaviorSubject<User>
    let usersSubject: BehaviorSubject<[User]>
    let fetching: PublishRelay<Void>
    
    override init(sceneCoordinator: SceneCoordinator) {
        
        curUserSubject = Service.shared.curUserSubject
        usersSubject = BehaviorSubject<[User]>(value: [])
        fetching = PublishRelay<Void>()
        
        super.init(sceneCoordinator: sceneCoordinator)
        print("@@@@@@ PeopleViewModel Init @@@@@@")
        
        fetching
            .subscribe(onNext: { [unowned self] _ in
                Service.shared.fetchUsers()
                    .map { $0.filter { $0.uid != AuthManager.shared.curUid()! } }
                    .bind(to: self.usersSubject)
                    .disposed(by: self.bag)
            })
            .disposed(by: bag)
    }
    
    func pushChatRoomVC(idx: Int) -> CocoaAction {
        return CocoaAction { [unowned self] in
            var otherUid = "Default"
            self.usersSubject
                .subscribe(onNext: { [unowned self] users in
                    otherUid = users[idx].uid
                })
                .disposed(by: self.bag)
            
            // Transition
            let chatRoomVM = ChatRoomViewModel(sceneCoordinator: self.sceneCoordinator, otherUid: otherUid)
            let chatRoomScene = Scene.chatRoom(chatRoomVM)
            return self.sceneCoordinator.transition(to: chatRoomScene, using: .push, animated: true).asObservable().map { _ in }
        }
    }
    
    deinit {
        print("@@@@@@ PeopleViewModel Deinit @@@@@@")
    }
}
