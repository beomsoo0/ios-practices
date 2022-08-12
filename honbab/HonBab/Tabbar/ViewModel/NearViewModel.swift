//
//  NearViewModel.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/20.
//

import Foundation
import RxSwift
import RxCocoa
import NMapsMap
import Action

class NearViewModel: CommonViewModel, PostsHasViewModel {
    
    let bag = DisposeBag()
    let curUserSubject: BehaviorSubject<User>
    var mapPostsSubject: BehaviorSubject<[MapPost]>
    var postsSubject: BehaviorSubject<[Post]>
    let curPositionSubject: PublishSubject<String>
    
    let curBoundsSubject: PublishSubject<NMGLatLngBounds>
    
    override init(sceneCoordinator: SceneCoordinator) {
        curUserSubject = Service.shared.curUserSubject
        
        mapPostsSubject = BehaviorSubject<[MapPost]>(value: [])
        curPositionSubject = PublishSubject<String>()
        postsSubject = BehaviorSubject<[Post]>(value: [])
        
        curBoundsSubject = PublishSubject<NMGLatLngBounds>()
        
        super.init(sceneCoordinator: sceneCoordinator)
        print("@@@@@@ NearViewModel Init @@@@@@")
        
        // 첫위치 전송
        curUserSubject
            .take(2) //첫번은 default
            .withLatestFrom(Observable.combineLatest(curUserSubject, curPositionSubject))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] (user, position) in
                user.curPosition = position
                self.curUserSubject.onNext(user)
            })
            .disposed(by: bag)
            
        curBoundsSubject
            .subscribe(onNext: { [unowned self] bounds in
                Service.shared.fetchInMapPosts(bounds: bounds)
                    .subscribe({ [unowned self] success in
                        switch success {
                        case .success(let mapPosts):
                            self.mapPostsSubject.onNext(mapPosts)
                        case .error(_):
                            break
                        }
                    })
                    .disposed(by: self.bag)
            })
            .disposed(by: bag)
        
    }
    
    func pushPostVC(post: Post, nearVM: NearViewModel) -> CocoaAction {
        return CocoaAction { [unowned self] _ in            
            let postVM = PostViewModel(sceneCoordinator: self.sceneCoordinator, post: post, otherVM: nearVM)
            let postScene = Scene.post(postVM)
            return self.sceneCoordinator.transition(to: postScene, using: .push, animated: true).asObservable().map { _ in }
        }
    }
    
    
    deinit {
        print("@@@@@@ NearViewModel Deinit @@@@@@")
    }
}
