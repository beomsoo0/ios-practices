//
//  PostViewModel.swift
//  HonBab
//
//  Created by 김범수 on 2021/10/01.
//

import Foundation
import RxSwift
import RxCocoa
import Action

class PostViewModel: CommonViewModel {
    let bag = DisposeBag()
    
    let curUserSubject: BehaviorSubject<User>
    let usersSubject: BehaviorSubject<[User]>
    let postSubject: BehaviorSubject<Post>

    let fetching: PublishRelay<Void>
    let promising: PublishRelay<Void>
    let promiseValid: BehaviorSubject<(Bool, Bool)>
    let positionSubject: BehaviorSubject<String>
    let chatRoomPushing: PublishRelay<Void>
    
    init(sceneCoordinator: SceneCoordinator, post: Post, otherVM: PostsHasViewModel) {

        curUserSubject = Service.shared.curUserSubject
        usersSubject = BehaviorSubject<[User]>(value: [])
        postSubject = BehaviorSubject<Post>(value: post)
        
        fetching = PublishRelay<Void>()
        promising = PublishRelay<Void>()
        promiseValid = BehaviorSubject<(Bool, Bool)>(value: (true, true))
        positionSubject = BehaviorSubject<String>(value: "")
        chatRoomPushing = PublishRelay<Void>()
        
        
        super.init(sceneCoordinator: sceneCoordinator)
        print("@@@@@@ PostViewModel Init @@@@@@")

        postSubject
            .subscribe(onNext: { [unowned self] post in
                var users: [User] = []
                // Host User Fetching
                Service.shared.fetchUser(uid: post.promise.hostUid)
                    .subscribe(onNext: { [unowned self] user in
                        users.insert(user, at: 0)
                        post.user = user
                        self.usersSubject.onNext(users)
                    })
                    .disposed(by: self.bag)
                // Promise Users Fetching
                post.promise.peoples.forEach { [unowned self] (key, val) in
                    Service.shared.fetchUser(uid: key)
                        .subscribe(onNext: { [unowned self] user in
                            users.append(user)
                            self.usersSubject.onNext(users)
                        })
                        .disposed(by: self.bag)
                }
            })
            .disposed(by: bag)
        
        postSubject
            .withLatestFrom(Observable.combineLatest(postSubject, otherVM.postsSubject))
            .subscribe(onNext: { [unowned self] post, posts in
                let newPost = posts.map { $0.puid == post.puid ? post : $0 }
                otherVM.postsSubject.onNext(newPost)
            })
            .disposed(by: bag)
        
        // Promise 기능
        promising
            .throttle(.seconds(1), latest: false, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .withLatestFrom(Observable.combineLatest(curUserSubject, postSubject))
            .subscribe(onNext: { [unowned self] (curUser, curPost) in
                if !curPost.promise.peoples.contains(where: { $0.key == curUser.uid }) {
                    Service.shared.promiseAdd(pUid: curPost.puid, uid: curUser.uid, name: curUser.name)
                        .subscribe(onNext: { [unowned self] _ in
                            curPost.promise.peoples.updateValue(curUser.name, forKey: curUser.uid)
                            self.postSubject.onNext(curPost)
                            curUser.promisePuids.append(curPost.puid)
                            self.curUserSubject.onNext(curUser)
                        })
                        .disposed(by: self.bag)
                } else {
                    Service.shared.promiseRemove(pUid: curPost.puid, uid: curUser.uid, name: curUser.name)
                        .subscribe(onNext: { [unowned self] _ in
                            curPost.promise.peoples.removeValue(forKey: curUser.uid)
                            self.postSubject.onNext(curPost)
                            curUser.promisePuids.removeAll(where: { $0 == curPost.uid })
                            self.curUserSubject.onNext(curUser)
                        })
                        .disposed(by: self.bag)
                }
            })
            .disposed(by: bag)
        
        // Promise Valid Check
        Observable.combineLatest(curUserSubject, postSubject)
            .subscribe(onNext: { [unowned self] (curUser, post) in
                if curUser.uid == post.promise.hostUid {
                    self.promiseValid.onNext((false, true))
                } else {
                    let isContain = curUser.promisePuids.contains(post.puid)
                    let isFull = post.promise.maxPeople <= post.promise.curNum
                    self.promiseValid.onNext((isContain, isFull))
                }
            })
            .disposed(by: bag)
        
        // Position Fetching
        postSubject
            .map { $0.position }
            .bind(to: positionSubject)
            .disposed(by: bag)

    }
    
    func pushChatRoomVC() -> CocoaAction {
        return CocoaAction { [unowned self] _ in
            var otherUid = "Default"
            self.postSubject
                .subscribe(onNext: { [unowned self] post in
                    otherUid = post.uid
                })
                .disposed(by: self.bag)
            // Transition
            let chatRoomVM = ChatRoomViewModel(sceneCoordinator: self.sceneCoordinator, otherUid: otherUid)
            let chatRoomScene = Scene.chatRoom(chatRoomVM)
            return self.sceneCoordinator.transition(to: chatRoomScene, using: .push, animated: true).asObservable().map { _ in }
        }
    }
    

    deinit {
        print("@@@@@@ PostViewModel Deinit @@@@@@")
    }
}
