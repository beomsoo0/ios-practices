//
//  HomeTableViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/24.
//

import UIKit

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeViewModel.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell") as? HomeTableViewCell else { return UITableViewCell() }
        guard let user = homeViewModel.posts[indexPath.row].user
              else { return  UITableViewCell() }
        let post = homeViewModel.posts[indexPath.row]

        cell.profileImage.image = user.profileImage
        cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.width * 0.5
        cell.profileID.setTitle(user.id, for: .normal)
        cell.postImage.image = post.image
        cell.postLikeLabel.text = "좋아요 \(post.likes.count)개"
        cell.postContentLabel.text = user.id + "  " + post.content
        
        cell.isLike = false
        for like in post.likes {
            print("@@@@@", like)
            if like == User.currentUser.uid {
                cell.isLike = true
            }
        }
        if cell.isLike == true {
            cell.likeButton.setImage(UIImage(named: "heartFill"), for: .normal)
        } else {
            cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        
        return cell
    }
    
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
    
}

