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
    
    var userModel = UserModel.shared

    @IBAction func reload(_ sender: Any) {
        
        postCollectionView.reloadData()
        initProfile()
        print(userModel.contents.count)
        print(userModel.userInfo?.name ?? "No")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initProfile()
    }

    func initProfile() {
        profileImage.image = UIImage(named: "ong")
        id.text = userModel.userInfo?.id
        contentsCount.text = String(userModel.contents.count ?? -1)
        followerCount.text = String(userModel.userInfo?.follower ?? -1)
        followCount.text = String(userModel.userInfo?.follow ?? -1)
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Profile image count: ", userModel.contents.count)
        return userModel.contents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileContentsCell", for: indexPath)
            as! ProfileContentsCell
        cell.contentImage.image = userModel.contents[indexPath.item].image
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
