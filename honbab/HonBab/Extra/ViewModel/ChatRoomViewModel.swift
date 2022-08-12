//
//  ChatRoomViewModel.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/26.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import Alamofire

class ChatRoomViewModel: CommonViewModel {
    let bag = DisposeBag()
    let chatManager = ChatManager.shared
    
    let curUserSubject: BehaviorSubject<User>
    let chatRoomSubject: BehaviorSubject<ChatRoom>
    let sendMsgSubject: PublishSubject<Message>
    let contentRelay: PublishRelay<String>
    
    let fetching: PublishRelay<Void>
    let sending: PublishRelay<Void>
    
    let complete: BehaviorSubject<Bool>
    let back: PublishRelay<Void>
    
    weak var chatRoom: ChatRoom!

    init(sceneCoordinator: SceneCoordinator, otherUid: String) {

        curUserSubject = Service.shared.curUserSubject
        chatRoomSubject = BehaviorSubject<ChatRoom>(value: ChatRoom())
        sendMsgSubject = PublishSubject<Message>()
        
        contentRelay = PublishRelay<String>()
        fetching = PublishRelay<Void>()
        sending = PublishRelay<Void>()
        complete = BehaviorSubject<Bool>(value: false)
        back = PublishRelay<Void>()
        
        super.init(sceneCoordinator: sceneCoordinator)
        print("@@@@@@ ChatRoomViewModel Init @@@@@@")
        
        chatManager.fetchChatRoom(otherUid: otherUid)
            .subscribe(onNext: { [unowned self] chatRoom in
                self.chatRoomSubject.onNext(chatRoom)
            })
            .disposed(by: bag)
        
        // Scroll -> More Fetch
        fetching
            .withLatestFrom(chatRoomSubject)
            .subscribe(onNext: { [unowned self] chatRoom in
                // More Fetch
                chatManager.fetchChatRoomMessages(otherUid: chatRoom.uid)
                    .subscribe({ success in
                        switch success {
                        case .success(let fetchMsgs):
                            chatRoom.messages = chatRoom.messages + fetchMsgs
                            self.chatRoomSubject.onNext(chatRoom)
                        case .error(_):
                            print("메세지 Fetching ERROR")
                        }
                    })
                    .disposed(by: self.bag)
            })
            .disposed(by: bag)
        
        // Msg Binding
        Observable.combineLatest(curUserSubject, chatRoomSubject, contentRelay)
            .subscribe(onNext: { [unowned self] (curUser, chatRoom, content) in
                guard let otherUser = chatRoom.user else { return }
                let msg = Message(msgUid: "", toUid: otherUser.uid, fromUid: curUser.uid, content: content, date: Date().dateToStr(format: "yyyy-MM-dd-HH-mm-ss"))
                self.sendMsgSubject.onNext(msg)
            })
            .disposed(by: bag)
        
        // Msg Upload
        sending
            .withLatestFrom(sendMsgSubject)
            .subscribe(onNext: { [unowned self] msg in
                chatManager.uploadMessage(message: msg)
                    .subscribe({ Completable in
                        switch Completable {
                        case .completed:
                            print("메세지 업로드 성공")
                            complete.onNext(true)
                        case .error(let error):
                            print("메세지 업로드 실패")
                        }
                    })
                    .disposed(by: self.bag)
            })
            .disposed(by: bag)
        
        // Notification
        sending
            .withLatestFrom(Observable.combineLatest(curUserSubject, chatRoomSubject, sendMsgSubject))
            .subscribe(onNext: { [unowned self] (curUser, chatRoom, msg) in
                let notificationModel = NotificationModel()
                
                guard let user = chatRoom.user,
                    let token = user.token else { return }

                let url = notificationModel.url
                let header = notificationModel.header
                
                notificationModel.to = token
                notificationModel.notification.title = curUser.name
                notificationModel.notification.text = msg.content

                // For Foreground
                notificationModel.data.title = curUser.name
                notificationModel.data.text = msg.content
                
                let parmas = notificationModel.toJSON()
                
                AF.request(url, method: .post, parameters: parmas, encoding: JSONEncoding.default, headers: header).responseJSON { responce in
                    print(responce)
                }
            })
            .disposed(by: bag)


        back
            .subscribe(onNext: { [unowned self] in
                chatManager.initMsgParameter()
                self.backAction.execute()
            })
            .disposed(by: bag)
    }
    
    deinit {
        print("@@@@@@ ChatRoomViewModel Deinit @@@@@@")
    }
}
