//
//  UserModel.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class Content {
    var image: UIImage?
    var comment: String?
    
    init(image: UIImage, comment: String) {
        self.image = image
        self.comment = comment
    }
}

class UserModel {
    
//    static let shared = UserModel() //singleton pattern (여러 VC에서 하나의 객체 사용하기 위함)
    
    var id: String?
    var name: String?
    var email: String?
    var follower: Int?
    var follow: Int?
    var contents: [Content] = []
    
//    init() {
//        self.id = "Init ID"
//        self.name = "Init Name"
//        self.email = "Init Email"
//        self.follower = -2
//        self.follow = -2
//
//        //self.parsingUserInfo()
//    }
    
//    private func parsingUserInfo() {
//        let uid = Auth.auth().currentUser?.uid
//        let ref = Database.database().reference()
//        let userInfoAddr = ref.child("users").child(uid!)
//        //let contentsAddr = Database.database().reference().child(uid!).child("contents")
//
//        // User Info 불러오기 from Database
//        userInfoAddr.observeSingleEvent(of: .value, with: { snapshot in
//                let value = snapshot.value as? NSDictionary
//                self.userInfo?.id = value?["id"] as? String ?? "No ID"
//                self.userInfo?.name = value?["name"] as? String ?? "No Name"
//                self.userInfo?.email = value?["email"] as? String ?? "No Email"
//                self.userInfo?.follower = value?["follower"] as? Int ?? -1
//                self.userInfo?.follow = value?["follower"] as? Int ?? -1
//                print(self.userInfo?.id)
//            })
//
//        print(self.userInfo?.id)
//    }
    
    public func contentsCount() -> Int {
        return contents.count
    }
    
}
