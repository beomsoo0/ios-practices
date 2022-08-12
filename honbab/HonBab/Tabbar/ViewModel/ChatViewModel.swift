//
//  ChatViewModel.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/20.
//

import Foundation
import RxSwift
import RxCocoa
import Action

class ChatViewModel: CommonViewModel {

    let bag = DisposeBag()
    let chatManager = ChatManager.shared
    let curUserSubject: BehaviorSubject<User>
    let chatRoomsSubject: BehaviorSubject<[ChatRoom]>

    override init(sceneCoordinator: SceneCoordinator) {
        
        curUserSubject = Service.shared.curUserSubject
        chatRoomsSubject = BehaviorSubject<[ChatRoom]>(value: [])
 
        super.init(sceneCoordinator: sceneCoordinator)
        print("@@@@@@ ChatViewModel Init @@@@@@")
        
        chatManager.fetchChatRooms()
            .subscribe(onNext: { [unowned self] chatRooms in
                chatRoomsSubject.onNext(chatRooms)
            })
            .disposed(by: bag)
     
    }

    func pushChatRoomVC(otherUid: String) -> CocoaAction {
        return CocoaAction { [unowned self] in        
            let chatRoomVM = ChatRoomViewModel(sceneCoordinator: self.sceneCoordinator, otherUid: otherUid)
            let chatRoomScene = Scene.chatRoom(chatRoomVM)
            return self.sceneCoordinator.transition(to: chatRoomScene, using: .push, animated: true).asObservable().map { _ in}
        }
    }
    
    deinit {
        print("@@@@@@ ChatViewModel Deinit @@@@@@")
    }
}
