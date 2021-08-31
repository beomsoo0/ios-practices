//
//  FollowViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/27.
//

import UIKit

class FollowViewController: UIViewController {

    var isFollow: Bool!
    var followUids: [String]!
    var followerUids: [String]!
    var followUsers = [User]()
    var followerUsers = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        
        for followUid in followUids {
            DatabaseManager.shared.fetchUser(uid: followUid) { [weak self] user in
                self?.followUsers.append(user)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.updateUI()
                }
            }
        }
        for followerUid in followerUids {
            DatabaseManager.shared.fetchUser(uid: followerUid) { [weak self] user in
                self?.followerUsers.append(user)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.updateUI()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    
    func updateUI() {
        if isFollow == true {
            followButton.setTitle("\(followUsers.count) 팔로잉", for: .normal)
            followerButton.setTitle("\(followerUsers.count) 팔로워", for: .normal)
            titleLabel.text = "팔로잉"
        } else {
            followButton.setTitle("\(followUsers.count) 팔로우", for: .normal)
            followerButton.setTitle("\(followerUsers.count) 팔로잉", for: .normal)
            titleLabel.text = "팔로워"
        }
    }
    
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followerButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func onFollow(_ sender: Any) {
        if isFollow == true {
            
        }
        else {
            isFollow = !isFollow
            updateUI()
            self.tableView.reloadData()
        }
    }
    @IBAction func onFollower(_ sender: Any) {
        if isFollow == true {
            isFollow = !isFollow
            updateUI()
            self.tableView.reloadData()
        }
        else {

        }
    }
}

extension FollowViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isFollow == true ? followUsers.count : followerUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "FollowTableViewCell") as? FollowTableViewCell else { return UITableViewCell() }
        let users = isFollow == true ? followUsers : followerUsers
        let user = users[indexPath.row]
        cell.profileImage.image = user.profileImage
        cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.width * 0.5
        cell.profileID.text = user.id
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "FriendVC") as? FriendViewController else { return }
        let users = isFollow == true ? followUsers : followerUsers
        let user = users[indexPath.row]
        nextVC.user = user
        self.navigationController?.pushViewController(nextVC, animated: true)
        return
    }
    
    
}

class FollowTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileID: UILabel!
    
}
