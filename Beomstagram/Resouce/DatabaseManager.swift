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

    func fetchUserInfo(userInfo: UserInfoModel, completion: @escaping () -> Void) {
        let uid = AuthManager.shared.currentUid()
        //let userInfo = UserInfo()

        ref.child("userinfo").child(uid!).observeSingleEvent(of: .value) { (UidSnapshot) in
            let values = UidSnapshot.value as? [String: Any]
            userInfo.email = values?["email"] as? String ?? "No Email"
            userInfo.id = values?["id"] as? String ?? "No ID"
            userInfo.name = values?["name"] as? String ?? "No Name"
            userInfo.follower = values?["follower"] as? Int ?? -1
            userInfo.follow = values?["follow"] as? Int ?? -1
            self.fetchProfile(userInfo: userInfo) { success in
                if success {
                    completion()
                } else {
                    userInfo.profile.image = UIImage(named: "default_profile")
                    userInfo.profile.cuid = ""
                    userInfo.profile.comment = ""
                    userInfo.profile.time = .none
                    completion()
                }
            }
        }
    }
    
    func fetchProfile(userInfo: UserInfoModel, completion: @escaping (Bool) -> Void) {
        let uid = AuthManager.shared.currentUid()

        ref.child("userinfo").child(uid!).observeSingleEvent(of: .value) { (UidSnapshot) in
            let values = UidSnapshot.value as? [String: Any]
            guard let urlString = values?["imageUrl"] as? String else {
                completion(false)
                return
            }
            URLSession.shared.dataTask(with: URL(string: urlString)!) { (data, response, error ) in
                userInfo.profile.image = UIImage(data: data!)
                userInfo.profile.cuid = values?["cuid"] as? String ?? "No Cuid"
                userInfo.profile.comment = values?["comment"] as? String ?? "No Comment"
                userInfo.profile.time = values?["time"] as? TimeInterval ?? .none
                completion(true)
            }.resume()
        }
    }
    
    func fetchUserContents(completion: @escaping ([ContentModel]) -> Void) {
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
    
    func fetchAllContents(completion: @escaping ([AllContentModel]) -> Void) {
        var allContentsModel: [AllContentModel] = []
        
        ref.child("contents").observeSingleEvent(of: DataEventType.value) { (UidSnapshot) in
            for uidSnapshot in UidSnapshot.children.allObjects as! [DataSnapshot]{
                let puid = uidSnapshot.key
                for cuidSnapshot in uidSnapshot.children.allObjects as! [DataSnapshot]{
                    let values = cuidSnapshot.value as! [String: Any]
                    let allContentModel = AllContentModel()

                    URLSession.shared.dataTask(with: URL(string: values["imageUrl"] as! String)!) { (data, response, error ) in
                        allContentModel.content.image = UIImage(data: data!)
                        allContentModel.content.cuid = values["cuid"] as? String
                        allContentModel.content.comment = values["comment"] as? String
                        allContentModel.content.time = values["time"] as? TimeInterval
                        
                        self.ref.child("userinfo").child(puid).observeSingleEvent(of: .value) { (DataSnapshot) in
                            let values = DataSnapshot.value as? [String: Any]
                
                            allContentModel.userInfo.email = values?["email"] as? String ?? "nil"
                            allContentModel.userInfo.id = values?["id"] as? String ?? "nil"
                            allContentModel.userInfo.name = values?["name"] as? String ?? "nil"
                            allContentModel.userInfo.follower = values?["follower"] as? Int ?? -1
                            allContentModel.userInfo.follow = values?["follow"] as? Int ?? -1
                        }
                        allContentsModel.append(allContentModel)
                        completion(allContentsModel)
                    }.resume()
                }
            }
        }
    }
    
}
