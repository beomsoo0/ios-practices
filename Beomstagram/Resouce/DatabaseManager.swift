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
        ref.child("userinfo").child(uid).setValue(["email": email.safetyEmail(), "name": name, "id": id,  "follower": 0, "follow": 0])
    }
    
    public func uploadContent(image: UIImage, comment: String, completion: @escaping (Bool) -> Void) {
        let uid = AuthManager.shared.currentUid()
        let cuid = ref.child("contents").child(uid!).childByAutoId().key
        
        guard uid != nil, cuid != nil else {
            completion(false)
            return
        }
        StorageManager.shared.uploadImageToStorage(cuid: cuid!, uid: uid!, image: image, completion: { result in
            switch result {
            case .success(let url):
                self.ref.child("contents").child(uid!).child(cuid!).setValue(["cuid": cuid!, "imageUrl": url.absoluteString, "comment": comment, "time": ServerValue.timestamp()])
                completion(true)
                return
            case .failure(let error):
                print(error)
                completion(false)
                return
            }
        })
    }
    
    public func editProfile(image: UIImage, comment: String, name: String, id: String, completion: @escaping (Bool) -> Void) {
        let uid = AuthManager.shared.currentUid()
        let cuid = ref.child("contents").child(uid!).childByAutoId().key
        
        guard uid != nil, cuid != nil else {
            completion(false)
            return
        }
        StorageManager.shared.uploadImageToStorage(cuid: cuid!, uid: uid!, image: image, completion: { result in
            switch result {
            case .success(let url):
                self.ref.child("userinfo").child(uid!).updateChildValues(["cuid": cuid!, "imageUrl": url.absoluteString, "comment": comment, "time": ServerValue.timestamp(), "name": name, "id": id])
                completion(true)
                return
            case .failure(let error):
                print(error)
                completion(false)
                return
            }
        })
    }

    func fetchCurrentUserModel(userModel: UserModel, completion: @escaping () -> Void) {
        let uid = AuthManager.shared.currentUid()

        ref.child("userinfo").child(uid!).observeSingleEvent(of: .value) { (UidSnapshot) in
            let values = UidSnapshot.value as? [String: Any]
            userModel.userInfo.email = values?["email"] as? String ?? "No Email"
            userModel.userInfo.id = values?["id"] as? String ?? "No ID"
            userModel.userInfo.name = values?["name"] as? String ?? "No Name"
            userModel.userInfo.follower = values?["follower"] as? Int ?? -1
            userModel.userInfo.follow = values?["follow"] as? Int ?? -1
            self.fetchCurrentProfile(content: userModel.content) { success in
                if success {
                    completion()
                } else {
                    userModel.content.image = UIImage(named: "default_profile")
                    userModel.content.cuid = ""
                    userModel.content.comment = ""
                    userModel.content.time = .none
                    completion()
                }
            }
        }
    }
    func fetchCurrentProfile(content: ContentModel, completion: @escaping (Bool) -> Void) {
        let uid = AuthManager.shared.currentUid()

        ref.child("userinfo").child(uid!).observeSingleEvent(of: .value) { (UidSnapshot) in
            let values = UidSnapshot.value as? [String: Any]
            guard let urlString = values?["imageUrl"] as? String else {
                completion(false)
                return
            }
            URLSession.shared.dataTask(with: URL(string: urlString)!) { (data, response, error ) in
                content.image = UIImage(data: data!)
                content.cuid = values?["cuid"] as? String ?? "No Cuid"
                content.comment = values?["comment"] as? String ?? "No Comment"
                content.time = values?["time"] as? TimeInterval ?? .none
                completion(true)
            }.resume()
        }
    }
    
    func fetchCurrentUserContents(completion: @escaping ([ContentModel]) -> Void) {
        let uid = AuthManager.shared.currentUid()
        var contents = [ContentModel]()
        ref.child("contents").child(uid!).observeSingleEvent(of: DataEventType.value) { (CuidSnapshot) in
            for items in CuidSnapshot.children.allObjects as! [DataSnapshot] {
                let values = items.value as! [String: Any]
                let content = ContentModel()
                
                URLSession.shared.dataTask(with: URL(string: values["imageUrl"] as! String)!) { (data, response, error ) in
                    content.image = UIImage(data: data!)
                    content.cuid = values["cuid"] as? String ?? "nil"
                    content.comment = values["comment"] as? String ?? "nil"
                    content.time = values["time"] as? TimeInterval
                    contents.append(content)
                    completion(contents)
                }.resume()
            }
        }
    }
    
    func fetchAllContentModel(completion: @escaping ([UserModel]) -> Void) {
        var userModels: [UserModel] = []
        
        ref.child("contents").observeSingleEvent(of: DataEventType.value) { (UidSnapshot) in
            for uidSnapshot in UidSnapshot.children.allObjects as! [DataSnapshot]{
                let puid = uidSnapshot.key
                for cuidSnapshot in uidSnapshot.children.allObjects as! [DataSnapshot]{
                    let values = cuidSnapshot.value as! [String: Any]
                    let userModel = UserModel()

                    URLSession.shared.dataTask(with: URL(string: values["imageUrl"] as! String)!) { (data, response, error ) in
                        userModel.content.image = UIImage(data: data!)
                        userModel.content.cuid = values["cuid"] as? String
                        userModel.content.comment = values["comment"] as? String
                        userModel.content.time = values["time"] as? TimeInterval
                        
                        self.ref.child("userinfo").child(puid).observeSingleEvent(of: .value) { (DataSnapshot) in
                            let values = DataSnapshot.value as? [String: Any]
                
                            userModel.userInfo.email = values?["email"] as? String ?? "nil"
                            userModel.userInfo.id = values?["id"] as? String ?? "nil"
                            userModel.userInfo.name = values?["name"] as? String ?? "nil"
                            userModel.userInfo.follower = values?["follower"] as? Int ?? -1
                            userModel.userInfo.follow = values?["follow"] as? Int ?? -1
                        }
                        userModels.append(userModel)
                        completion(userModels)
                    }.resume()
                }
            }
        }
    }
    
    func fetchAllUserModel(completion: @escaping ([UserModel]) -> Void) {
        var userModels: [UserModel] = []
        
        ref.child("userinfo").observeSingleEvent(of: DataEventType.value) { (UidSnapshot) in
            //let uid = UidSnapshot.key
            for infoSnapshot in UidSnapshot.children.allObjects as! [DataSnapshot]{
                let values = infoSnapshot.value as! [String: Any]
                let userModel = UserModel()
                
                userModel.userInfo.email = values["email"] as? String ?? "nil"
                userModel.userInfo.id = values["id"] as? String ?? "nil"
                userModel.userInfo.name = values["name"] as? String ?? "nil"
                userModel.userInfo.follower = values["follower"] as? Int ?? -1
                userModel.userInfo.follow = values["follow"] as? Int ?? -1
                if let urlString = values["imageUrl"] as? String {
                    URLSession.shared.dataTask(with: URL(string: urlString)!) { (data, response, error ) in
                        userModel.content.image = UIImage(data: data!)
                        userModel.content.cuid = values["cuid"] as? String
                        userModel.content.comment = values["comment"] as? String
                        userModel.content.time = values["time"] as? TimeInterval
                        userModels.append(userModel)
                        completion(userModels)
                    }.resume()
                }else {
                    userModel.content.image = UIImage(named: "default_profile")
                    userModel.content.cuid = ""
                    userModel.content.comment = ""
                    userModel.content.time = .none
                    userModels.append(userModel)
                    completion(userModels)
                }
            }
        }
    }
        
    
}
