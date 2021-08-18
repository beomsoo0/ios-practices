//
//  ProfileViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/18.
//

import UIKit

class ProfileViewController: UIViewController {

    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DatabaseManager.fetchCurrentUser { user in
            self.user = user
            self.updateUI()
        }
        
    }
    
    func updateUI() {
        idLabel.setTitle(user?.id, for: .normal)
        profileImage.image = user?.profileImage
        nameLabel.text = user?.name
        postCount.text = "0"
        followerCount.text = "0"
        followCount.text = "0"
    }
    @IBOutlet weak var idLabel: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postCount: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var followCount: UILabel!
    
}


