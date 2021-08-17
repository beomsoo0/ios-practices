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
    
    public func insertNewUser(uid: String, email: String, name: String, id: String) {
        ref.child("userinfo").child(uid).setValue(["email": email.safetyEmail(), "name": name, "id": id,  "follower": 0, "follow": 0])
    }
    
        
    
}

