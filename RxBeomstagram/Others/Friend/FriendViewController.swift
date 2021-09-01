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
    
    // MARK - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.idText
            .subscribe(onNext: {
                self.navigationItem.title = $0
            })
            .disposed(by: disposeBag)
        
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
        viewModel.followers
            .map{ "\($0.count)\n\n팔로우" }
            .subscribe(onNext: {
                self.followerCountButton.setTitle($0, for: .normal)
            })
            .disposed(by: disposeBag)
        // follow
        viewModel.follows
            .map{ "\($0.count)\n\n팔로워" }
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
        

        viewModel.posts
            .bind(to: collectionView.rx.items(cellIdentifier: "PostCollectionViewCell", cellType: PostCollectionViewCell.self)) { index, item, cell in
                cell.postImage.image = item.image
                cell.post = item
            }
            .disposed(by: disposeBag)
        
        viewModel.isFollowing
            .subscribe(onNext: {
                if $0 == true {
                    self.followButton.setTitle("팔로잉", for: .normal)
                    self.followButton.backgroundColor = .systemBackground
                } else {
                    self.followButton.setTitle("팔로우", for: .normal)
                    self.followButton.backgroundColor = .systemBlue
                }
            })
            .disposed(by: disposeBag)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
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
        viewModel.changeFollowObserver.onNext(AuthManager.shared.currentUid()!)
    }
    
    
    @IBAction func onFollower(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "FollowVC") as? FollowViewController else { return }

        var followUids: [String] = []
        var followerUids: [String] = []
        
        var user = User(uid: "", id: "", name: "")
        do {
            user = try viewModel.userSubject.value()
        } catch {}
        
        followUids = user.follows
        followerUids = user.followers
        
        let followViewModel = FollowViewModel(isFollow: false, followUids: followUids, followerUids: followerUids)
        nextVC.viewModel = followViewModel
        nextVC.isFollow = false
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func onFollow(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "FollowVC") as? FollowViewController else { return }

        var followUids: [String] = []
        var followerUids: [String] = []
        
        var user = User(uid: "", id: "", name: "")
        do {
            user = try viewModel.userSubject.value()
        } catch {}
        
        followUids = user.follows
        followerUids = user.followers
        
        let followViewModel = FollowViewModel(isFollow: true, followUids: followUids, followerUids: followerUids)
        nextVC.viewModel = followViewModel
        nextVC.isFollow = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}


extension FriendViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpacing: CGFloat = 1
        let width: CGFloat = (collectionView.bounds.width - itemSpacing) / 3
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "ContentVC") as? ContentViewController else { return }

        var posts: [Post] = []
        do {
            posts = try viewModel.userSubject.value().posts
        } catch { }
        
        let contentViewModel = ContentViewModel(posts)
        nextVC.viewModel = contentViewModel
        nextVC.indexPath = indexPath
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}

class FriendCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var postImage: UIImageView!
    var post: Post?
}
