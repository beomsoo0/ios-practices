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
    
   
    let curUserInfo = UserInfoModel.shared
    var contents = [ContentModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Profile viewDidLoad")
 
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Profile viewWillAppear")
        DatabaseManager.shared.fetchUserContents { [weak self] Contents in
            self?.contents = Contents
            DispatchQueue.main.async {
                self?.setProfileInfo()
                self?.postCollectionView.reloadData()
            }
        }
    }
    func setProfileInfo() {
        id.text = curUserInfo.id
        followerCount.text = String(curUserInfo.follower ?? -1)
        followCount.text = String(curUserInfo.follow ?? -1)
        profileImage.image = curUserInfo.profile.image
        profileComment.text = curUserInfo.profile.comment
        contentsCount.text = String(contents.count ?? -1)
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
