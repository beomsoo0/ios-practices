//
//  ProfileViewModel.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/18.
//

import Foundation
import RxSwift

class ProfileViewModel {

    var currentUser = User()
    
    init() {
        DatabaseManager.fetchCurrentUser { [weak self] user in
            self?.currentUser = user
        }
        
    }
}
