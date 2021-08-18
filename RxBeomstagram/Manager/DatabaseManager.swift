//
//  DatabaseManager.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/17.
//

import FirebaseDatabase
import RxSwift

public class DatabaseManager {
    
    static let shared = DatabaseManager()
    let ref = Database.database().reference()
    
    public func insertNewUser(uid: String, email: String, name: String, id: String) {
        ref.child("userinfo").child(uid).setValue(["email": email.safetyEmail(), "name": name, "id": id])
    }
    
    static func fetchCurrentUser(completion: @escaping (User) -> Void) {
        let uid = AuthManager.shared.currentUid()
        let ref = Database.database().reference()
        
        ref.child("userinfo").child(uid!).observeSingleEvent(of: .value) { (UidSnapshot) in
            let values = UidSnapshot.value as? [String: Any]
            let email = values?["email"] as? String ?? "No Email"
            let id = values?["id"] as? String ?? "No ID"
            let name = values?["name"] as? String ?? "No Name"
            
            var profileImage: UIImage
            if let imgURL = values?["profileImageURL"] as? String {
                URLSession.shared.dataTask(with: URL(string: imgURL)!) {
                    data, _, error in
                    guard data != nil, error == nil else { return }
                    profileImage = UIImage(data: data!)!
                }
            } else {
                profileImage = UIImage(named: "default_profile")!
            }
            let description = values?["description"] as? String ?? "No description"
            
            for infoSnapshot in UidSnapshot.children.allObjects as! [DataSnapshot]{
                let values = infoSnapshot.value as! [String: Any]
            
            var follower: [User]
            var follow: [User]
            var posts: [Post]

            let user = User(email: email, id: id, name: name)
            completion(user)
        }
    }
    
    func fetchFollower(completion: @escaping (User) -> Void) {
        let uid = AuthManager.shared.currentUid()
        let ref = Database.database().reference()
        
        ref.child("userinfo").child(uid!).child("follower").observeSingleEvent(of: .value) { (UidSnapshot) in
            for followerSnapshot in UidSnapshot.children.allObjects as! [DataSnapshot]{
                let values = followerSnapshot.value as! [String: Any]
            let follower = values?["name"] as? String ?? "No Name"
        
    func userInfo
    
    
    
    static func fetchCurrentUserRx() -> Observable<User> {
        return Observable.create { emitter in
            
            fetchCurrentUser(completion: { user in
                emitter.onNext(user)
            })
            return Disposables.create()
        }
    }
            
    static func uploadContent(image: UIImage, content: String, completion: @escaping (Bool) -> Void) {
        let ref = Database.database().reference()
        let uid = AuthManager.shared.currentUid()
        let cuid = ref.child("posts").child(uid!).childByAutoId().key
        
        guard uid != nil, cuid != nil else {
            completion(false)
            return
        }
        StorageManager.shared.uploadImageToStorage(cuid: cuid!, image: image, completion: { result in
            switch result {
            case .success(let url):
                ref.child("posts").child(uid!).child(cuid!).setValue(["imageUrl": url.absoluteString, "content": content, "time": ServerValue.timestamp()])
                completion(true)
                return
            case .failure(let error):
                print(error)
                completion(false)
                return
            }
        })
    }

}

