//
//  DatabaseManager.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/04.
//

import FirebaseDatabase

public class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    let userModel = UserModel.shared
//    let allContentsModel = AllContentsModel.shared
//    let allUserModel = AllUserModel.shared
    
    let ref = Database.database().reference()
    //let uid = AuthManager.shared.currentUid()
    
    public func insertNewUser(uid: String, email: String, name: String, id: String) {
        ref.child("userinfo").child(uid).setValue(["email": email.safetyEmail(), "name": name, "id": id,  "follower": 0, "follow": 0])
    }
    
    public func uploadContent(image: UIImage, comment: String, completion: @escaping (Bool) -> Void) {
        let uid = AuthManager.shared.currentUid()
        let cuid = ref.child("contents").child(uid!).childByAutoId().key
        
        guard uid != nil, cuid != nil else {
            completion(false)
            return
        }
        // Save Content to Database
        StorageManager.shared.uploadImageToStorage(cuid: cuid!, uid: uid!, image: image, completion: { result in
            switch result {
            case .success(let url):
                self.ref.child("contents").child(uid!).child(cuid!).setValue(["Cuid": cuid!, "ImageUrl": url.absoluteString, "Comment": comment])
                completion(true)
                return
            case .failure(let error):
                print(error)
                completion(false)
                return
            }
        })
    }
    
    public func loadUserInfo() {
        let uid = AuthManager.shared.currentUid()
        DispatchQueue.global().sync {
            ref.child("userinfo").child(uid!).observeSingleEvent(of: .value) { (DataSnapshot) in
                let values = DataSnapshot.value as? [String: Any]
                var userInfo = UserInfo()
                
                userInfo.id = values?["id"] as? String
                userInfo.name = values?["name"] as? String
                userInfo.email = values?["email"] as? String
                userInfo.email = self.userModel.userInfo.email?.restoreEmail()
                userInfo.follower = values?["follower"] as? Int
                userInfo.follow = values?["follow"] as? Int
                
                self.userModel.userInfo = userInfo
            }
        }
    }
    
    public func loadContents() {
        let uid = AuthManager.shared.currentUid()
        userModel.contents = []
        DispatchQueue.global().sync {
            ref.child("contents").child(uid!).observeSingleEvent(of: DataEventType.value) { (DataSnapshot) in
                for items in DataSnapshot.children.allObjects as! [DataSnapshot] {
                    let values = items.value as! [String: Any]
                    var content = ContentModel()
                    
                    URLSession.shared.dataTask(with: URL(string: values["ImageUrl"] as! String)!) { (data, response, error ) in
                        DispatchQueue.main.async {
                            content.image = UIImage(data: data!)
                            content.cuid = values["Cuid"] as? String
                            content.comment = values["Comment"] as? String
                            self.userModel.contents.append(content)
                        }
                    }.resume()
                }
            }
        }
    }
    
//    func loadAllContents() {
//        self.allContentsModel.contents = []
//        DispatchQueue.global().sync {
//            ref.child("contents").observeSingleEvent(of: DataEventType.value) { (DataSnapshot) in
//                for uidSnapshot in DataSnapshot.children.allObjects as! [DataSnapshot]{
//                    for cuidSnapshot in uidSnapshot.children.allObjects as! [DataSnapshot]{
//
//                        let values = cuidSnapshot.value as! [String: Any]
//                        var content = ContentModel()
//
//                        URLSession.shared.dataTask(with: URL(string: values["ImageUrl"] as! String)!) { (data, response, error ) in
//                            DispatchQueue.main.async {
//                                content.image = UIImage(data: data!)
//                                content.cuid = values["Cuid"] as? String
//                                content.comment = values["Comment"] as? String
//                                self.allContentsModel.contents.append(content)
//
//                            }
//                        }.resume()
//                    }
//                }
//            }
//        }
//    }
    
//    func loadAllUserModel() {
//        self.allUserModel.userModels = []
//       
//        
//        DispatchQueue.global().sync {
//            ref.child("users").observeSingleEvent(of: .value) { (DataSnapshot) in
//                for uidSnapshot in DataSnapshot.children.allObjects as! [DataSnapshot]{
//                    let uid = uidSnapshot.key
//                    let values = uidSnapshot.value as! [String: Any]
//                    let userModel = UserModel()
//                    var userInfo = UserInfo()
//                    
//                    // userInfo Parsing하여 userModel에 넣기
//                    userInfo.id = values["id"] as? String
//                    userInfo.name = values["name"] as? String
//                    userInfo.email = values["email"] as? String
//                    userInfo.email = self.userModel.userInfo?.email?.restoreEmail()
//                    userInfo.follower = values["follower"] as? Int
//                    userInfo.follow = values["follow"] as? Int
//                    userModel.userInfo = userInfo
//                    
//                    // 위에서의 uid의 contents Parsing하여 userModel에 넣기
//                    self.ref.child("contents").child(uid).observeSingleEvent(of: DataEventType.value) { (DataSnapshot) in
//                        for cuidSnapshot in DataSnapshot.children.allObjects as! [DataSnapshot]{
//                            print(cuidSnapshot.key)
//                            let values = cuidSnapshot.value as! [String: Any]
//                            var content = ContentModel()
//                            print(values)
//                            URLSession.shared.dataTask(with: URL(string: values["ImageUrl"] as! String)!) { (data, response, error ) in
//                                DispatchQueue.main.async {
//                                    content.image = UIImage(data: data!)
//                                    content.cuid = values["Cuid"] as? String
//                                    content.comment = values["Comment"] as? String
//                                    userModel.contents.append(content)
//                                }
//                            }.resume()
//                        }
//                    }
//                    //  완성된 uid의 userModel ->  allUserModel에 넣기
//                    self.allUserModel.userModels.append(userModel)              
//                }
//            }
//        }
//    }
    
}
