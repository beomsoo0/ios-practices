//
//  FriendViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/25.
//

import UIKit

class FriendViewController: UIViewController {

    // MARK - Variables
    var user: User!
    var isFollowing: Bool!
    
    // MARK - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        isFollowing = checkIsFollowing()
        updateUI()
        followButtonUI()
    }
    // MARK - UI functions
    func updateUI() {
        collectionView.reloadData()
        
        self.navigationItem.backButtonTitle = ""
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.navigationBar.backgroundColor = .systemBackground
        
        self.navigationItem.title = "\(user.id)"
        profileImage.image = user.profileImage
        profileImage.layer.cornerRadius = profileImage.bounds.width * 0.5
        descriptionLabel.text = user.description
        nameLabel.text = user.name
        postCount.text = "\(user.posts.count)"
        followerCount.text = "\(user.followers.count)"
        followCount.text = "\(user.follows.count)"
    }
    
    func checkIsFollowing() -> Bool {
        guard let user = user else { return false }
        
        for follower in user.followers {
            if follower == User.currentUser.uid{
                return true
            }
        }
        return false
    }
    func followButtonUI() {
        if isFollowing == true {
            followButton.setTitle("팔로잉", for: .normal)
            followButton.backgroundColor = .systemBackground
        } else {
            followButton.setTitle("팔로우", for: .normal)
            followButton.backgroundColor = .systemBlue
        }
    }

    
    
    // MARK - Outlets
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postCount: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var followCount: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var followButton: UIButton!
    @IBAction func onFollowButton(_ sender: Any) {

        if isFollowing == true {
            DatabaseManager.shared.deleteFollow(from: User.currentUser, to: user) {
                
            }
            followerCount.text = "\(Int(followerCount.text!)! - 1)"
            
        } else {
            DatabaseManager.shared.updateFollow(from: User.currentUser, to: user) {
                // 모델 정보 reload && UI reload
            }
            followerCount.text = "\(Int(followerCount.text!)! + 1)"
        }
        isFollowing = !isFollowing
        followButtonUI()
    }
    
}


extension FriendViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return user?.posts.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCollectionViewCell", for: indexPath) as? PostCollectionViewCell else { return UICollectionViewCell() }
        cell.postImage.image = user?.posts[indexPath.item].image
        cell.post = user?.posts[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpacing: CGFloat = 1
        let width: CGFloat = (collectionView.bounds.width - itemSpacing) / 3
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "ContentVC") as? ContentViewController else { return }
        nextVC.posts = user?.posts
        nextVC.indexPath = indexPath
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}

class FriendCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var postImage: UIImageView!
    var post: Post?
    
}
