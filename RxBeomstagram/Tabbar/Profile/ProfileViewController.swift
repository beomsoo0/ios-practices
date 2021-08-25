//
//  ProfileViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/18.
//

import UIKit

class ProfileViewController: UIViewController {

    // MARK - Variables
    var profileViewModel = ProfileViewModel()
    
    // MARK - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        updateUI()
    }
    // MARK - UI functions
    func updateUI() {
        collectionView.reloadData()
        
        idLabel.setTitle(profileViewModel.user.id, for: .normal)
        profileImage.image = profileViewModel.user.profileImage
        profileImage.layer.cornerRadius = profileImage.bounds.width * 0.5
        descriptionLabel.text = profileViewModel.user.description
        nameLabel.text = profileViewModel.user.name
        postCount.text = "\(profileViewModel.user.posts.count)"
        followerCount.text = "\(profileViewModel.user.followers.count)"
        followCount.text = "\(profileViewModel.user.follows.count)"
    }
    
    // MARK - Outlets
    @IBOutlet weak var idLabel: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postCount: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var followCount: UILabel!
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
