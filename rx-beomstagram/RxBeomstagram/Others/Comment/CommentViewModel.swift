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

    var postSubject: BehaviorSubject<Post> { get }
    var curUserSubject: BehaviorSubject<User> { get }
    
    var pushCommentObservable: AnyObserver<Comment> { get }
}

class CommentViewModel: CommentViewModelType {

    var disposeBag = DisposeBag()

    var pushCommentObservable: AnyObserver<Comment>
    
    
    var postSubject: BehaviorSubject<Post>
    var curUserSubject: BehaviorSubject<User>
    
    init(post: Post = Post()) {

        postSubject = BehaviorSubject<Post>(value: post)
        curUserSubject = User.currentUserRx
        
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



