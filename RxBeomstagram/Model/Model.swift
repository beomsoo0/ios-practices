//
//  Model.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/17.
//

import UIKit

struct User {
    var userName: String
    var profileImage: UIImage
    var description: String
    var follower: [User]
    var follow: [User]
    var posts: [Post]

}

struct Post {
    var image: UIImage
    var content: String
    var comment: [String]
    var like: Int
    var postTime: Date
}
