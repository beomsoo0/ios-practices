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
        

        //updateUI()
        //profileViewModel.fetchCurrentModel { [self] in updateUI() }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("@@@@@@@")
        dump(profileViewModel.user)
        updateUI()
    }
    // MARK - UI functions
    func updateUI() {
        collectionView.reloadData()
        
        idLabel.setTitle(profileViewModel.user.id, for: .normal)
        profileImage.image = profileViewModel.user.profileImage
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
}
