//
//  CategoryViewModel.swift
//  HonBab
//
//  Created by 김범수 on 2021/10/18.
//

import Foundation
import RxSwift
import RxCocoa
import Action
class CategoryViewModel: CommonViewModel, PostsHasViewModel {
    
    let bag = DisposeBag()
    
    // Model Subject
    let curUserSubject: BehaviorSubject<User>
    var postsSubject: BehaviorSubject<[Post]>

    // Fetch & Change
    let fetching: PublishRelay<Void>
    let reFetching: PublishRelay<Void>
    let scrolling: PublishSubject<Int>
    let activating: BehaviorSubject<Bool>
    
    init(sceneCoordinator: SceneCoordinator, sort: SortingType, category: String) {
        
        // Model Subject
        curUserSubject = Service.shared.curUserSubject
        postsSubject = BehaviorSubject<[Post]>(value: [])

        // Fetch & Change
        fetching = PublishRelay<Void>()
        reFetching = PublishRelay<Void>()
        scrolling = PublishSubject<Int>()
        activating = BehaviorSubject<Bool>(value: false)
        
        super.init(sceneCoordinator: sceneCoordinator)
        print("@@@@@@ CategoryViewModel Init @@@@@@")
        
        let fetchingCnt: UInt = 8
        let defaultDate = "2099-99-99-99-99-99"
        
        fetching
            .withLatestFrom(Observable.combineLatest(curUserSubject, postsSubject))
            .do(onNext: { [unowned self] _ in self.activating.onNext(true) })
            .flatMap { [unowned self] curUser, posts -> Observable<[Post]> in
                switch sort {
                case .postDate:
                    return Service.shared.fetchPostDatePosts(category: category, lastDate: posts.last?.postDate ?? defaultDate, fetchingCnt: fetchingCnt)
                case .promiseDate:
                    return Service.shared.fetchPromiseDatePosts(category: category, lastDate: posts.last?.promiseDate ?? defaultDate, fetchingCnt: fetchingCnt)
                case .distance:
                    let curPosition = curUser.curPosition ?? "0-0"
                    return Service.shared.fetchDistancePosts(curPos: curPosition, category: category, lastDistance: posts.last?.calDistance(curUserPos: curPosition) ?? 0.0, fetchingCnt: fetchingCnt)
                }
            }
            .do(onNext: { [unowned self] _ in self.activating.onNext(false) })
            .bind(to: postsSubject)
            .disposed(by: bag)
        
        reFetching
            .withLatestFrom(Observable.combineLatest(postsSubject, curUserSubject))
            .subscribe(onNext : { [unowned self] (posts, curUser) in
                switch sort{
                case .postDate:
                    Service.shared.fetchPostDatePosts(category: category, lastDate: posts.last?.postDate ?? defaultDate, fetchingCnt: fetchingCnt)
                        .map { posts + $0 }
                        .bind(to: self.postsSubject)
                        .disposed(by: self.bag)
                case .promiseDate:
                    Service.shared.fetchPromiseDatePosts(category: category, lastDate: posts.last?.promiseDate ?? defaultDate, fetchingCnt: fetchingCnt)
                        .map { posts + $0 }
                        .bind(to: self.postsSubject)
                        .disposed(by: self.bag)
                case .distance:
                    let curPosition = curUser.curPosition ?? "0-0"
                    Service.shared.fetchDistancePosts(curPos: curPosition, category: category, lastDistance: posts.last?.calDistance(curUserPos: curPosition) ?? 0.0, fetchingCnt: fetchingCnt)
                        .map { posts + $0 }
                        .bind(to: self.postsSubject)
                        .disposed(by: self.bag)
                }
            })
            .disposed(by: bag)
    }
    
    func pushPostVC(post: Post, viewModel: PostsHasViewModel) -> CocoaAction {
        return CocoaAction { [unowned self] _ in
            let postVM = PostViewModel(sceneCoordinator: self.sceneCoordinator, post: post, otherVM: viewModel)
            let postScene = Scene.post(postVM)
            return self.sceneCoordinator.transition(to: postScene, using: .push, animated: true).asObservable().map { _ in }
        }
    }
    
    deinit {
        print("@@@@@@ CategoryViewModel Deinit @@@@@@")
    }
    
}
