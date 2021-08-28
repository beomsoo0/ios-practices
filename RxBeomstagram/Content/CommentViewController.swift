//
//  CommentViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/27.
//

import UIKit

class CommentViewController: UIViewController {

    var post: Post!
    var users: [User] = []
    var comments: [Comment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        dump(post)
        for comment in post.comments{
            let uid = comment.uid

            comments.append(comment)
            print("!@!@", comment)
            //tableView.reloadData()
            DatabaseManager.shared.fetchUser(uid: uid) { [weak self] user in
                self?.users.append(user)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    func updateUI() {
        self.navigationItem.title = "댓글"
        
        postUserProfile.image = post.user.profileImage
        postUserProfile.layer.cornerRadius = postUserProfile.bounds.width * 0.5
        postContent.text = post.content
        
        
        curUserProfile.image = User.currentUser.profileImage
        curUserProfile.layer.cornerRadius = curUserProfile.bounds.width * 0.5
        
        
    }
    
    
    @IBOutlet weak var postUserProfile: UIImageView!
    @IBOutlet weak var postContent: UITextView!
    @IBOutlet weak var curUserProfile: UIImageView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func onPushComment(_ sender: UIButton) {
        DatabaseManager.shared.pushComment(from: User.currentUser, to: post, comment: inputTextField.text ?? "") {
            // 현재 post에 append
        }
        
    }
    
}

extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as? CommentTableViewCell else { return UITableViewCell() }
        
        cell.commentText.text = comments[indexPath.row].ment
        cell.commentProfile.image = users[indexPath.row].profileImage
        cell.commentProfile.layer.cornerRadius = cell.commentProfile.bounds.width * 0.5

        return cell
    }
    
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
