//
//  Service.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/09/09.
//

import UIKit
import RxSwift
import RxCocoa
import FirebaseDatabase

class Service {
    
    static let shared = Service()
    let ref = Database.database().reference()
    let disposeBag = DisposeBag()
    
    var curUserSubject = BehaviorSubject<User>(value: User())
    var storyUserSubject = BehaviorSubject<[User]>(value: [])
    var feedPostsSubject = BehaviorSubject<[Post]>(value: [])
    var allPostsSubject = BehaviorSubject<[Post]>(value: [])
    
    func fetchUser(uid: String) -> BehaviorSubject<User> {
    
        let userSubject = BehaviorSubject<User>(value: User())
        
        ref.child("userinfo").child(uid).observeSingleEvent(of: .value) { (uidSnapShot) in

            let user = User()
            
            guard let values = uidSnapShot.value as? [String: Any] else {
                return
            }
            
            guard let uid = values["uid"] as? String,
                  let id = values["id"] as? String,
                  let name = values["name"] as? String else {
                return
            }
            
            user.uid = uid
            user.id = id
            user.name = name
            
            if let imgURL = values["profileImageURL"] as? String
            {
                self.downloadImage(url: imgURL) { image in
                    user.profileImage = image
                    userSubject.onNext(user)
                }
            }
            
            if let description = values["description"] as? String {
                user.description = description
            }
            
            // follower
            var followers = [String]()
            if let followerDic = values["follower"] as? [String: String] {
                for fuidDic in followerDic {
                    let followerUid = fuidDic.value
                    followers.append(followerUid)
                }
            }
            user.followers = followers
            
            // follow
            var follows = [String]()
            if let followDic = values["follow"] as? [String: String] {
                for fuidDic in followDic {
                    let followUid = fuidDic.value
                    follows.append(followUid)
                }
            }
            user.follows = follows
            
            // Posts
            var postsSubject = BehaviorSubject<[Post]>(value: [])
            postsSubject = self.fetchUserPosts(user: user, uid: uid)
            
            postsSubject.subscribe(onNext: {
                user.posts = $0
            })
            .disposed(by: self.disposeBag)
            
        }
        return userSubject
    }
    
    func fetchStoryUsers() {
        
        var users = [User]()
        
        curUserSubject
            .subscribe(onNext: { user in
                if user.name != "Default Name" {
                    users.append(user)
                    self.storyUserSubject.onNext(users)
                }
                
                user.follows.forEach { uid in
                    self.fetchUser(uid: uid)
                        .subscribe(onNext: { user in
                            if user.name != "Default Name" {
                                users.append(user)
                                self.storyUserSubject.onNext(users)
                            }
                        })
                        .disposed(by: self.disposeBag)
                }
            })
            .disposed(by: disposeBag)

    }
    
    func fetchUserPosts(user: User, uid: String) -> BehaviorSubject<[Post]> {
        
        let postsSubject = BehaviorSubject<[Post]>(value: [])
        var posts = [Post]()
        // posts 없을 시 예외처리
        ref.child("userinfo").child(uid).observeSingleEvent(of: .value) { (uidSnapShot) in
            if uidSnapShot.hasChild("posts") == false {
                return
            }
        }
        ref.child("userinfo").child(uid).child("posts").observeSingleEvent(of: .value) { (cuidSnapShot) in
    
            for postSnapShot in cuidSnapShot.children.allObjects as! [DataSnapshot]{
                guard let values = postSnapShot.value as? [String: Any],
                      let imgURL = values["imageURL"] as? String else {
                    return
                }
                
                let post = Post()
                post.user = user
                
                self.downloadImage(url: imgURL) { image in
                    post.image = image
                        posts.append(post)
                    postsSubject.onNext(posts)
                }
                
                guard let cuid = values["cuid"] as? String else { return }
                post.cuid = cuid
                
                if let content = values["content"] as? String {
                    post.content = content
                }
                
                // likes
                var likes = [String]()
                if let likesDic = values["likes"] as? [String: String] {
                    for likeDic in likesDic {
                        let likeUid = likeDic.value
                        likes.append(likeUid)
                    }
                }
                post.likes = likes
                
                var comments = [Comment]()
                if let commentsUids = values["comment"] as? [String: [String: String]] {
                    
                    for commentDic in commentsUids.values {
                        commentDic.forEach({ key, value in
                            let comment = Comment(uid: key, ment: value)
                            comments.append(comment)
                        })
                    }
                }
                post.comments = comments

            }
        }
        return postsSubject
    }
    
    func fetchFeedPosts() {
        
        var posts = [Post]()
        
        curUserSubject
            .subscribe(onNext: { user in
                user.follows.forEach { uid in
                    
                    self.fetchUser(uid: uid)
                        .subscribe(onNext: { u in
                            if u.name != "Default Name"
                            {
                                self.fetchUserPosts(user: u, uid: uid)
                                    .subscribe(onNext: { userPosts in
                                        
                                        userPosts.forEach { post in
                                            if !posts.contains(post) {
                                                posts.append(post)
                                            }
                                        }
                                        
                                        posts.sort { $0.cuid > $1.cuid }
                                
                                        self.feedPostsSubject.onNext(posts)
                                    })
                                    .disposed(by: self.disposeBag)
                            }
                            
                        })
                        .disposed(by: self.disposeBag)
                }
            })
            .disposed(by: self.disposeBag)
        
    }
    
    
    func fetchAllPosts() {
        
        var posts = [Post]()
        
        ref.child("userinfo").observeSingleEvent(of: .value) { userinfoSnapShot in
            // uid마다
            for uidSnapShot in userinfoSnapShot.children.allObjects as! [DataSnapshot]{
                let uid = uidSnapShot.key
             
                self.fetchUser(uid: uid)
                    .subscribe(onNext: { u in
                        if u.name != "Default Name" {
                            self.fetchUserPosts(user: u, uid: uid)
                                .subscribe(onNext: { userPosts in
                                    userPosts.forEach { p in
                                        if !posts.contains(p) {
                                            posts.append(p)
                                        }
                                        posts.sort { $0.cuid > $1.cuid }
                                        self.allPostsSubject.onNext(posts)
                                    }
                                })
                                .disposed(by: self.disposeBag)
                        }
                    })
                    .disposed(by: self.disposeBag)
            }
        }
    }
        
    private func downloadImage(url: String?, completion: @escaping (UIImage) -> Void) {
        if let imgURL = url {
            URLSession.shared.dataTask(with: URL(string: imgURL)!) {
                data, _, error in
                if let data = data {
                    completion(UIImage(data: data) ?? UIImage(named: "default_profile")!)
                }
            }.resume()
        } else {
            completion(UIImage(named: "default_profile")!)
        }
    }

}
