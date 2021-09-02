//
//  SearchViewModel.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/29.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewModel {
    
    var postsObservable = BehaviorSubject<[Post]>(value: [])
    
    init() {
        
        postsObservable = Post.allPostsRx

    }
    
    
}
