//
//  UserModel.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit

struct UserInfoModel {
    
    static var shared = UserModel()
    
    var email: String?
    var id: String?
    var name: String?
    var follower: Int?
    var follow: Int?
    var profileImage: UIImage?
    var comment: String?
}

struct UserModel {
    
    var email: String?
    var id: String?
    var name: String?
    var follower: Int?
    var follow: Int?
    var profileImage: UIImage?
    var comment: String?
}

class ContentModel {
    var image: UIImage?
    var cuid: String?
    var comment: String?
    var time: TimeInterval?
    
    var userInfo = UserModel()
}
