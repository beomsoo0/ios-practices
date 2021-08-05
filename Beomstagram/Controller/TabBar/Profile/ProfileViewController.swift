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
    
    var userModel = UserModel()
    var contentsModel = [ContentModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ref = DatabaseManager.shared.ref
        let uid = AuthManager.shared.currentUid()
        
//        ref.child("users").child(uid!).observeSingleEvent(of: DataEventType.value) { (DataSnapshot) in
//            for items in DataSnapshot.children.allObjects as! [DataSnapshot] {
//                guard uid != nil else {
//                    break
//                }
//                let values = items.value as! [String: Any]
//
//                self.userModel.id = values["id"] as? String
//                self.userModel.name = values["name"] as? String
//                self.userModel.email = values["email"] as? String
//                self.userModel.email?.restoreEmail()
//                self.userModel.follower = values["follower"] as? Int
//                self.userModel.follow = values["follow"] as? Int
//            }
//        }
        
//        ref.child(uid!).child("contents").observeSingleEvent(of: DataEventType.value) { (DataSnapshot) in
//            for items in DataSnapshot.children.allObjects as! [DataSnapshot] {
//                let values = items.value as! [String: Any]
//                var content = ContentModel()
//
//                URLSession.shared.dataTask(with: URL(string: values["ImageUrl"] as! String)!) { (data, response, error ) in
//                    DispatchQueue.main.async {
//                        content.image = UIImage(data: data!)
//                        content.cuid = values["Cuid"] as? String
//                        content.comment = values["Comment"] as? String
//
//                        //모델에 넣어주기
//                        self.userModel.contents.append(content)
//                        self.postCollectionView.reloadData()
//                    }
//                }.resume()
//            }
//        }
        ref.child(uid!).child("contents").observeSingleEvent(of: DataEventType.value) { (DataSnapshot) in
                  for items in DataSnapshot.children.allObjects as! [DataSnapshot] {
                      let values = items.value as! [String: Any]
                      var content = ContentModel()
      
                      URLSession.shared.dataTask(with: URL(string: values["ImageUrl"] as! String)!) { (data, response, error ) in
                          DispatchQueue.main.async {
                              content.image = UIImage(data: data!)
                              content.cuid = values["Cuid"] as? String
                              content.comment = values["Comment"] as? String
      
                              //모델에 넣어주기
                              self.contentsModel.append(content)
                              self.postCollectionView.reloadData()
                          }
                      }.resume()
                  }
              }
    }
    
    
    func initProfile() {
//        id.text = userModel.id
        profileImage.image = UIImage(named: "ong")
//        contentsCount.text = String(userModel.contents.count)
//        followerCount.text = String(userModel.follower)
//        followCount.text = String(userModel.follow)
        
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return userManager.contentsCount()
        return contentsModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileContentsCell", for: indexPath)
        as! ProfileContentsCell
        
        //cell.contentImage.image = UserModel().contents[indexPath.item].image
        cell.contentImage.image = contentsModel[indexPath.item].image
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.bounds.width / 3 - 1
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }

    
}

class ProfileContentsCell: UICollectionViewCell {
    
    @IBOutlet weak var contentImage: UIImageView!
}
