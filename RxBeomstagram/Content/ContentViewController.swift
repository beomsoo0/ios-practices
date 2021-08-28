//
//  ContentViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/24.
//

import UIKit

class ContentViewController: UIViewController {

    var allPosts: [Post]!
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "게시물"
        tableView.reloadData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.scrollToRow(at: indexPath!, at: .top, animated: false)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func onID(_ sender: UIButton) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "FriendVC") as? FriendViewController else { return }
        
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }
        nextVC.user = allPosts[indexPath.row].user
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func onLikeButton(_ sender: UIButton) {
        
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }
        guard let cell = tableView.cellForRow(at: indexPath) as? ContentTableViewCell else { return }
        let post = allPosts[indexPath.row]
        
        if cell.isLike == true {
            DatabaseManager.shared.deleteLike(from: User.currentUser, to: post.user, cuid: post.cuid) {
                
            }
            cell.postLikeLabel.text = "좋아요 \(post.likes.count - 1)개"
            cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        } else {
            DatabaseManager.shared.updateLike(from: User.currentUser, to: post.user, cuid: post.cuid) {
                
            }
            cell.postLikeLabel.text = "좋아요 \(post.likes.count + 1)개"
            cell.likeButton.setImage(UIImage(named: "heartFill"), for: .normal)
        }
        cell.isLike = !cell.isLike
    }
    
    @IBAction func onComment(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }
        
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "CommentVC") as? CommentViewController else { return }
        let post = allPosts[indexPath.row]
        nextVC.post = post
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}

extension ContentViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContentTableViewCell") as? ContentTableViewCell else { return UITableViewCell() }
        let post = allPosts[indexPath.row]
        
        cell.profileImageView.image = post.user.profileImage
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.bounds.width * 0.5
        cell.profileIDButton.setTitle(post.user.id, for: .normal)
        cell.postImageView.image = post.image
        //cell.postLikeLabel.text

        cell.postLikeLabel.text = "좋아요 \(post.likes.count)개"
        cell.postContentTextView.text = post.user.id + "  " + post.content

        cell.isLike = false
        for like in post.likes {
            if like == User.currentUser.uid {
                cell.isLike = true
            }
        }
        if cell.isLike == true {
            cell.likeButton.setImage(UIImage(named: "heartFill"), for: .normal)
        } else {
            cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        cell.commentButton.setTitle("댓글 \(post.comments.count)개 모두 보기", for: .normal)
        return cell
    }
    
    
}

class ContentTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileIDButton: UIButton!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postLikeLabel: UILabel!
    @IBOutlet weak var postContentTextView: UITextView!
    @IBOutlet weak var likeButton: UIButton!
    var isLike: Bool!
    @IBOutlet weak var commentButton: UIButton!
}
