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
    
   
    let currentUser = UserModel.shared
    var profileViewModel = PriofileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Profile viewDidLoad")
 
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Profile viewWillAppear")
        profileViewModel.loadProfileModel {
            DispatchQueue.main.async {
                self.setProfileInfo()
                self.postCollectionView.reloadData()
            }
        }
    }
    
    func setProfileInfo() {
        id.text = currentUser.userInfo.id
        followerCount.text = String(currentUser.userInfo.follower ?? -1)
        followCount.text = String(currentUser.userInfo.follow ?? -1)
        profileImage.image = currentUser.content.image
        //둥글게
        profileImage.layer.cornerRadius = profileImage.frame.width/3
        profileImage.clipsToBounds = true
        profileComment.text = currentUser.content.comment
        contentsCount.text = String(profileViewModel.profileModel.count)
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profileViewModel.profileModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileContentsCell", for: indexPath) as? ProfileContentsCell else {
            return UICollectionViewCell()
        }
        cell.contentImage.image = profileViewModel.profileModel[indexPath.item].image
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
