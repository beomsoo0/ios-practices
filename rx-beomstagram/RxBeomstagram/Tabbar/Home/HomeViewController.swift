//
//  HomeViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/18.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController, ViewModelBindType {

    let disposeBag = DisposeBag()
    var viewModel: HomeViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addContentButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func bindViewModel() {
        viewModel.fetchUserInfo()
        viewModel.fetchPostsInfo()
        
        // story
        viewModel.storyUserObservable
            .observe(on: MainScheduler.instance)
            .bind(to: collectionView.rx.items(cellIdentifier: "HomeCollectionViewCell", cellType: HomeCollectionViewCell.self)) { index, item, cell in
                cell.storyImageView.image = item.profileImage
                cell.storyImageView.layer.cornerRadius = cell.storyImageView.bounds.width * 0.5
                cell.storyIDLabel.text = item.id
            }
            .disposed(by: disposeBag)
        
        // feed
        viewModel.feedPostsObservable
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: "HomeTableViewCell", cellType: HomeTableViewCell.self)) { index, item, cell in
                
                let user = item.user
                let post = item
                
                cell.profileImage.image = user.profileImage
                cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.width * 0.5
                cell.profileID.setTitle(user.id, for: .normal)
                
//                cell.profileID.rx.tap
//                    .subscribe(onNext: {
//                        let friendViewModel = FriendViewModel(user)
//                        self.coordinator?.pushFriendVC(model: friendViewModel)
//                    })
//                    .disposed(by: self.disposeBag)
                
                
                cell.postImage.image = post.image
                
                cell.postContentLabel.text = user.id + "  " + post.content
                

                // Like
                let curUid = AuthManager.shared.currentUid()!
                cell.isLike = post.likes.contains(curUid) ? true : false
                cell.post = item
                cell.postLikeLabel.text = "좋아요 \(post.likes.count)개"
                let img = cell.isLike == true ? UIImage(named: "heartFill") : UIImage(systemName: "heart")
                cell.likeButton.setImage(img, for: .normal)
                
                // Comment
                cell.commentButton.setTitle("댓글 \(post.comments.count)개 모두 보기", for: .normal)
            }
            .disposed(by: disposeBag)
        
        
        // Buttons
        addContentButton.rx.tap
            .subscribe(onNext: {
//                 self.coordinator?.tabbarIndex(index: 2)
                self.tabBarController?.selectedIndex = 2
            })
            .disposed(by: disposeBag)

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
        guard let cell = tableView.cellForRow(at: indexPath) as? HomeTableViewCell else { return }
        let user = cell.post.user

        let friendViewModel = FriendViewModel(user)
        nextVC.viewModel = friendViewModel
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func onLikeButton(_ sender: UIButton) {
        let indexPath = findIndexTableButton(sender)
        guard let cell = tableView.cellForRow(at: indexPath) as? HomeTableViewCell else { return }
        
        viewModel.likeObserver.onNext((cell.post, cell.isLike))
    }
    
    @IBAction func onComment(_ sender: UIButton) {
        let indexPath = findIndexTableButton(sender)
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "CommentVC") as? CommentViewController else { return }
        
        var post = Post()
        do {
            let posts = try viewModel.feedPostsObservable.value()
            post = posts[indexPath.row]
        } catch { }

        var commentUser = [User]()
        post.comments.forEach { comment in
            DatabaseManager.shared.fetchUser(uid: comment.uid) { user in
                commentUser.append(user)
            }
        }
        let commentViewModel = CommentViewModel(post: post)
        nextVC.viewModel = commentViewModel
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}



