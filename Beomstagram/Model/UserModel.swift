//
//  UserModel.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit

struct UserModel {
    var id: String?
    var name: String?
    var email: String?
    var follower: Int?
    var follow: Int?
    var contents: [ContentModel] = []
    
}

struct ContentModel {
    var image: UIImage?
    var cuid: String?
    var comment: String?
}
