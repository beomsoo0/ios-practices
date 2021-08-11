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
    
    public func uploadProfile(image: UIImage, comment: String, completion: @escaping (Bool) -> Void) {
        let uid = AuthManager.shared.currentUid()
        let cuid = ref.child("contents").child(uid!).childByAutoId().key
        
        guard uid != nil, cuid != nil else {
            completion(false)
            return
        }
        StorageManager.shared.uploadImageToStorage(cuid: cuid!, uid: uid!, image: image, completion: { result in
            switch result {
            case .success(let url):
                self.ref.child("userInfo").child(uid!).setValue(["cuid": cuid!, "imageUrl": url.absoluteString, "comment": comment, "time": ServerValue.timestamp()])
                completion(true)
                return
            case .failure(let error):
                print(error)
                completion(false)
                return
            }
        })
    }

    func fetchUserModel(completion: @escaping (UserModel) -> Void) {
        let uid = AuthManager.shared.currentUid()
        let model = UserModel()

        ref.child("userinfo").child(uid!).observeSingleEvent(of: .value) { (UidSnapshot) in
            let values = UidSnapshot.value as? [String: Any]
            model.userInfo.email = values?["email"] as? String ?? "No Email"
            model.userInfo.id = values?["id"] as? String ?? "No ID"
            model.userInfo.name = values?["name"] as? String ?? "No Name"
            model.userInfo.follower = values?["follower"] as? Int ?? -1
            model.userInfo.follow = values?["follow"] as? Int ?? -1
            
            let url = URL(string: values?["imageUrl"] as? String ?? "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.snsboom.co.kr%2Fannouncement%2F%3Fq%3DYToyOntzOjEyOiJrZXl3b3JkX3R5cGUiO3M6MzoiYWxsIjtzOjQ6InBhZ2UiO2k6MTt9%26bmode%3Dview%26idx%3D2472131%26t%3Dboard&psig=AOvVaw015-5DDP9COCaRd-X2jC0k&ust=1628745880155000&source=images&cd=vfe&ved=0CAsQjRxqFwoTCODJja-dqPICFQAAAAAdAAAAABAO")

            URLSession.shared.dataTask(with: url!) { (data, response, error ) in
                if error != nil {
                    print("image error")
                    completion(model)
                }
                model.profileContent.image = UIImage(data: data!)
                model.profileContent.comment = values?["cuid"] as? String ?? "No Cuid"
                model.profileContent.comment = values?["comment"] as? String ?? "No Comment"
                model.profileContent.time = values?["time"] as? TimeInterval ?? .none
                completion(model)
            }.resume()
        }
    }
    
    func fetchProfile(completion: @escaping (ContentModel) -> Void) {
        let uid = AuthManager.shared.currentUid()
        let profile = ContentModel()

        ref.child("userinfo").child(uid!).observeSingleEvent(of: .value) { (UidSnapshot) in
            let values = UidSnapshot.value as? [String: Any]
            guard let urlString = values?["imageUrl"] as? String else { return }
            URLSession.shared.dataTask(with: URL(string: urlString)!) { (data, response, error ) in
                profile.image = UIImage(data: data!)
                profile.cuid = values?["cuid"] as? String ?? "No Cuid"
                profile.comment = values?["comment"] as? String ?? "No Comment"
                profile.time = values?["time"] as? TimeInterval ?? .none
                completion(profile)
            }.resume()
        }
    }
    
    func fetchUserContents(completion: @escaping ([ContentModel]) -> Void) {
        let uid = AuthManager.shared.currentUid()
        var contents: [ContentModel] = []
        
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
