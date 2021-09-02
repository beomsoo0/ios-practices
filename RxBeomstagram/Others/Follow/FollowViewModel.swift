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
    var userSubject: BehaviorSubject<User> { get }
    var followState: BehaviorSubject<Bool> { get }
}

class FollowViewModel: FollowViewModelType {
    
    var followSubject = BehaviorSubject<[User]>(value: [])
    var followerSubject = BehaviorSubject<[User]>(value: [])
    
    var userSubject: BehaviorSubject<User>
    var followState: BehaviorSubject<Bool>
    
    init(isFollow: Bool = false, user: User = User()) {
        
        userSubject = BehaviorSubject<User>(value: user)
        followState = BehaviorSubject<Bool>(value: isFollow)
        
    }
    
}
