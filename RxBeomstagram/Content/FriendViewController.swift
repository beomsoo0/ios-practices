//
//  FriendViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/25.
//

import UIKit

class FriendViewController: UIViewController {

    // MARK - Variables
    var user: User?
    var followFlag = false
    
    // MARK - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        updateUI()
        followButtonUI()
    }
    // MARK - UI functions
    func updateUI() {
        collectionView.reloadData()
        
        self.navigationItem.backButtonTitle = ""
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.navigationBar.backgroundColor = .systemBackground
        
        guard let user = user else { return }
        self.navigationItem.title = "\(user.id)"
        profileImage.image = user.profileImage
        profileImage.layer.cornerRadius = profileImage.bounds.width * 0.5
        descriptionLabel.text = user.description
        nameLabel.text = user.name
        postCount.text = "\(user.posts.count)"
        followerCount.text = "\(user.followers.count)"
        followCount.text = "\(user.follows.count)"
    }
    
    func followButtonUI() {
        guard let user = user else { return }
        
        // 1. Model에서 이름으로 유저 비교하는 메소드 만들기
        // 2. user의 follower 목록에서 curUser 있는지 확인
        // 3. 있으면 팔로잉 / 없으면 팔로우 표시 // flag 변수
        // 4. curUser의 follow목록도 업데이트
        
        
//        user.followers.contains { <#User#> in
//            <#code#>
//        }
        
        if followFlag == true {
            isFollowing()
        } else {
            isNonFollowing()
        }
        
    }
    
    func isFollowing() {
        followButton.setTitle("팔로잉", for: .normal)
        followButton.backgroundColor = .systemBackground
        followFlag = true
    }
    func isNonFollowing() {
        followButton.setTitle("팔로우", for: .normal)
        followButton.backgroundColor = .systemBlue
        followFlag = false
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
        // 1. 위에서 만든 flag 이용
        // 2. follow 누르면 DB에 curUser 추가
        // 3. following 누르면 DB에 curUser 제거
        // 4. curUser의 follow목록도 업데이트
        
        followFlag = !followFlag
        if followFlag == true {
            followerCount.text = "\(Int(followerCount.text!)! + 1)"
            isFollowing()
        } else {
            followerCount.text = "\(Int(followerCount.text!)! - 1)"
            isNonFollowing()
        }
        
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
        nextVC.user = user
        nextVC.indexPath = indexPath
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}

class FriendCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var postImage: UIImageView!
    var post: Post?
    
}
