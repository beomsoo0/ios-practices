//
//  HomeViewModel.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/28.
//

import UIKit
import RxSwift
import RxCocoa

protocol HomeViewModelType {
//
//    var users: Observable<[User]>? { get }
//    var posts: Observable<[Post]>? { get }
////    var curUser: Observable<User> { get }
//    var likeCountText: Observable<String> { get }
}

class HomeViewModel : HomeViewModelType {
    
//    var users: Observable<[User]>?
//    var posts: Observable<[Post]>?

    let usersObservable = BehaviorSubject<[User]>(value: [])
    let postsObservable = BehaviorSubject<[Post]>(value: [])
    let curUserObservable = BehaviorSubject<User>(value: User(uid: "", id: "", name: ""))
    
//    var likeCountText: Observable<String>
    
    
    init() {
        
//        let usersObservable = BehaviorSubject<[User]>(value: [])
//        let postsObservable = BehaviorSubject<[Post]>(value: [])
//        let curUserObservable = BehaviorSubject<User>(value: User.currentUser!)
        
        // 초기화 안되어있어서 weak self 불가
        DatabaseManager.shared.fetchOtherUsers { [weak self] user in
//            var storyUsers = [User]()
//            storyUsers.append(User.currentUser)
//            storyUsers += u
            self?.usersObservable.onNext(user)
//            self?.users = usersObservable.map { $0 }
        }
        DatabaseManager.shared.fetchAllPosts { [weak self] post in
            self?.postsObservable.onNext(post)
//            self.posts = postsObservable.map { $0 }
        }

        let uid = AuthManager.shared.currentUid()!
        DatabaseManager.shared.fetchUser(uid: uid) { [weak self] user in
            self?.curUserObservable.onNext(user)
        }
        
//        likeCountText =
    }
    
    
}
