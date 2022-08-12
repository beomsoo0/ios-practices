//
//  HomeViewModel.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/12.
//

import Foundation

class HomeViewModel {
    
    let databaseManager = DatabaseManager.shared

    var postModel = [UserModel]()
    var storyModel = [UserModel]()
    
    func loadPostModel(completion: @escaping () -> Void) {
        databaseManager.fetchAllContentModel(completion: { [weak self] UserModels in
            self?.postModel = UserModels
            completion()
        })
    }
    
    func loadStoryModel(completion: @escaping () -> Void) {
        databaseManager.fetchAllUserModel(completion: { [weak self] UserModels in
            self?.storyModel = UserModels
            completion()
        })
    }
    
}
