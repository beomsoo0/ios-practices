//
//  ProfileViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var contentsCount: UILabel!
    @IBOutlet weak var followCount: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var postCollectionView: UICollectionView!
    @IBOutlet weak var profileView: UIView!
    
    var userInfo = UserInfoModel()
    var contents: [ContentModel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        
        // 유저 정보 받아오기
        ref.child("userinfo").child(uid!).observeSingleEvent(of: .value) { (UidSnapshot) in
            let values = UidSnapshot.value as? [String: Any]
            
            DispatchQueue.main.async {
                self.userInfo.email = values?["email"] as? String ?? "nil"
                self.userInfo.id = values?["id"] as? String ?? "nil"
                self.userInfo.name = values?["name"] as? String ?? "nil"
                self.userInfo.follower = values?["follower"] as? Int ?? -1
                self.userInfo.follow = values?["follow"] as? Int ?? -1
                
                self.id.text =  self.userInfo.id
                
                self.followerCount.text = String(self.userInfo.follower ?? -1)
                self.followCount.text = String(self.userInfo.follow ?? -1)
                
//                let url = URL(string: values?["profileImageUrl"] as? String ?? "http://www.google.com")
//
//                URLSession.shared.dataTask(with: url ??)) { (data, response, error ) in
//                    guard error == nil else {
//                        print("!!!")
//                        return
//                    }
//                    print("@@@")
//                    self.profileImage.image = UIImage(data: data!)
//                }

                
                
            }
        }
        
        // 게시물 받아오기
        ref.child("contents").child(uid!).observeSingleEvent(of: DataEventType.value) { (CuidSnapshot) in
            for items in CuidSnapshot.children.allObjects as! [DataSnapshot] {
                let values = items.value as! [String: Any]
                let content = ContentModel()
                
                URLSession.shared.dataTask(with: URL(string: values["ImageUrl"] as! String)!) { (data, response, error ) in
                    
                    DispatchQueue.main.async {
                        content.image = UIImage(data: data!)
                        content.cuid = values["Cuid"] as? String ?? "nil"
                        content.comment = values["Comment"] as? String ?? "nil"
                        content.time = values["Time"] as! TimeInterval
                        self.contents.append(content)
                        if self.contents.count == 0 {
                            self.contentsCount.text = "0"
                        }
                        else {
                            self.contentsCount.text = String(self.contents.count)
                        }
                        self.postCollectionView.reloadData()
                    }
                }.resume()
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.postCollectionView.reloadData()
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileContentsCell", for: indexPath) as? ProfileContentsCell else {
            return UICollectionViewCell()
        }
        cell.contentImage.image = contents[indexPath.item].image
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpacing: CGFloat = 1
        let width: CGFloat = (collectionView.bounds.width - itemSpacing) / 3
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }
    
}

class ProfileContentsCell: UICollectionViewCell {
    
    @IBOutlet weak var contentImage: UIImageView!
}
