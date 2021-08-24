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
        cell.profileImage.image = homeViewModel.posts[indexPath.row].user?.profileImage
        cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.width * 0.5
        cell.profileID.setTitle(homeViewModel.posts[indexPath.row].user?.id, for: .normal)
        cell.postImage.image = homeViewModel.posts[indexPath.row].image
        //cell.postLikeLabel.text
        cell.postContentLabel.text = homeViewModel.posts[indexPath.row].content
        //cell.commentButton
        //cell.curProfileImage.image
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
}

