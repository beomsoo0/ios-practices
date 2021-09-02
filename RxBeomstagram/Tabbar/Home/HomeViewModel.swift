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

    var likeObserver: AnyObserver<(post: Post, isLike: Bool)> { get }
    
}

class HomeViewModel: HomeViewModelType {

    let usersObservable:  BehaviorSubject<[User]>
    let postsObservable: BehaviorSubject<[Post]>
    let curUserObservable: BehaviorSubject<User>

    let disposeBag = DisposeBag()
    
    let likeObserver: AnyObserver<(post: Post, isLike: Bool)>

    
    
    init() {

        usersObservable = User.allUserRx
        postsObservable = Post.allPostsRx
        curUserObservable = User.currentUserRx
        
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
