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

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addContentButton: UIButton!

    let viewModel = HomeViewModel()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUserInfo()
        fetchPostsInfo()
        
        tableView.dataSource = nil
        collectionView.dataSource = nil
        
        // story
        viewModel.usersObservable
            .map({ users -> [User] in
                var u: [User] = []
                users.forEach { user in
                    if user.uid == AuthManager.shared.currentUid() {
                        u.insert(user, at: 0)
                    } else {
                        u.append(user)
                    }
                }
                return u
            })
            .observe(on: MainScheduler.instance)
            .bind(to: collectionView.rx.items(cellIdentifier: "HomeCollectionViewCell", cellType: HomeCollectionViewCell.self)) { index, item, cell in
                cell.storyImageView.image = item.profileImage
                cell.storyImageView.layer.cornerRadius = cell.storyImageView.bounds.width * 0.5
                cell.storyIDLabel.text = item.id
            }
            .disposed(by: disposeBag)
        
        // feed
        viewModel.postsObservable
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: "HomeTableViewCell", cellType: HomeTableViewCell.self)) { index, item, cell in
                
                let user = item.user
                let post = item
                
                cell.profileImage.image = user.profileImage
                cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.width * 0.5
                cell.profileID.setTitle(user.id, for: .normal)
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
                self.tabBarController?.selectedIndex = 2
            })
            .disposed(by: disposeBag)
        
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        
    }

    // cur유저 팔로우, comment 유저 정보 fetching
    func fetchUserInfo() {
        
        var user = User()
        do {
            user = try viewModel.curUserObservable.value()
        } catch { }
        user.fetchFollowUsers() // followUsers Fetching (시간 좀 걸림)
        user.posts.forEach { post in
            post.comments.forEach { comment in
                comment.fetchCommentUser()
            }
        }
        viewModel.curUserObservable.onNext(user)
    }
    
    func fetchPostsInfo() {
        
        var posts = [Post]()
        do {
            posts = try viewModel.postsObservable.value()
        } catch { }
        
        var uid = [String]()
        posts.forEach { post in
            if uid.contains(post.user.uid) == false {
                post.user.fetchFollowUsers()
                uid.append(post.user.uid)
            }
            post.comments.forEach { comment in
                comment.fetchCommentUser()
            }
        }
        posts.forEach { post in
            post.user.posts = post.user.posts.sorted { $0.cuid > $1.cuid }
        }
        let sorted = posts.sorted { $0.cuid > $1.cuid }
        viewModel.postsObservable.onNext(sorted)
        
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
            let posts = try viewModel.postsObservable.value()
            post = posts[indexPath.row]
        } catch { }

        var commentUser = [User]()
        post.comments.map { comment in
            DatabaseManager.shared.fetchUser(uid: comment.uid) { user in
                commentUser.append(user)
            }
        }
        let commentViewModel = CommentViewModel(post: post)
        nextVC.viewModel = commentViewModel
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}



