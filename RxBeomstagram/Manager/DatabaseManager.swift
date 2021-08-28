//
//  DatabaseManager.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/17.
//

import FirebaseDatabase


public class DatabaseManager {
    
    static let shared = DatabaseManager()
    let ref = Database.database().reference()
    
    // MARK - Create User
    func insertNewUser(uid: String, email: String, name: String, id: String) {
        ref.child("userinfo").child(uid).setValue(["uid": uid, "email": email.safetyEmail(), "name": name, "id": id])
    }
    
    func fetchUser(uid: String, completion: @escaping (User) -> Void) {
        ref.child("userinfo").child(uid).observeSingleEvent(of: .value) { (uidSnapShot) in
            let values = uidSnapShot.value as? [String: Any]
            
            // email[o], id[o], name[o], profileImage[o], description[x], followers[x], follows[x], posts[o]
            
            guard let uid = values?["uid"] as? String,
                  let id = values?["id"] as? String,
                  let name = values?["name"] as? String else {
                return
            }
            let user = User(uid: uid, id: id, name: name)

            let imgURL = values?["profileImageURL"] as? String
            self.downloadImage(url: imgURL) { image in
                user.profileImage = image
                
                //description
                if let description = values?["description"] as? String { user.description = description }
                
                // follower
                var followers = [String]()
                if let followerDic = values?["follower"] as? [String: String] {
                    for fuidDic in followerDic {
                        let followerUid = fuidDic.value
                        followers.append(followerUid)
                    }
                }
                user.followers = followers
                
                // follow
                var follows = [String]()
                if let followDic = values?["follow"] as? [String: String] {
                    for fuidDic in followDic {
                        let followUid = fuidDic.value
                        follows.append(followUid)
                    }
                }
                user.follows = follows
                
                // posts
                self.fetchUserPosts(user: user, uid: uid) { posts in
                    user.posts = posts
                    completion(user)
                }
            }
        }
    }
    
    func fetchOtherUsers(completion: @escaping ([User]) -> Void) {
        ref.child("userinfo").observeSingleEvent(of: .value) { (infoSnapShot) in
            var users = [User]()
            for uidSnapShot in infoSnapShot.children.allObjects as! [DataSnapshot] {
                let values = uidSnapShot.value as? [String: Any]
                // email[o], id[o], name[o], profileImage[o], description[o], followers[x], follows[x], posts[o]
                
                // email, id, name
                guard let uid = values?["uid"] as? String,
                      let id = values?["id"] as? String,
                      let name = values?["name"] as? String else {
                    return
                }
                
                if uid != User.currentUser.uid {
                    
                    let user = User(uid: uid, id: id, name: name)

                    let imgURL = values?["profileImageURL"] as? String
                    self.downloadImage(url: imgURL) { image in
                        user.profileImage = image
                        
                        //description
                        if let description = values?["description"] as? String { user.description = description }
                        
                        // follower
                        var followers = [String]()
                        if let followerDic = values?["follower"] as? [String: String] {
                            for fuidDic in followerDic {
                                let followerUid = fuidDic.value
                                followers.append(followerUid)
                            }
                        }
                        user.followers = followers
                        
                        // follow
                        var follows = [String]()
                        if let followDic = values?["follow"] as? [String: String] {
                            for fuidDic in followDic {
                                let followUid = fuidDic.value
                                follows.append(followUid)
                            }
                        }
                        user.follows = follows
                        
                        // posts
                        self.fetchUserPosts(user: user, uid: uid) { posts in
                            user.posts = posts
                            completion(users)
                        }
                        users.append(user)
                    }
                    
                    
                }
                
                
            }
        }
    }
    
    private func downloadImage(url: String?, completion: @escaping (UIImage) -> Void) {
        if let imgURL = url {
            URLSession.shared.dataTask(with: URL(string: imgURL)!) {
                data, _, error in
                if let data = data {
                    completion(UIImage(data: data)!)
                }
            }.resume()
        } else {
            completion(UIImage(named: "default_profile")!)
        }
    }
    
    
    // MARK - Post
    func uploadPost(image: UIImage, content: String?, completion: @escaping (Bool) -> Void) {
        guard let uid = AuthManager.shared.currentUid(),
              let cuid = ref.child("posts").child(uid).childByAutoId().key else {
            completion(false)
            return
        }
        StorageManager.shared.uploadImageToStorage(cuid: cuid, image: image, completion: { result in
            switch result {
            case .success(let url):
                self.ref.child("userinfo").child(uid).child("posts").child(cuid).setValue(["cuid": cuid, "imageURL": url.absoluteString, "content": content ?? ""/*, "time": ServerValue.timestamp()*/])
                completion(true)
                return
            case .failure(let error):
                print(error)
                completion(false)
                return
            }
        })
    }
    
    func fetchUserPosts(user: User, uid: String, completion: @escaping ([Post]) -> Void) {
        var posts = [Post]()
        // posts 없을 시 예외처리
        ref.child("userinfo").child(uid).observeSingleEvent(of: .value) { (uidSnapShot) in
            if uidSnapShot.hasChild("posts") == false {
                completion(posts)
            }
        }
        ref.child("userinfo").child(uid).child("posts").observeSingleEvent(of: .value) { (cuidSnapShot) in
            for postSnapShot in cuidSnapShot.children.allObjects as! [DataSnapshot]{
                let values = postSnapShot.value as? [String: Any]
                let imgURL = values?["imageURL"] as? String
                self.downloadImage(url: imgURL) { image in
                    
                    // cuid, image, content
                    if let cuid = values?["cuid"] as? String,
                        let content = values?["content"] as? String {
                        
                        var post = Post(user: user, cuid: cuid, image: image, content: content)
                        
                        // likes
                        var likes = [String]()
                        if let likesDic = values?["likes"] as? [String: String] {
                            for likeDic in likesDic {
                                let likeUid = likeDic.value
                                likes.append(likeUid)
                            }
                        }
                        post.likes = likes
                        
                        var comments = [Comment]()
                        if let commentsUids = values?["comment"] as? [String: [String: String]] {
                            
                            for commentDic in commentsUids.values {
                                commentDic.forEach({ key, value in
                                    let comment = Comment(uid: key, ment: value)
                                    comments.append(comment)
                                })
                            }
                        }
                        post.comments = comments
                        
                        posts.append(post)
                        completion(posts)
                    }
                }
            }
        }
        
    }
    
    func fetchAllPosts(completion: @escaping ([Post]) -> Void) {
        var posts = [Post]()
        
        ref.child("userinfo").observeSingleEvent(of: .value) { userinfoSnapShot in
            // uid마다
            for uidSnapShot in userinfoSnapShot.children.allObjects as! [DataSnapshot]{
                let uid = uidSnapShot.key
                let userinfoDic = uidSnapShot.value as? [String: Any]
                
                if let cuidDic = userinfoDic?["posts"] as? [String: [String: Any]] {

                    for dic in cuidDic {
                        let imgURL = dic.value["imageURL"] as? String
                        self.downloadImage(url: imgURL) { image in
                            // user
                            self.fetchUser(uid: uid) { user in
                                // cuid, image, content
                                if let cuid = dic.value["cuid"] as? String,
                                   let content = dic.value["content"] as? String {
                                    
                                    var post = Post(user: user, cuid: cuid, image: image, content: content)
                                    
                                    // likes
                                    var likes = [String]()
                                    if let likesDic = dic.value["likes"] as? [String: String] {
                                        for likeDic in likesDic {
                                            let likeUid = likeDic.value
                                            likes.append(likeUid)
                                        }
                                    }
                                    post.likes = likes
                                    
                                    var comments = [Comment]()
                                    if let commentsUids = dic.value["comment"] as? [String: [String: String]] {
                                        
                                        for commentDic in commentsUids.values {
                                            commentDic.forEach({ key, value in
                                                let comment = Comment(uid: key, ment: value)
                                                comments.append(comment)
                                                
                                                
                                            })
                                        }
                                    }
                                    post.comments = comments
                                    
                                    posts.append(post)
                                    completion(posts)
                                }
                            }
                        }
                    }
                    
                }
                
            }
        }
    }
    
    // MARK - Profile
    public func editProfile(image: UIImage, description: String, name: String, id: String, completion: @escaping (Bool) -> Void) {
        guard let uid = AuthManager.shared.currentUid(),
              let cuid = ref.child("contents").child(uid).childByAutoId().key else {
            completion(false)
            return
        }
        StorageManager.shared.uploadImageToStorage(cuid: cuid, image: image, completion: { result in
            switch result {
            case .success(let url):
                self.ref.child("userinfo").child(uid).updateChildValues(["profileImageURL": url.absoluteString, "description": description, "name": name, "id": id])
                completion(true)
                return
            case .failure(let error):
                print(error)
                completion(false)
                return
            }
        })
    }
    
    func updateFollow(from: User, to: User, completion: @escaping () -> Void) {
        // follower
        let followerRef = ref.child("userinfo").child(to.uid).child("follower")
        followerRef.updateChildValues([from.name: from.uid])
        // follow
        let followRef = ref.child("userinfo").child(from.uid).child("follow")
        followRef.updateChildValues([to.name: to.uid])
//        followRef.setValue([to.name: to.uid])
    }
    
    func deleteFollow(from: User, to: User, completion: @escaping () -> Void) {
        // follower
        ref.child("userinfo").child(to.uid).child("follower").child(from.name).removeValue()
        // follow
        ref.child("userinfo").child(from.uid).child("follow").child(to.name).removeValue()
    }
    
    func updateLike(from: User, to: User, cuid: String, completion: @escaping () -> Void) {
        ref.child("userinfo").child(to.uid).child("posts").child(cuid).child("likes").updateChildValues([from.name: from.uid])
    }
    
    func deleteLike(from: User, to: User, cuid: String, completion: @escaping () -> Void) {
        ref.child("userinfo").child(to.uid).child("posts").child(cuid).child("likes").child(from.name).removeValue()
    }

    func pushComment(from: User, to: Post, comment: String, completion: @escaping () -> Void) {
        guard let commentUid = ref.child("userinfo").child(to.user.uid).child("posts").child(to.cuid).child("comment").childByAutoId().key else {
            completion()
            return
        }
        ref.child("userinfo").child(to.user.uid).child("posts").child(to.cuid).child("comment").child(commentUid).setValue([from.uid: comment])
    }

}

