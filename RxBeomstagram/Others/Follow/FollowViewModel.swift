//
//  FollowViewModel.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/09/01.
//

import UIKit
import RxSwift
import RxCocoa

protocol FollowViewModelType {
    var followSubject: BehaviorSubject<[User]> { get }
    var followerSubject: BehaviorSubject<[User]> { get }
}

class FollowViewModel: FollowViewModelType {
    
    var followSubject = BehaviorSubject<[User]>(value: [])
    var followerSubject = BehaviorSubject<[User]>(value: [])
    
    init(isFollow: Bool = false, followUids: [String] = [], followerUids: [String] = []) {
        
        var followUsers: [User] = []
        for followUid in followUids {
            DatabaseManager.shared.fetchUser(uid: followUid) { [weak self] user in
                followUsers.append(user)
                self?.followSubject.onNext(followUsers)
            }
        }
        
        var followerUsers: [User] = []
        for followerUid in followerUids {
            DatabaseManager.shared.fetchUser(uid: followerUid) { [weak self] user in
                followerUsers.append(user)
                self?.followerSubject.onNext(followerUsers)
            }
        }
        
    }
    
}
