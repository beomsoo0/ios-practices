//
//  FriendViewModel.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/30.
//

import UIKit
import RxSwift
import RxCocoa

protocol FriendViewModelType {
    var idText: Observable<String> { get }
    var profileImage: Observable<UIImage> { get }
    var descriptionText: Observable<String> { get }
    var followers: Observable<[String]> { get }
    var follows: Observable<[String]> { get }
    var posts: Observable<[Post]> { get }
    var postsCountText: Observable<String> { get }
    var isFollowing: Observable<Bool> { get }
    var userSubject: BehaviorSubject<User> { get }
    var changeFollowObserver: AnyObserver<String> { get }
}

class FriendViewModel: FriendViewModelType {
    
    let disposeBag = DisposeBag()
    
    var idText: Observable<String>
    var profileImage: Observable<UIImage>
    var descriptionText: Observable<String>
    var followers: Observable<[String]>
    var follows: Observable<[String]>
    var posts: Observable<[Post]>
    var postsCountText: Observable<String>
    var isFollowing: Observable<Bool>

    
    var userSubject: BehaviorSubject<User>
    var changeFollowObserver: AnyObserver<String>
    
    init(_ selectedUser: User = User(uid: "", id: "", name: "")) {
        
        userSubject = BehaviorSubject<User>(value: selectedUser)

        idText = userSubject.map { $0.id }
        profileImage = userSubject.map { $0.profileImage }
        descriptionText = userSubject.map { $0.description }
        followers = userSubject.map { $0.followers }
        follows = userSubject.map { $0.follows }
        posts = userSubject.map { $0.posts }
        postsCountText = userSubject.map { "\($0.posts.count)\n\n게시물" }
        isFollowing = userSubject.map({ user -> Bool in
            if user.followers.contains(AuthManager.shared.currentUid()!) == true {
                return true
            } else {
                return false
            }
        })

        
        // 팔로우
        let changeFollowSubject = PublishSubject<String>()
        changeFollowObserver = changeFollowSubject.asObserver()
        
        changeFollowSubject
            .map { $0 }
            .withLatestFrom(userSubject) { uid, user -> User in
                if user.followers.contains(uid) == true {
                    user.followers = user.followers.filter({ $0 != uid })
                    DatabaseManager.shared.deleteFollow(from: User.currentUser, to: selectedUser) { }
                } else {
                    user.followers.append(uid)
                    DatabaseManager.shared.updateFollow(from: User.currentUser, to: selectedUser) { }
                }
                return user
            }.subscribe(onNext: userSubject.onNext)
            .disposed(by: disposeBag)
        
        
    }
    
   
    
    
}
