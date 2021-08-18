//
//  Model.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/17.
//

import UIKit

struct User {
    var email: String
    var id: String
    var name: String
    var profileImage: UIImage
    var description: String
    var follower: [User]
    var follow: [User]
    var posts: [Post]
    
    init() {
        email = "default Email"
        id = "default ID"
        name = "default Name"
        profileImage = UIImage(named: "default_profile")!
        description = "default description"
        follower = []
        follow = []
        posts = []
    }
}

struct Post {
    var image: UIImage
    var content: String
    var comment: [String]
    var like: Int
    var postTime: Date
    
    init() {
        image = UIImage(named: "default_profile")!
        content = "default content"
        comment = []
        like = -1
        postTime = Date()
    }
}
