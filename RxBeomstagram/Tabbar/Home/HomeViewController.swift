//
//  HomeViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/18.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {

    var allPosts = [Post]()
    var otherUsers = [User]()
    
    let homeViewModel = HomeViewModel()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = nil
        collectionView.dataSource = nil
        
        homeViewModel.usersObservable
            .observe(on: MainScheduler.instance)
            .bind(to: collectionView.rx.items(cellIdentifier: "HomeCollectionViewCell", cellType: HomeCollectionViewCell.self)) { index, item, cell in
//                let user = index == 0 ? homeViewModel.curUserObservable.map{ $0 } : item
                cell.storyImageView.image = item.profileImage
                cell.storyImageView.layer.cornerRadius = cell.storyImageView.bounds.width * 0.5
                cell.storyIDLabel.text = item.id
            }
            .disposed(by: disposeBag)
        
        homeViewModel.postsObservable
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: "HomeTableViewCell", cellType: HomeTableViewCell.self)) { index, item, cell in
                
                let user = item.user
                let post = item
                
                cell.profileImage.image = user.profileImage
                cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.width * 0.5
                cell.profileID.setTitle(user.id, for: .normal)
                cell.postImage.image = post.image
                cell.postLikeLabel.text = "좋아요 \(post.likes.count)개"
                cell.postContentLabel.text = user.id + "  " + post.content
                
                cell.isLike = false
                
                let curUid = AuthManager.shared.currentUid()!
                cell.isLike = post.likes.contains(curUid) ? true : false
                
                let img = cell.isLike == true ? UIImage(named: "heartFill") : UIImage(systemName: "heart")
                cell.likeButton.setImage(img, for: .normal)
                
                cell.commentButton.setTitle("댓글 \(post.comments.count)개 모두 보기", for: .normal)
            }
            .disposed(by: disposeBag)
        

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
    
    func findIndexTableButton(_ sender: UIButton) -> IndexPath {
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            print("button is not contained in a table view cell")
            return IndexPath()
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return IndexPath()
        }
        return indexPath
    }
    
    @IBAction func onID(_ sender: UIButton) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "FriendVC") as? FriendViewController else { return }
        
        let indexPath = findIndexTableButton(sender)
        nextVC.user = allPosts[indexPath.row].user
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func onLikeButton(_ sender: UIButton) {
        let indexPath = findIndexTableButton(sender)
        
        guard let cell = tableView.cellForRow(at: indexPath) as? HomeTableViewCell else { return }
        
        homeViewModel.postsObservable
            .map { posts in
                let post = posts[indexPath.row]
                
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
//        let post = allPosts[indexPath.row]
//        if cell.isLike == true {
//            DatabaseManager.shared.deleteLike(from: User.currentUser, to: post.user, cuid: post.cuid) {
//
//            }
//            cell.postLikeLabel.text = "좋아요 \(post.likes.count - 1)개"
//            cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
//        } else {
//            DatabaseManager.shared.updateLike(from: User.currentUser, to: post.user, cuid: post.cuid) {
//
//            }
//            cell.postLikeLabel.text = "좋아요 \(post.likes.count + 1)개"
//            cell.likeButton.setImage(UIImage(named: "heartFill"), for: .normal)
//        }
//        cell.isLike = !cell.isLike
    }
    
    @IBAction func onComment(_ sender: UIButton) {
        let indexPath = findIndexTableButton(sender)
        
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "CommentVC") as? CommentViewController else { return }
        let post = allPosts[indexPath.row]
        nextVC.post = post
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}



