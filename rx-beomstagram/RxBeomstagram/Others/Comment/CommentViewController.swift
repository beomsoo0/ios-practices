//
//  CommentViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/27.
//

import UIKit
import RxSwift
import RxCocoa

class CommentViewController: UIViewController {

    // MARK - Variables
    var viewModel: CommentViewModelType
    var disposeBag = DisposeBag()
    
    init(viewModel: CommentViewModelType = CommentViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        viewModel = CommentViewModel()
        super.init(coder: aDecoder)
    }
    
    var post: Post!
    var users: [User] = []
    var comments: [Comment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false

        viewModel.postSubject
            .map({ $0.image })
            .bind(to: postUserProfile.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.postSubject
            .map({ $0.content })
            .bind(to: postContent.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.postSubject
            .map { $0.comments }
//        commentObservable
            .bind(to: tableView.rx.items(cellIdentifier: "CommentTableViewCell", cellType: CommentTableViewCell.self)) { index, item, cell in
                cell.commentText.text = item.ment
                cell.commentProfile.image = item.user.profileImage
                cell.commentProfile.layer.cornerRadius = cell.commentProfile.bounds.width * 0.5
            }
            .disposed(by: disposeBag)

        viewModel.curUserSubject
            .map({ $0.profileImage })
            .bind(to: curUserProfile.rx.image)
            .disposed(by: disposeBag)
        
        updateUI()
        
    }

    func updateUI() {
        self.navigationItem.title = "댓글"
        curUserProfile.layer.cornerRadius = curUserProfile.bounds.width * 0.5
    }
    
    
    @IBOutlet weak var postUserProfile: UIImageView!
    @IBOutlet weak var postContent: UITextView!
    @IBOutlet weak var curUserProfile: UIImageView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func onPushComment(_ sender: UIButton) {
        
        let comment = Comment(uid: AuthManager.shared.currentUid()!, ment: inputTextField.text ?? "")
        var post = Post()
        do {
            comment.user = try viewModel.curUserSubject.value()
            post = try viewModel.postSubject.value()
        } catch {}
        
        viewModel.pushCommentObservable.onNext(comment)
        Post.allPostsRx
            .subscribe(onNext: {
                $0.map { p in
                    if p.cuid == post.cuid {
                        p.comments.append(comment)
                    }
                }
            })
            .disposed(by: disposeBag)

        DatabaseManager.shared.pushComment(post: post, comment: comment, completion: {})
        
    }
    
}

extension CommentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "FriendVC") as? FriendViewController else { return }
        
        var post = Post()
        do {
            post = try viewModel.postSubject.value()
        } catch {}
        let user = post.comments[indexPath.row].user
        let friendViewModel = FriendViewModel(user)
        nextVC.viewModel = friendViewModel
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}

class CommentTableViewCell: UITableViewCell {
    @IBOutlet weak var commentProfile: UIImageView!
    @IBOutlet weak var commentText: UITextView!
    
}
