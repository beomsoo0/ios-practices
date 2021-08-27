//
//  ProfileViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/18.
//

import UIKit

class ProfileViewController: UIViewController {

    // MARK - Variables
    var user = User.currentUser!
    
    // MARK - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        updateUI()
        
    }
    
    // MARK - UI functions
    func updateUI() {
        idLabel.setTitle(user.id, for: .normal)
        profileImage.image = user.profileImage
        profileImage.layer.cornerRadius = profileImage.bounds.width * 0.5
        descriptionLabel.text = user.description
        nameLabel.text = user.name
        
        
        postCountButton.setTitle("\(user.posts.count)\n\n게시물", for: .normal)
        postCountButton.titleLabel?.lineBreakMode = .byWordWrapping
        postCountButton.titleLabel?.textAlignment = .center
        followerCountButton.setTitle("\(user.followers.count)\n\n팔로워", for: .normal)
        followerCountButton.titleLabel?.lineBreakMode = .byWordWrapping
        followerCountButton.titleLabel?.textAlignment = .center
        followCountButton.setTitle("\(user.follows.count)\n\n팔로우", for: .normal)
        followCountButton.titleLabel?.lineBreakMode = .byWordWrapping
        followCountButton.titleLabel?.textAlignment = .center
    }

    @IBAction func onFollower(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "FollowVC") as? FollowViewController else { return }
        nextVC.isFollow = false
        nextVC.followUids = user.follows
        nextVC.followerUids = user.followers
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func onFollow(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "FollowVC") as? FollowViewController else { return }
        nextVC.isFollow = true
        nextVC.followUids = user.follows
        nextVC.followerUids = user.followers
        self.navigationController?.pushViewController(nextVC, animated: true)
    }

    
    // MARK - Outlets
    @IBOutlet weak var idLabel: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postCountButton: UIButton!
    @IBOutlet weak var followerCountButton: UIButton!
    @IBOutlet weak var followCountButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func onAddContent(_ sender: Any) {
        self.tabBarController?.selectedIndex = 2
    }
    @IBAction func onSetting(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "SettingVC") as? SettingViewController else { return }
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func onEditProfile(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "EditVC") as? EditProfileViewController else { return }
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    
    
}
