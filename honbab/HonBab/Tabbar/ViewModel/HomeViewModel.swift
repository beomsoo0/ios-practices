//
//  HomeViewModel.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/20.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import NMapsMap

class HomeViewModel: CommonViewModel, PostsHasViewModel {
    let bag = DisposeBag()
    
    // Model Subject
    let curUserSubject: BehaviorSubject<User>
    var postsSubject: BehaviorSubject<[Post]>

    // Fetch & Change
    let fetching: PublishRelay<Void>
    let reFetching: PublishRelay<Void>
    let scrolling: PublishSubject<Int>
    let adding: PublishSubject<Post>
    let activating: BehaviorSubject<Bool>
    
    override init(sceneCoordinator: SceneCoordinator) {
        
        Service.shared.fetchUser(uid: AuthManager.shared.curUid()!)
            .bind(to: Service.shared.curUserSubject)
            .disposed(by: bag)
        
        // Model Subject
        curUserSubject = Service.shared.curUserSubject
        postsSubject = BehaviorSubject<[Post]>(value: [])

        // Fetch & Change
        fetching = PublishRelay<Void>()
        reFetching = PublishRelay<Void>()
        scrolling = PublishSubject<Int>()
        adding = PublishSubject<Post>()
        activating = BehaviorSubject<Bool>(value: false)
        
        super.init(sceneCoordinator: sceneCoordinator)
        print("@@@@@@ HomeViewModel Init @@@@@@")

        let category = "전부"
        let fetchingCnt: UInt = 8
        let defaultDate = "2099-99-99-99-99-99"

        fetching
            .do(onNext: { [unowned self] _ in self.activating.onNext(true) })
            .flatMap { _ in Service.shared.fetchPostDatePosts(category: category, lastDate: defaultDate, fetchingCnt: fetchingCnt) }
            .do(onNext: { [unowned self] _ in self.activating.onNext(false) })
            .bind(to: postsSubject)
            .disposed(by: bag)
        
        reFetching
            .withLatestFrom(postsSubject)
            .subscribe(onNext : { [unowned self] posts in
                Service.shared.fetchPostDatePosts(category: category, lastDate: posts.last?.postDate ?? defaultDate, fetchingCnt: fetchingCnt)
                    .subscribe(onNext: { [unowned self] fetchPosts in
                        self.postsSubject.onNext(posts + fetchPosts)
                    })
                    .disposed(by: self.bag)
            })
            .disposed(by: bag)
        
        adding
            .withLatestFrom(Observable.combineLatest(adding, postsSubject, curUserSubject))
            .subscribe(onNext: { [unowned self] (upLoad, posts, curUser) in
                var newPosts = posts
                newPosts.insert(upLoad, at: 0)
                self.postsSubject.onNext(newPosts)
                self.scrolling.onNext(0)
            })
            .disposed(by: bag)
                
    }

    func pushPostVC(post: Post, homeVM: HomeViewModel) -> CocoaAction {
        return CocoaAction { [unowned self] _ in
            let postVM = PostViewModel(sceneCoordinator: self.sceneCoordinator, post: post, otherVM: homeVM)
            let postScene = Scene.post(postVM)
            return self.sceneCoordinator.transition(to: postScene, using: .push, animated: true).asObservable().map { _ in }
        }
    }
    func pushAddPostVC(homeVM: HomeViewModel) -> CocoaAction {
        return CocoaAction { [unowned self] _ in
            let addPostVM = AddPostViewModel(sceneCoordinator: self.sceneCoordinator, homeVM: homeVM)
            let addPostScene = Scene.addPost(addPostVM)
            return self.sceneCoordinator.transition(to: addPostScene, using: .push, animated: true).asObservable().map { _ in }
        }
    }
    func pushSortVC(homeVM: HomeViewModel) -> CocoaAction {
        return CocoaAction { [unowned self] _ in
            let sortVM = SortViewModel(sceneCoordinator: self.sceneCoordinator)
            sortVM.homeVM = homeVM
            let sortScene = Scene.sort(sortVM)
            return self.sceneCoordinator.transition(to: sortScene, using: .push, animated: true).asObservable().map { _ in }
        }
    }
    
    
    deinit {
        print("@@@@@@ HomeViewModel Deinit @@@@@@")
    }
}
