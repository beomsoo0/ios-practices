//
//  ProfileViewModel.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/12.
//

import Foundation

class PriofileViewModel {
    
    var profileModel = [ContentModel]()
    
    func loadProfileModel(completion: @escaping () -> Void) {
        DatabaseManager.shared.fetchCurrentUserContents { [weak self] Contents in
            self?.profileModel = Contents
            completion()
        }
    }
}
