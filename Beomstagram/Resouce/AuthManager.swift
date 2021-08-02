//
//  AuthManager.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import FirebaseAuth
import FirebaseDatabase

public class AuthManager {
    
    static let shared = AuthManager()
    
    public func createNewUser(id: String, password: String, name: String, email: String, completion: @escaping (Bool) -> Void) {
        
        if (id.isEmpty || password.isEmpty || password.count <= 8 || name.isEmpty || email.isEmpty) {
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

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
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
    
    
}
