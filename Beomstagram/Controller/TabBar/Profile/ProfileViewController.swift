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
    
    @IBOutlet weak var profileComment: UILabel!
    @IBOutlet weak var contentsCount: UILabel!
    @IBOutlet weak var followCount: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var postCollectionView: UICollectionView!
    @IBOutlet weak var profileView: UIView!
    
    var userModel = UserModel()
    let curUserInfo = UserInfoModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Profile ViewDidLoad")
        
        //profileImage.image = self?.userModel.profileContent.image
        //contentsCount.text = String(self?.userModel.contents.count ?? -1)
        
        /*
        DatabaseManager.shared.fetchUserModel { [weak self] userModel in
            self?.userModel = userModel
            DispatchQueue.main.async {
                self?.id.text = self?.userModel.userInfo.id
                self?.profileImage.image = self?.userModel.profileContent.image
                self?.contentsCount.text = String(self?.userModel.contents.count ?? -1)
                self?.followerCount.text = String(self?.userModel.userInfo.follower ?? -1)
                self?.followCount.text = String(self?.userModel.userInfo.follow ?? -1)
            }
        }
        
        DatabaseManager.shared.fetchProfile { [weak self] profile in
            self?.userModel.profileContent = profile
            DispatchQueue.main.async {
                if self?.userModel.profileContent.image != nil {
                    self?.profileImage.image = self?.userModel.profileContent.image
                    //comment
                } else {
                    self?.profileImage.image = UIImage(named: "default_profile")
                }
            }
        
        DatabaseManager.shared.fetchUserContents { [weak self] contentsModel in
            self?.userModel.contents = contentsModel
            DispatchQueue.main.async {
                self?.postCollectionView.reloadData()
                }
            }
        }*/
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("@@@@@")
        print(curUserInfo.email)
        print(curUserInfo.id)
        print(curUserInfo.name)
        print(curUserInfo.profile.comment)
        setProfileInfo()
    }
    func setProfileInfo() {
        id.text = curUserInfo.id
        followerCount.text = String(curUserInfo.follower ?? -1)
        followCount.text = String(curUserInfo.follow ?? -1)
        profileImage.image = curUserInfo.profile.image
        profileComment.text = curUserInfo.profile.comment
        //contentsCount.text = String(curUserInfo.profile.count ?? -1)
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return userModel.contents.count
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileContentsCell", for: indexPath) as? ProfileContentsCell else {
//            return UICollectionViewCell()
//        }
//        cell.contentImage.image = userModel.contents[indexPath.item].image
//        return cell
        return UICollectionViewCell()
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
