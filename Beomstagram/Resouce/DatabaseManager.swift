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
    
    public func insertNewUser(uid: String, email: String, id: String, name: String) {
        ref.child("users").child(uid).setValue(["id": id, "name": name, "email": email.safetyEmail(), "follower": 0, "follow": 0])
    }
    
    public func updateContent(image: UIImage, comment: String) {
        
        let uid = AuthManager.shared.currentUid()
        let cuid = ref.child(uid!).child("contents").childByAutoId().key
        
        // Save Content to Database
        StorageManager.shared.uploadImageToStorage(cuid: cuid!, uid: uid!, image: image, completion: { result in
            switch result {
            case .success(let url):
                self.ref.child(uid!).child("contents").child(cuid!).setValue(["Cuid": cuid!, "ImageUrl": url.absoluteString, "Comment": comment])
            case .failure(_):
                print("Upload Error")
            }
        })
        // User->Contents에 추가

    }
}
