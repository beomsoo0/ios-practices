//
//  HomeViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/18.
//

import UIKit

class HomeViewController: UIViewController {

    var allPosts = [Post]()
    var otherUsers = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        DatabaseManager.shared.fetchAllPosts { [weak self] posts in
            self?.allPosts = posts
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                dump(self?.allPosts)
            }
            
        }
        DatabaseManager.shared.fetchOtherUsers { [weak self] users in
            self?.otherUsers = users
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
    }


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func onAddContent(_ sender: Any) {
        self.tabBarController?.selectedIndex = 2
    }
    
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
        guard let cell = tableView.cellForRow(at: indexPath) as? HomeTableViewCell else { return }
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



