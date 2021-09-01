//
//  ContentViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/24.
//

import UIKit
import RxSwift
import RxCocoa


class ContentViewController: UIViewController {

    var viewModel: ContentViewModelType
    var disposeBag = DisposeBag()
    
    init(viewModel: ContentViewModel = ContentViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        viewModel = ContentViewModel()
        super.init(coder: aDecoder)
    }

    var allPosts: [Post]!
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "게시물"

        // feed
        
        viewModel.postsObservable
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: "ContentTableViewCell", cellType: ContentTableViewCell.self)) { index, item, cell in
                
                let user = item.user
                let post = item
                
                cell.profileImage.image = user.profileImage
                cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.width * 0.5
                cell.profileID.setTitle(user.id, for: .normal)
                cell.postImage.image = post.image
                
                cell.postContent.text = user.id + "  " + post.content
                

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
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func onID(_ sender: UIButton) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "FriendVC") as? FriendViewController else { return }
        let indexPath = findIndexTableButton(sender)
        guard let cell = tableView.cellForRow(at: indexPath) as? ContentTableViewCell else { return }
        let user = cell.post.user
        
        let friendViewModel = FriendViewModel(user)
        nextVC.viewModel = friendViewModel
        self.navigationController?.pushViewController(nextVC, animated: true)
        
    }
    
    @IBAction func onLikeButton(_ sender: UIButton) {
        let indexPath = findIndexTableButton(sender)
        guard let cell = tableView.cellForRow(at: indexPath) as? ContentTableViewCell else { return }
        
        viewModel.likeObserver.onNext((cell.post, cell.isLike))
    }
    
    @IBAction func onComment(_ sender: UIButton) {
        let indexPath = findIndexTableButton(sender)
        
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "CommentVC") as? CommentViewController else { return }
        let post = allPosts[indexPath.row]
        nextVC.post = post
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}

extension ContentViewController: UITableViewDelegate {
    
}

class ContentTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileID: UIButton!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postLikeLabel: UILabel!
    @IBOutlet weak var postContent: UITextView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    var isLike: Bool!
    var post: Post!
}
