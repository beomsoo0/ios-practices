//
//  AuthManager.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

public class AuthManager {
    
    static let shared = AuthManager()
    
    
    public func createNewUser(id: String, password: String, name: String, email: String, completion: @escaping (Bool) -> Void) {
        
        guard !id.isEmpty, !password.isEmpty, !name.isEmpty, !email.isEmpty, password.count >= 8, email.contains("@"), email.contains(".") else {
            completion(false)
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if error != nil {
                print(error.debugDescription)
                completion(false)
                return
            }
            let uid = authResult?.user.uid
            Database.database().reference().child("users").child(uid!).setValue(["id": id, "password": password, "name": name, "email": email.safetyDatabase()])
            completion(true)
            return
        }
    }
    
    public func loginUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if error != nil {
                print("\(error.debugDescription)")
                completion(false)
                return
            }
            else
            {
                completion(true)
                return
            }
        }
    }
    
    func updateContent(content: Content) {
        let uid = Auth.auth().currentUser?.uid
        let Cuid = Database.database().reference().child(uid!).child("contents").childByAutoId().key
        let image = content.image.jpegData(compressionQuality: 0.1)
        let imageRef = Storage.storage().reference().child(uid!).child("contents").child(Cuid!)
        
        imageRef.putData(image!, metadata: nil) { (StorageMetadata, error) in
            //예외처리
            
            imageRef.downloadURL { (url, error) in
                Database.database().reference().child(uid!).child("contents").child("Cid").setValue(["Cuid": Cuid!, "ImageUrl": url?.absoluteString, "Comment": content.comment])
            }
        }
       
    }
}
