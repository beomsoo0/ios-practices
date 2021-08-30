//
//  Model.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/17.
//

import UIKit

class User {
    
    static var currentUser: User!
    
    var uid: String
    var id: String
    var name: String
    var profileImage: UIImage
    var description: String
    var followers: [String] //Uid
    var follows: [String] // Uid
    var posts: [Post]
    
    init(uid: String, id: String, name: String) {
        self.uid = uid
        self.id = id
        self.name = name
        profileImage = UIImage(named: "default_profile")!
        description = ""
        followers = []
        follows = []
        posts = []
    }
    
}
extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid
    }
}
    
class Post {
    var user: User
    var cuid: String
    var image: UIImage
    var content: String
    var likes: [String]
    var comments: [Comment]
    
    init(user: User, cuid: String, image: UIImage, content: String) {
        self.user = user
        self.cuid = cuid
        self.image = image
        self.content = content
        likes = []
        comments = []
    }
}

extension Post: Equatable {
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.cuid == rhs.cuid
    }
}

struct Comment {
    var uid: String
    var ment: String
    
    init(uid: String, ment: String) {
        self.uid = uid
        self.ment = ment
    }
}
