//
//  ContentViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/24.
//

import UIKit

class ContentViewController: UIViewController {

    var user: User?
    var posts: [Post]?
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "게시물"
//        tableView.reloadData()
       // tableView.reloadData()
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
        if let user = posts?[indexPath.row].user {
            nextVC.user = user
        } else {
            nextVC.user = self.user
        }
        //nextVC.user = posts?[indexPath.row].user
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}

extension ContentViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let user = user {
            return user.posts.count
        } else if let posts = posts {
            return posts.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContentTableViewCell") as? ContentTableViewCell else { return UITableViewCell() }
        var profileImage = UIImage(named: "default_profile")
        var profileID = "No ID"
        var postImage = UIImage(named: "default_profile")
        var postContent = "No Content"
        
        if let user = user {
            profileImage = user.profileImage
            profileID = user.id
            postImage = user.posts[indexPath.row].image
            postContent = user.posts[indexPath.row].content
        } else if let posts = posts {
            profileImage = posts[indexPath.row].user?.profileImage
            profileID = posts[indexPath.row].user?.id ?? "No ID"
            postImage = posts[indexPath.row].image
            postContent = posts[indexPath.row].content
        }
        cell.profileImageView.image = profileImage
        cell.profileImageView.layer.cornerRadius = cell.profileImageView.bounds.width * 0.5
        cell.profileIDButton.setTitle(profileID, for: .normal)
        cell.postImageView.image = postImage
        //cell.postLikeLabel.text
        cell.postContentTextView.text = postContent
        //cell.commentButton
        //cell.curProfileImage.image
        return cell
    }
}

class ContentTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileIDButton: UIButton!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postLikeLabel: UILabel!
    @IBOutlet weak var postContentTextView: UITextView!
}
