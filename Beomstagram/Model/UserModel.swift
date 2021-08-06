//
//  UserModel.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit

class UserModel {
    
    static var shared = UserModel()
    
    var userInfo: UserInfo?
    var contents: [ContentModel] = []
}

struct UserInfo {
    var id: String?
    var name: String?
    var email: String?
    var follower: Int?
    var follow: Int?
}

struct ContentModel {
    var image: UIImage?
    var cuid: String?
    var comment: String?
}

class AllContentsModel {
    
    static let shared = AllContentsModel()
    
    var contents: [ContentModel] = []
}

class AllUserModel {
    
    static let shared = AllUserModel()
    
    var userModels: [UserModel] = []
}
