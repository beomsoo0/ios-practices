//
//  HomeViewModel.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/18.
//

import Foundation

class HomeViewModel {
    
    var posts = [Post]()
    
    init() {
        DatabaseManager.shared.fetchAllPosts { [weak self] posts in
            self?.posts = posts
        }
    }
}
