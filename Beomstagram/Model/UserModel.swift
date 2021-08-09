//
//  UserModel.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit

class UserModel {
    
    static var shared = UserModel()
    
    var userInfo = UserInfo()
    var contents = [ContentModel]()
}

struct UserInfo {
    var email: String?
    var id: String?
    var name: String?
    var follower: Int?
    var follow: Int?
}

struct ContentModel {
    var image: UIImage?
    var cuid: String?
    var comment: String?
}

class PostContentsModel {
    var userInfo = UserInfo()
    
    var cuid: String?
    var image: UIImage?
    var comment: String?
    var like: Int?
}
