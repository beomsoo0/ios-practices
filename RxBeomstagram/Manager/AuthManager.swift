//
//  AuthManager.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/17.
//

import FirebaseAuth

public class AuthManager {
    
    static let shared = AuthManager()
    
    // Create User
    public func createNewUser(email: String, password: String, name: String, id: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            guard let authResult = authResult, error == nil else {
                completion(false)
                return
            }
            let uid = authResult.user.uid
            DatabaseManager.shared.insertNewUser(uid: uid, email: email, name: name, id: id)
            completion(true)
            return
        }
    }
    // Login User
    public func loginUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            guard authResult != nil, error == nil else {
                completion(false)
                return
            }
            completion(true)
            return
        }
    }
    // Logout
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
    
    // return uid
    public func currentUid() -> String? {
        return Auth.auth().currentUser?.uid
    }
}

