//
//  ProfileViewModel.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/28.
//

import UIKit
import RxSwift
import RxCocoa

protocol ProfileViewModelType {
    
    var idText: Observable<String> { get }
    var profileImage: Observable<UIImage> { get }
    var descriptionText: Observable<String> { get }
    var followersText: Observable<String> { get }
    var followsText: Observable<String> { get }
    var posts: Observable<[Post]> { get }
    var postsCountText: Observable<String> { get }
    var curUserObservable: BehaviorSubject<User> { get }
}

class ProfileViewModel : ProfileViewModelType{
    
    var idText: Observable<String>
    var profileImage: Observable<UIImage>
    var descriptionText: Observable<String>
    var followersText: Observable<String>
    var followsText: Observable<String>
    var posts: Observable<[Post]>
    var postsCountText: Observable<String>

    
    let curUserObservable: BehaviorSubject<User>

    init() {
        
        curUserObservable = BehaviorSubject<User>(value: User(uid: "", id: "", name: ""))

        let curUser = User.currentUser!
        curUserObservable.onNext(curUser)
        

        idText = curUserObservable.map { $0.id }
        profileImage = curUserObservable.map { $0.profileImage }
        descriptionText = curUserObservable.map { $0.description }
        followersText = curUserObservable.map { "\($0.followers.count)\n\n팔로워" }
        followsText = curUserObservable.map { "\($0.follows.count)\n\n팔로우" }
        posts = curUserObservable.map { $0.posts }
        postsCountText = curUserObservable.map { "\($0.posts.count)\n\n게시물" }
    }
}
