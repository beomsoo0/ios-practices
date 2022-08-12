//
//  Model.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/17.
//

import UIKit
import RxSwift
import RxCocoa


class User {
    
    static var currentUser = User()
    static var currentUserRx = BehaviorSubject<User>(value: User())
    static var allUserRx = BehaviorSubject<[User]>(value: [])
    
    var uid: String
    var id: String
    var name: String
    var profileImage: UIImage
    var description: String
    var followers: [String] //Uid
    var follows: [String] // Uid
    var posts: [Post]
    
    var followerUsers = [User]()
    var followUsers = [User]()
    
    init() {
        uid = "Default UID"
        id = "Default ID"
        name = "Default Name"
        profileImage = UIImage(named: "default_profile")!
        description = "Default Description"
        followers = []
        follows = []
        posts = []
    }
    
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
    
    func fetchFollowUsers() {
        self.followers.forEach { uid in
            DatabaseManager.shared.fetchUser(uid: uid) { followers in
                self.followerUsers.append(followers)
                print("@@@@@@@", followers)
            }
        }
        self.follows.forEach { uid in
            DatabaseManager.shared.fetchUser(uid: uid) { follows in
                self.followUsers.append(follows)
            }
        }
    }
    
    
}
extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid
    }
}
    
class Post {
    
    static var allPostsRx = BehaviorSubject<[Post]>(value: [])
    
    var user: User
    var cuid: String
    var image: UIImage
    var content: String
    var likes: [String]
    var comments: [Comment]
    
    init() {
        user = User()
        cuid = "Default CUID"
        image = UIImage(named: "default_profile")!
        content = "Default Content"
        likes = []
        comments = []
    }
    
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

class Comment {
    var uid: String
    var ment: String
    var user = User()
    
    init(uid: String, ment: String) {
        self.uid = uid
        self.ment = ment
    }
    
    func fetchCommentUser() {
        DatabaseManager.shared.fetchUser(uid: uid) { user in
            self.user = user
        }
    }
}
