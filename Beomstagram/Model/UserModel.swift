//
//  UserModel.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit

class UserModel {
    var userInfo = UserInfoModel()
    var profileContent = ContentModel()
    var contents: [ContentModel] = []
}

class UserInfoModel {
    
    static var shared = UserInfoModel()
    
    var email: String?
    var id: String?
    var name: String?
    var follower: Int?
    var follow: Int?
    var profile = ContentModel()
//    private init() {
//
//    }
}

class ContentModel {
    var image: UIImage?
    var cuid: String?
    var comment: String?
    var time: TimeInterval?
}

class AllContentModel {
    var userInfo = UserInfoModel()
    var content = ContentModel()
}
