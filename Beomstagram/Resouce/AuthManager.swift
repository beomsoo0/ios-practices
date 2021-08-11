//
//  AuthManager.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import FirebaseAuth

public class AuthManager {
    
    static let shared = AuthManager()
    
    public func createNewUser(email: String, password: String, name: String, id: String, completion: @escaping (Bool) -> Void) {
        guard email.contains("@"), email.contains("."), password.count >= 8, !name.isEmpty, !id.isEmpty  else {
            completion(false)
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            guard let authResult = authResult, error == nil else {
                print("계정 생성 실패 \(error.debugDescription)")
                completion(false)
                return
            }
            let uid = authResult.user.uid
            DatabaseManager.shared.insertNewUser(uid: uid, email: email, name: name, id: id)
            completion(true)
            return
        }
    }
    
    public func loginUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            guard authResult != nil, error == nil else {
                print(error.debugDescription)
                completion(false)
                return
            }
            completion(true)
            return
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
    
    public func currentUid() -> String? {
        return Auth.auth().currentUser?.uid
    }
}
