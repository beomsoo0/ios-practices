//
//  SearchViewModel.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/29.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewModel: CommonViewModel {
    
    var postsObservable = BehaviorSubject<[Post]>(value: [])
    
    override init(sceneCoordinator: SceneCoordinatorType) {
        
        postsObservable = Service.shared.allPostsSubject
        super.init(sceneCoordinator: sceneCoordinator)
    }
    
//    init() {
//
////        postsObservable = Post.allPostsRx
//        postsObservable = Service.shared.allPostsSubject
//    }
    
    
}
