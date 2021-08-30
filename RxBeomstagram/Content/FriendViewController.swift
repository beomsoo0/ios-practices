//
//  FriendViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/25.
//

import UIKit
import RxSwift
import RxCocoa

class FriendViewController: UIViewController {

    // MARK - Variables
    var viewModel: FriendViewModelType
    var disposeBag = DisposeBag()
    
    init(viewModel: FriendViewModelType = FriendViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        viewModel = FriendViewModel()
        super.init(coder: aDecoder)
    }
    
    var user: User!
    var isFollowing: Bool!
    
    // MARK - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.idText
            .bind(to: nameLabel.rx.text)
            .disposed(by: disposeBag)
        // profileImage
        viewModel.profileImage
            .bind(to: profileImage.rx.image)
            .disposed(by: disposeBag)
        // description
        viewModel.descriptionText
            .bind(to: descriptionLabel.rx.text)
            .dispose()
        // follower
        viewModel.followersText
            .subscribe(onNext: {
                self.followerCountButton.setTitle($0, for: .normal)
            })
            .disposed(by: disposeBag)
        // follow
        viewModel.followsText
            .subscribe(onNext: {
                self.followCountButton.setTitle($0, for: .normal)
            })
            .disposed(by: disposeBag)
        // posts
        viewModel.postsCountText
            .subscribe(onNext: {
                self.postCountButton.setTitle($0, for: .normal)
            })
            .disposed(by: disposeBag)
     
        updateUI()
        
        collectionView.dataSource = nil
        
        viewModel.posts
            .bind(to: collectionView.rx.items(cellIdentifier: "PostCollectionViewCell", cellType: PostCollectionViewCell.self)) { index, item, cell in
                cell.postImage.image = item.image
                cell.post = item
            }
            .disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        isFollowing = checkIsFollowing()
        followButtonUI()
    }
    // MARK - UI functions
    func updateUI() {
        profileImage.layer.cornerRadius = profileImage.bounds.width * 0.5
        buttonUI(postCountButton, followerCountButton, followCountButton)
    }
    func buttonUI(_ buttons: UIButton...) {
        buttons.forEach({
            $0.titleLabel?.lineBreakMode = .byWordWrapping
            $0.titleLabel?.textAlignment = .center
        })
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
    @IBOutlet weak var postCountButton: UIButton!
    @IBOutlet weak var followerCountButton: UIButton!
    @IBOutlet weak var followCountButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var followButton: UIButton!
    
    @IBAction func onFollowButton(_ sender: Any) {

        if isFollowing == true {
            DatabaseManager.shared.deleteFollow(from: User.currentUser, to: user) {
                
            }
            followerCountButton.setTitle("\(user.followers.count - 1)\n\n팔로워", for: .normal)
            
        } else {
            DatabaseManager.shared.updateFollow(from: User.currentUser, to: user) {
                // 모델 정보 reload && UI reload
            }
            followerCountButton.setTitle("\(user.followers.count + 1)\n\n팔로워", for: .normal)
        }
        isFollowing = !isFollowing
        followButtonUI()
    }
    
    
    @IBAction func onFollower(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "FollowVC") as? FollowViewController else { return }
        nextVC.isFollow = false
        nextVC.followUids = user.follows
        nextVC.followerUids = user.followers
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func onFollow(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "FollowVC") as? FollowViewController else { return }
        nextVC.isFollow = true
        nextVC.followUids = user.follows
        nextVC.followerUids = user.followers
        self.navigationController?.pushViewController(nextVC, animated: true)
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
        nextVC.allPosts = user.posts
        nextVC.indexPath = indexPath
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}

class FriendCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var postImage: UIImageView!
    var post: Post?
    
}
