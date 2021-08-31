//
//  CommentViewModel.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/31.
//

import UIKit
import RxSwift
import RxCocoa

protocol CommentViewModelType {
    var postObservable: Observable<Post> { get }
    var curUserObservable: Observable<User> { get }
//    var commentObservable: Observable<[Comment]> { get }
    
    
    var pushCommentObservable: AnyObserver<Comment> { get }
}

class CommentViewModel: CommentViewModelType {

    var disposeBag = DisposeBag()
    var postObservable: Observable<Post>
    var curUserObservable: Observable<User>
//    var commentObservable: Observable<[Comment]>
//    var usersObservable: Observable<[User]>
    var pushCommentObservable: AnyObserver<Comment>
    
    init(post: Post = Post(), curUser: User = User()) {

        var postSubject = BehaviorSubject<Post>(value: post)
        let curUserSubject = BehaviorSubject<User>(value: curUser)
        
        postObservable = postSubject.asObserver()
        curUserObservable = curUserSubject.asObservable()
            
//        commentObservable = postObservable.map({ $0.comments })

        
        // 댓글달기
        let pushCommentSubject = PublishSubject<Comment>()
        pushCommentObservable = pushCommentSubject.asObserver()
        
        pushCommentSubject
            .map { $0 }
            .withLatestFrom(postSubject) { comment, post -> Post in
                post.comments.append(comment)
                return post
            }.subscribe(onNext: postSubject.onNext)
            .disposed(by: disposeBag)
        
        
    }


}



