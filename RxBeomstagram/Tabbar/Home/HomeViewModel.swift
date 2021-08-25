//
//  HomeViewModel.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/18.
//

import Foundation

class HomeViewModel {
    
    var posts = [Post]()
    var users = [User]()
    init() {
        DatabaseManager.shared.fetchAllPosts { [weak self] posts in
            self?.posts = posts
        }
        DatabaseManager.shared.fetchAllUser { [weak self] users in
            self?.users = users
        }
    }
}
