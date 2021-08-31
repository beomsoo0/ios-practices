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

        viewModel.postObservable
            .map({ $0.image })
            .bind(to: postUserProfile.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.postObservable
            .map({ $0.content })
            .bind(to: postContent.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.postObservable
            .map { $0.comments }
//        commentObservable
            .bind(to: tableView.rx.items(cellIdentifier: "CommentTableViewCell", cellType: CommentTableViewCell.self)) { index, item, cell in
                cell.commentText.text = item.ment
    
                // User 정보 가지고 있게 구현 예정
                DatabaseManager.shared.fetchUser(uid: item.uid) { user in
                    DispatchQueue.main.async {
                        cell.commentProfile.image = user.profileImage
                        cell.commentProfile.layer.cornerRadius = cell.commentProfile.bounds.width * 0.5
                    }
                }
            }
            .disposed(by: disposeBag)

        viewModel.curUserObservable
            .map({ $0.profileImage })
            .bind(to: curUserProfile.rx.image)
            .disposed(by: disposeBag)
        
        updateUI()
        
    }

    func updateUI() {
        self.navigationItem.title = "댓글"
        postUserProfile.layer.cornerRadius = postUserProfile.bounds.width * 0.5
//        curUserProfile.layer.cornerRadius = curUserProfile.bounds.width * 0.5
    }
    
    
    @IBOutlet weak var postUserProfile: UIImageView!
    @IBOutlet weak var postContent: UITextView!
    @IBOutlet weak var curUserProfile: UIImageView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func onPushComment(_ sender: UIButton) {
        
        let comment = Comment(uid: AuthManager.shared.currentUid()!, ment: inputTextField.text ?? "")
        viewModel.pushCommentObservable.onNext(comment)

        var post = Post()
        viewModel.postObservable
            .subscribe(onNext: {
                post = $0
            })
            .dispose()

        DatabaseManager.shared.pushComment(post: post, comment: comment, completion: {})
        
    }
    
}

extension CommentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "FriendVC") as? FriendViewController else { return }
        nextVC.user = users[indexPath.row]
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}

class CommentTableViewCell: UITableViewCell {
    @IBOutlet weak var commentProfile: UIImageView!
    @IBOutlet weak var commentText: UITextView!
    
}
