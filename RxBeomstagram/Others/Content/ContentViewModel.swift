//
//  ContentViewModel.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/31.
//

import UIKit
import RxSwift
import RxCocoa

protocol ContentViewModelType {
    var postsObservable: BehaviorSubject<[Post]> { get }
    var curUserObservable: BehaviorSubject<User> { get }
    var likeObserver: AnyObserver<(post: Post, isLike: Bool)> { get }
    
}

class ContentViewModel: ContentViewModelType {
    
    var postsObservable = BehaviorSubject<[Post]>(value: [])
    var curUserObservable = BehaviorSubject<User>(value: User(uid: "", id: "", name: ""))

    let disposeBag = DisposeBag()
    
    let likeObserver: AnyObserver<(post: Post, isLike: Bool)>

    
    
    init() {

        // Like
        let likeSubject = PublishSubject<(post: Post, isLike: Bool)>()
        
        likeObserver = likeSubject.asObserver()
        
        likeSubject.map { self.changeLike($0.post, $0.isLike) }
            .withLatestFrom(postsObservable) { (updated, originals) -> [Post] in
                originals.map {
                    guard $0 == updated else { return $0 }
                    return updated
                }
            }
            .subscribe(onNext: postsObservable.onNext)
            .disposed(by: disposeBag)

        DatabaseManager.shared.fetchAllPosts { [weak self] post in
            self?.postsObservable.onNext(post)

        }

        let uid = AuthManager.shared.currentUid()!
        DatabaseManager.shared.fetchUser(uid: uid) { [weak self] user in
            self?.curUserObservable.onNext(user)
        }
    }
    
    init(_ passedPosts: BehaviorSubject<[Post]>) {
        
        postsObservable = passedPosts
   
        // Like
        let likeSubject = PublishSubject<(post: Post, isLike: Bool)>()
        
        likeObserver = likeSubject.asObserver()
        
        likeSubject.map { self.changeLike($0.post, $0.isLike) }
            .withLatestFrom(postsObservable) { (updated, originals) -> [Post] in
                originals.map {
                    guard $0 == updated else { return $0 }
                    return updated
                }
            }
            .subscribe(onNext: postsObservable.onNext)
            .disposed(by: disposeBag)
        
        
        let uid = AuthManager.shared.currentUid()!
        DatabaseManager.shared.fetchUser(uid: uid) { [weak self] user in
            self?.curUserObservable.onNext(user)
        }
        
        
        
        
    }
    

    
    
    func changeLike(_ post: Post, _ isLike: Bool) -> Post {
        let curUid = AuthManager.shared.currentUid()!
        
        if isLike == true {
            DatabaseManager.shared.deleteLike(from: User.currentUser, to: post.user, cuid: post.cuid) { }
            post.likes = post.likes.filter({ $0 != curUid })
        } else {
            DatabaseManager.shared.updateLike(from: User.currentUser, to: post.user, cuid: post.cuid) { }
            post.likes.append(curUid)
        }
        return post
    }
    
    
    

    
    
}

