//
//  DatabaseManager.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/04.
//

import FirebaseDatabase

public class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    let ref = Database.database().reference()
    
    public func insertNewUser(uid: String, email: String, name: String, id: String) {
        ref.child("users").child(uid).setValue(["email": email.safetyEmail(), "name": name, "id": id,  "follower": 0, "follow": 0])
    }
    
    public func uploadContent(image: UIImage, comment: String, completion: @escaping (Bool) -> Void) {
        let uid = AuthManager.shared.currentUid()
        let cuid = ref.child(uid!).child("contents").childByAutoId().key
        
        guard uid != nil, cuid != nil else {
            completion(false)
            return
        }
        // Save Content to Database
        StorageManager.shared.uploadImageToStorage(cuid: cuid!, uid: uid!, image: image, completion: { result in
            switch result {
            case .success(let url):
                self.ref.child(uid!).child("contents").child(cuid!).setValue(["Cuid": cuid!, "ImageUrl": url.absoluteString, "Comment": comment])
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
