//
//  HomeViewModel.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/28.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewModel: CommonViewModel {

    let disposeBag = DisposeBag()
    
    let usersObservable: BehaviorSubject<[User]>
    let postsObservable: BehaviorSubject<[Post]>
    let curUserObservable: BehaviorSubject<User>
    let likeObserver: AnyObserver<(post: Post, isLike: Bool)>

    override init(sceneCoordinator: SceneCoordinatorType) {

        usersObservable = Service.shared.storyUserSubject
        postsObservable = Service.shared.feedPostsSubject
        curUserObservable = Service.shared.curUserSubject

        // Like
        let likeSubject = PublishSubject<(post: Post, isLike: Bool)>()

        likeObserver = likeSubject.asObserver()
//
//        likeSubject.map { self.changeLike($0.post, $0.isLike) }
//            .withLatestFrom(postsObservable) { (updated, originals) -> [Post] in
//                originals.map {
//                    guard $0 == updated else { return $0 }
//                    return updated
//                }
//            }
//            .subscribe(onNext: postsObservable.onNext)
//            .disposed(by: disposeBag)

        super.init(sceneCoordinator: sceneCoordinator)
        
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
    
    // cur유저 팔로우, comment 유저 정보 fetching
    func fetchUserInfo() {
        
        var user = User()
        do {
            user = try self.curUserObservable.value()
        } catch { }
        user.fetchFollowUsers() // followUsers Fetching (시간 좀 걸림)
        user.posts.forEach { post in
            post.comments.forEach { comment in
                comment.fetchCommentUser()
            }
        }
        self.curUserObservable.onNext(user)
    }
    
    func fetchPostsInfo() {
        
        var posts = [Post]()
        do {
            posts = try self.postsObservable.value()
        } catch { }
        
        var uid = [String]()
        posts.forEach { post in
            if uid.contains(post.user.uid) == false {
                post.user.fetchFollowUsers()
                uid.append(post.user.uid)
            }
            post.comments.forEach { comment in
                comment.fetchCommentUser()
            }
        }
        posts.forEach { post in
            post.user.posts = post.user.posts.sorted { $0.cuid > $1.cuid }
        }
        let sorted = posts.sorted { $0.cuid > $1.cuid }
        self.postsObservable.onNext(sorted)
        
    }
    
}
