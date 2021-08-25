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
    
    // MARK - User
    func insertNewUser(uid: String, email: String, name: String, id: String) {
        ref.child("userinfo").child(uid).setValue(["email": email.safetyEmail(), "name": name, "id": id])
    }
    
    func fetchUser(uid: String, completion: @escaping (User) -> Void) {
        ref.child("userinfo").child(uid).observeSingleEvent(of: .value) { (uidSnapShot) in
            let values = uidSnapShot.value as? [String: Any]
            let user = User()
            // email[o], id[o], name[o], profileImage[o], description[x], followers[x], follows[x], posts[o]
            
            // email, id, name
            if let email = values?["email"] as? String,
               let id = values?["id"] as? String,
               let name = values?["name"] as? String {
                user.email = email
                user.id = id
                user.name = name
            }
            // profileImage
            if let imgURL = values?["profileImageURL"] as? String {
                URLSession.shared.dataTask(with: URL(string: imgURL)!) {
                    data, _, error in
                    if let data = data {
                        user.profileImage = UIImage(data: data)!
                    }
                }.resume()
            }
            // description
            if let description = values?["description"] as? String { user.description = description }
            // posts
            self.fetchUserPosts(uid: uid) { posts in
                user.posts = posts
            }
            completion(user)
        }
    }
    
    func fetchAllUser(completion: @escaping ([User]) -> Void) {
        ref.child("userinfo").observeSingleEvent(of: .value) { (infoSnapShot) in
            var users = [User]()
            for uidSnapShot in infoSnapShot.children.allObjects as! [DataSnapshot] {
                let uid = uidSnapShot.key
                let values = uidSnapShot.value as? [String: Any]
                let user = User()
                // email[o], id[o], name[o], profileImage[o], description[x], followers[x], follows[x], posts[o]
                
                // email, id, name
                if let email = values?["email"] as? String,
                   let id = values?["id"] as? String,
                   let name = values?["name"] as? String {
                    user.email = email
                    user.id = id
                    user.name = name
                }
                // profileImage
                if let imgURL = values?["profileImageURL"] as? String {
                    URLSession.shared.dataTask(with: URL(string: imgURL)!) {
                        data, _, error in
                        if let data = data {
                            user.profileImage = UIImage(data: data)!
                        }
                    }.resume()
                }
                // description
                if let description = values?["description"] as? String { user.description = description }
                // posts
                self.fetchUserPosts(uid: uid) { posts in
                    user.posts = posts
                }
                users.append(user)
                
            }
            completion(users)
        }
    }
    
    // MARK - Post
    func uploadContent(image: UIImage, content: String?, completion: @escaping (Bool) -> Void) {
        guard let uid = AuthManager.shared.currentUid(),
              let cuid = ref.child("posts").child(uid).childByAutoId().key else {
            completion(false)
            return
        }
        StorageManager.shared.uploadImageToStorage(cuid: cuid, image: image, completion: { result in
            switch result {
            case .success(let url):
                self.ref.child("userinfo").child(uid).child("posts").child(cuid).setValue(["imageURL": url.absoluteString, "content": content ?? ""/*, "time": ServerValue.timestamp()*/])
                completion(true)
                return
            case .failure(let error):
                print(error)
                completion(false)
                return
            }
        })
    }
    
    func fetchUserPosts(uid: String, completion: @escaping ([Post]) -> Void) {
        var posts = [Post]()
        ref.child("userinfo").child(uid).child("posts").observeSingleEvent(of: .value) { (cuidSnapShot) in
            for postSnapShot in cuidSnapShot.children.allObjects as! [DataSnapshot]{
                let values = postSnapShot.value as? [String: Any]
                if let imgURL = values?["imageURL"] as? String {
                    URLSession.shared.dataTask(with: URL(string: imgURL)!) {
                        data, _, error in
                        guard data != nil, error == nil else {
                            completion(posts)
                            return
                        }
                        var post = Post()
                        post.image = UIImage(data: data!)!
                        post.content = values?["content"] as? String ?? ""
                        //post.postTime = values?["time"] as? CVTimeStamp
                        posts.append(post)
                        completion(posts)
                    }.resume()
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
                guard let cuidDic = userinfoDic?["posts"] as? [String: [String: Any]] else {
                    completion(posts)
                    return
                }
                for dic in cuidDic {
                    if let imgURL = dic.value["imageURL"] as? String {
                        URLSession.shared.dataTask(with: URL(string: imgURL)!) {
                            data, _, error in
                            guard data != nil, error == nil else {
                                completion(posts)
                                return
                            }
                            var post = Post()
                            post.image = UIImage(data: data!)!
                            post.content = dic.value["content"] as? String ?? ""
                            //post.postTime = values?["time"] as? CVTimeStamp
                            self.fetchUser(uid: uid) { user in
                                post.user = user
                                posts.append(post)
                                completion(posts)
                            }
                        }.resume()
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
    
//    func fetchFollower(completion: @escaping (User) -> Void) {
//        let uid = AuthManager.shared.currentUid()
//        let ref = Database.database().reference()
//
//        ref.child("userinfo").child(uid!).child("follower").observeSingleEvent(of: .value) { (UidSnapshot) in
//            for followerSnapshot in UidSnapshot.children.allObjects as! [DataSnapshot]{
//                let values = followerSnapshot.value as! [String: Any]
//            let follower = values?["name"] as? String ?? "No Name"
//
//    func userInfo
//    
//    
//    
//    static func fetchCurrentUserRx() -> Observable<User> {
//        return Observable.create { emitter in
//            
//            fetchCurrentUser(completion: { user in
//                emitter.onNext(user)
//            })
//            return Disposables.create()
//        }
//    }
//            


}

