//
//  SearchViewModel.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/12.
//

import Foundation

class SearchViewModel {
    
    var postModel = [UserModel]()
    
    func loadPostModel(completion: @escaping () -> Void) {
        DatabaseManager.shared.fetchAllContentModel(completion: { [weak self] UserModels in
            self?.postModel = UserModels
            completion()
        })
    }
    
}
