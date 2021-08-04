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
    
    public func currentUid() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
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
            let uid = authResult?.user.uid ?? ""
            DatabaseManager.shared.insertNewUser(uid: uid, email: email, id: id, name: name)
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
    
    public func logOutUser(completion: @escaping (Bool) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(true)
            return
        }
        catch {
            print(error.localizedDescription)
            completion(false)
            return
        }
    }
    
    

}
