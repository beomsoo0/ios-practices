//
//  UserModel.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit

//게시물
class ContentModel {
    var image: UIImage?
    var cuid: String?
    var comment: String?
    var time: TimeInterval?
}
class UserInfoModel {
    var email: String?
    var id: String?
    var name: String?
    var follower: Int?
    var follow: Int?
}

//유저정보 && 해당 유저의 게시물들
class UserModel {
    
    static var shared = UserModel() // cur User
    
    var userInfo = UserInfoModel()
    var content = ContentModel()
}
