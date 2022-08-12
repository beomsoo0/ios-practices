//
//  ChatManager.swift
//  HonBab
//
//  Created by 김범수 on 2021/10/15.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import RxSwift
import FirebaseMessaging
import RxCocoa

class ChatManager {
    
    public static let shared = ChatManager()
    private let ref = Database.database().reference()
    private let bag = DisposeBag()
    private let service = Service.shared
    
    // Fetching Parameter
    private let dbMsgFetchCnt: UInt = 10
    public var dbLastFetchMsgDate = "2099-99-99-99-99-99-99"
    func initMsgParameter() {
        dbLastFetchMsgDate = "2099-99-99-99-99-99-99"
        observeList.removeLast()
    }
    public var observeList: [UInt] = []
    
    // Message Upload
    func uploadMessage(message: Message) -> Completable {
        return Completable.create { [unowned self] completable in
            let msgUid = self.ref.child("user").child(message.fromUid).child("chatRooms").child(message.toUid).childByAutoId().key!
            let msg = [
                msgUid: [
                    "msgUid": msgUid,
                    "date": message.date,
                    "toUid": message.toUid,
                    "fromUid": message.fromUid,
                    "content": message.content
                ]
            ]

            self.ref.child("user").child(message.fromUid).child("chatRooms").child(message.toUid).child("msgs").updateChildValues(msg)
            self.ref.child("user").child(message.toUid).child("chatRooms").child(message.fromUid).child("msgs").updateChildValues(msg)
            self.ref.child("user").child(message.fromUid).child("chatRooms").child(message.toUid).child("lastMsg").setValue(msg)
            self.ref.child("user").child(message.toUid).child("chatRooms").child(message.fromUid).child("lastMsg").setValue(msg)
            completable(.completed)
            return Disposables.create()
        }
    }
    
    // 채팅방 다 Fetching
    // 정해진 갯수 fetching [x]
    // ChatRoom Fetching[o], Observe[o]
    // LastMsg Fetching[o], Observe [o]
    // UserInfo Feching[o]
    func fetchChatRooms() -> Observable<[ChatRoom]> {
        return Observable.create { [unowned self] emitter in
            let curUid = AuthManager.shared.curUid()!
            let chatRoomsSubject = BehaviorSubject<[ChatRoom]>(value: [])
            let chatRoomSubject = PublishSubject<ChatRoom>()
            let fetching = PublishSubject<String>()
            let observe = PublishSubject<String>()
            var uidList = [String]()
            var chatRoomsUids = [String]()
            
            chatRoomsSubject
                .subscribe(onNext: { [unowned self] chatRooms in
                    let filterdChatRooms = chatRooms.filter { $0.lastMsg != nil }
                    let sortedChatRooms = filterdChatRooms.sorted { $0.lastMsg!.date > $1.lastMsg!.date }
                    emitter.onNext(sortedChatRooms)
                })
                .disposed(by: bag)
            
            chatRoomSubject
                .withLatestFrom(Observable.combineLatest(chatRoomSubject, chatRoomsSubject))
                .subscribe(onNext: { [unowned self] chatRoom, chatRooms in
                    var newChatRooms = chatRooms
                    if chatRoomsUids.contains(chatRoom.uid) {
                        newChatRooms = chatRooms.map { return $0.uid == chatRoom.uid ? chatRoom : $0 }
                    } else {
                        newChatRooms.append(chatRoom)
                        chatRoomsUids.append(chatRoom.uid)
                    }
                    chatRoomsSubject.onNext(newChatRooms)
                })
                .disposed(by: self.bag)
            
            fetching
                .subscribe(onNext: { [unowned self] otherUid in
                    self.fetchLastMsg(otherUid: otherUid)
                        .subscribe { lastMsg in
                            let chatRoom = ChatRoom(uid: otherUid, lastMessage: lastMsg)
                            service.fetchUser(uid: otherUid)
                                .subscribe(onNext: { [unowned self] otherUser in
                                    chatRoom.user = otherUser
                                    chatRoomSubject.onNext(chatRoom)
                                    observe.onNext(otherUid)
                                })
                                .disposed(by: self.bag)
                            
                        } onError: { _ in
                        }
                })
                .disposed(by: bag)
            
            observe
                .withLatestFrom(Observable.combineLatest(chatRoomSubject, observe))
                .subscribe(onNext: { [unowned self] chatRoom, otherUid in
                    self.lastMsgObserve(otherUid: otherUid)
                        .subscribe(onNext: { [unowned self] addedMsg in
                            if chatRoom.lastMsg?.msgUid != addedMsg.msgUid {
                                chatRoom.lastMsg = addedMsg
                                chatRoom.messages.insert(addedMsg, at: 0)
                                chatRoomSubject.onNext(chatRoom)
                            }
                        })
                        .disposed(by: self.bag)
                })
                .disposed(by: bag)
            
            // Observe ChatRoom Added
            self.ref.child("user").child(curUid).child("chatRooms").observe(.childAdded, with: { [unowned self] otherUidSnapshot in
                if !otherUidSnapshot.exists() { chatRoomsSubject.onNext([]) }
                let otherUid = otherUidSnapshot.key
                if !uidList.contains(otherUid) {
                    uidList.append(otherUid)
                    fetching.onNext(otherUid)
                }
            })
            
            return Disposables.create {
                emitter.onCompleted()
            }
        }
    }
    
    // 특정 채팅방
    // ChatRoom OneFetching[o]
    // LastMsg Fetching[o], Observe[o]
    // UserInfo Feching[o]
    func fetchChatRoom(otherUid: String) -> Observable<ChatRoom> {
        return Observable.create { [unowned self] emitter in
            
            let chatRoomSubject = PublishSubject<ChatRoom>()
            let observe = PublishSubject<String>()
            
            chatRoomSubject
                .subscribe(onNext: { [unowned self] chatRoom in
                    emitter.onNext(chatRoom)
                })
                .disposed(by: bag)
            
            self.fetchChatRoomMessages(otherUid: otherUid)
                .subscribe({ success in
                    switch success {
                    case .success(let fetchMsgs):
                        let chatRoom = ChatRoom(uid: otherUid, lastMessage: fetchMsgs.first)
                        chatRoom.messages = fetchMsgs
                        service.fetchUser(uid: otherUid)
                            .subscribe(onNext: { [unowned self] otherUser in
                                chatRoom.user = otherUser
                                chatRoomSubject.onNext(chatRoom)
                                observe.onNext(otherUid)
                            })
                            .disposed(by: self.bag)
                    case .error(_):
                        print("메세지 Fetching ERROR")
                    }
                })
                .disposed(by: self.bag)
            
            observe
                .withLatestFrom(Observable.combineLatest(chatRoomSubject, observe))
                .subscribe(onNext: { [unowned self] chatRoom, otherUid in
                    self.lastMsgObserve(otherUid: otherUid)
                        .subscribe(onNext: { [unowned self] addedMsg in
                            if chatRoom.lastMsg?.msgUid != addedMsg.msgUid {
                                chatRoom.lastMsg = addedMsg
                                chatRoom.messages.insert(addedMsg, at: 0)
                                chatRoomSubject.onNext(chatRoom)
                            }
                        })
                        .disposed(by: self.bag)
                })
                .disposed(by: bag)
            
            return Disposables.create {
                emitter.onCompleted()
            }
        }
    }
    
    // Msgs One Fetching
    func fetchChatRoomMessages(otherUid: String) -> Single<[Message]> {
        return Single.create { [unowned self] single in
            let curUid = AuthManager.shared.curUid()!
            let msgRef = self.ref.child("user").child(curUid).child("chatRooms").child(otherUid).child("msgs")
            
            msgRef.queryOrdered(byChild: "date").queryEnding(beforeValue: self.dbLastFetchMsgDate).queryLimited(toLast: self.dbMsgFetchCnt).observeSingleEvent(of: .value) { [unowned self] msgsSnapshot in
                
                if !msgsSnapshot.exists() { single(.success([])) }
                
                let dbMsgCnt =  msgsSnapshot.childrenCount
                var messages = [Message]()
                for mSnapshot in msgsSnapshot.children.allObjects as! [DataSnapshot] {
                    let value = mSnapshot.value as? [String: Any]
                    let msgUid = mSnapshot.key
                    
                    guard let date =  value?["date"] as? String,
                          let toUid = value?["toUid"] as? String,
                          let fromUid = value?["fromUid"] as? String,
                          let content = value?["content"] as? String else {
                              return
                          }
                    let message = Message(msgUid: msgUid, toUid: toUid, fromUid: fromUid, content: content, date: date)
                    messages.insert(message, at: 0)
                    
                    if dbMsgCnt >= self.dbMsgFetchCnt { // Normal : 한번 fetching할만큼 남아있을때
                        if messages.count == self.dbMsgFetchCnt {
                            self.dbLastFetchMsgDate = messages.last!.date
                            single(.success(messages))
                            return
                        }
                    } else {
                        if  messages.count == dbMsgCnt { // Exception: 조금 남았을때
                            self.dbLastFetchMsgDate = messages.last!.date
                            single(.success(messages))
                            return
                        }
                    }
                }
            }
            return Disposables.create ()
        }
    }
    
    // LastMsg OneFetching
    func fetchLastMsg(otherUid: String) -> Single<Message> {
        return Single.create { [unowned self] single in
            let curUid = AuthManager.shared.curUid()!
            let lastMsgRef = self.ref.child("user").child(curUid).child("chatRooms").child(otherUid).child("lastMsg")
            
            lastMsgRef.observeSingleEvent(of: .value) { [unowned self] lastMsgSnapshot in
                if !lastMsgSnapshot.exists() {
                    single(.success(Message()))
                    return
                }
                
                let value = lastMsgSnapshot.value as? [String: [String: Any]]
                let lastMsgDic = value?.values.first as? [String: String]
                let msgUid = lastMsgSnapshot.key
                
                guard let date =  lastMsgDic?["date"] as? String,
                      let toUid = lastMsgDic?["toUid"] as? String,
                      let fromUid = lastMsgDic?["fromUid"] as? String,
                      let content = lastMsgDic?["content"] as? String else {
                          return
                      }
                
                let message = Message(msgUid: msgUid, toUid: toUid, fromUid: fromUid, content: content, date: date)
                single(.success(message))
            }
            return Disposables.create ()
        }
    }
    
    // LastMsg Observe
    func lastMsgObserve(otherUid: String) -> Observable<Message> {
        return Observable.create { [unowned self] emitter in
            let curUid = AuthManager.shared.curUid()!
            let lastMsgRef = self.ref.child("user").child(curUid).child("chatRooms").child(otherUid).child("lastMsg")
            
            let observe = lastMsgRef.observe(.childAdded, with: { [unowned self] lastMsgSnapshot in
                
                if !lastMsgSnapshot.exists() {
                    emitter.onNext(Message())
                    return
                }
                
                let msgUid = lastMsgSnapshot.key
                let lastMsgDic = lastMsgSnapshot.value as? [String: Any]
                
                guard let date =  lastMsgDic?["date"] as? String,
                      let toUid = lastMsgDic?["toUid"] as? String,
                      let fromUid = lastMsgDic?["fromUid"] as? String,
                      let content = lastMsgDic?["content"] as? String else {
                          return
                      }
                let message = Message(msgUid: msgUid, toUid: toUid, fromUid: fromUid, content: content, date: date)
                emitter.onNext(message)
            })
            self.observeList.append(observe)
            return Disposables.create ()
        }
    }
    
    
}
