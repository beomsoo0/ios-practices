//
//  ProfileViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit

class ProfileViewController: UIViewController {

    
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var contentsCount: UILabel!
    @IBOutlet weak var followCount: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initProfile()
    }
    func initProfile() {
        id.text = "bumssooooo"
        profileImage.image = UIImage(named: "ong")
        contentsCount.text = "12"
        followCount.text = "100"
        followerCount.text = "100"
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileContentsCell", for: indexPath)
        as! ProfileContentsCell
        
        cell.contentImage.image = UIImage(named: "ong")
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpacing: CGFloat = 10
        let width: CGFloat = (collectionView.bounds.width - 2 * itemSpacing) / 3
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }

    
}

class ProfileContentsCell: UICollectionViewCell {
    

    @IBOutlet weak var contentImage: UIImageView!
}

class Profile {
    
    
}
