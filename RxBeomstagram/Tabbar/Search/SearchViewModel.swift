//
//  SearchViewModel.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/24.
//

import Foundation

class SearchViewModel {
    
    
    
    init() {
        DatabaseManager.shared.fetchAllPosts { [weak self] posts in
            self?.posts = posts
        }
    }
}
