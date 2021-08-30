//
//  HomeTableViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/24.
//

import UIKit
import RxSwift
import RxCocoa

extension HomeViewController: UITableViewDelegate {
    
    
}

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileID: UIButton!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postLikeLabel: UILabel!
    @IBOutlet weak var postContentLabel: UITextView!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var curProfileImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    
    var isLike: Bool!
    var post: Post!


}

