//
//  ProfileViewModel.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/20.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import NMapsMap



class ProfileViewModel: CommonViewModel, PostsHasViewModel {
    let bag = DisposeBag()
    let curUserSubject: BehaviorSubject<User>
    let myPostsSubject: BehaviorSubject<[Post]>
    let promisePostsSubject: BehaviorSubject<[Post]>
    var postsSubject: BehaviorSubject<[Post]>
    let selected: BehaviorRelay<ProfilePostType>
    
    override init(sceneCoordinator: SceneCoordinator) {
        curUserSubject = Service.shared.curUserSubject
        myPostsSubject = BehaviorSubject<[Post]>(value: [])
        promisePostsSubject = BehaviorSubject<[Post]>(value: [])
        postsSubject = BehaviorSubject<[Post]>(value: [])
        selected = BehaviorRelay<ProfilePostType>(value: .myPost)
        
        super.init(sceneCoordinator: sceneCoordinator)
        print("@@@@@@ ProfileViewModel Init @@@@@@")
        
        curUserSubject
            .subscribe(onNext: { [unowned self] curUser in
                // 내 게시물 Fetching
                var myPosts = [Post]()
                curUser.postPuids
                    .forEach { [unowned self] puid in
                        Service.shared.fetchPost(puid: puid)
                            .subscribe(onNext: { [unowned self] post in
                                myPosts.append(post)
                                self.myPostsSubject.onNext(myPosts)
                            })
                            .disposed(by: self.bag)
                    }
                // 약속 게시물 Fetching
                var promisePosts = [Post]()
                curUser.promisePuids
                    .forEach { [unowned self] puid in
                        Service.shared.fetchPost(puid: puid)
                            .subscribe(onNext: { [unowned self] post in
                                promisePosts.append(post)
                                self.promisePostsSubject.onNext(promisePosts)
                            })
                            .disposed(by: self.bag)
                    }
            })
            .disposed(by: bag)
        
        selected
            .subscribe(onNext: { [unowned self] display in
                switch display {
                case .myPost:
                    self.myPostsSubject
                        .bind(to: self.postsSubject)
                        .disposed(by: self.bag)
                case .promise:
                    self.promisePostsSubject
                        .bind(to: self.postsSubject)
                        .disposed(by: self.bag)
                case .like:
                    self.postsSubject.onNext([])
                }
            })
            .disposed(by: bag)
        
    }

    func pushPostVC(post: Post, profileVM: ProfileViewModel) -> CocoaAction {
        return CocoaAction { [unowned self] _ in
            let postVM = PostViewModel(sceneCoordinator: self.sceneCoordinator, post: post, otherVM: profileVM)
            let postScene = Scene.post(postVM)
            return self.sceneCoordinator.transition(to: postScene, using: .push, animated: true).asObservable().map { _ in }
        }
    }
    
    func pushSettingVC() -> CocoaAction {
        return CocoaAction { [unowned self] in
            let settingVM = SettingViewModel(sceneCoordinator: self.sceneCoordinator)
            let settingScene = Scene.setting(settingVM)
            return self.sceneCoordinator.transition(to: settingScene, using: .push, animated: true).asObservable().map { _ in}
        }
    }
    
    deinit {
        print("@@@@@@ ProfileViewModel Deinit @@@@@@")
    }
}
