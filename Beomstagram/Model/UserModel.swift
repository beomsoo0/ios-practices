//
//  UserModel.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit

class UserModel {
    var userInfo = UserInfo()
    var profileContent = ContentModel()
    var contents: [ContentModel] = []
}

class UserInfo {
    var email: String?
    var id: String?
    var name: String?
    var follower: Int?
    var follow: Int?
}

class ContentModel {
    var image: UIImage?
    var cuid: String?
    var comment: String?
    var time: TimeInterval?
}

class AllContentModel {
    var userInfo = UserInfo()
    var content = ContentModel()
}
