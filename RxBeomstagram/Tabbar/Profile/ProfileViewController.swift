//
//  ProfileViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/18.
//

import UIKit
import RxSwift

class ProfileViewController: UIViewController {

    // MARK - Variables
    let viewModel = ProfileViewModel()
    var disposeBag = DisposeBag()
    
    var user = User.currentUser!
    
    // MARK - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.reloadData()
        
        // id
        viewModel.idText
            .subscribe(onNext: {
                self.idLabel.setTitle($0, for: .normal)
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
        self.navigationController?.isNavigationBarHidden = true
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
    

    @IBAction func onFollower(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "FollowVC") as? FollowViewController else { return }

        var followUids: [String] = []
        var followerUids: [String] = []
        
        var user = User(uid: "", id: "", name: "")
        do {
            user = try viewModel.curUserObservable.value()
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
            user = try viewModel.curUserObservable.value()
        } catch {}
        
        followUids = user.follows
        followerUids = user.followers
        
        let followViewModel = FollowViewModel(isFollow: true, followUids: followUids, followerUids: followerUids)
        nextVC.viewModel = followViewModel
        nextVC.isFollow = true
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    // MARK - Outlets
    @IBOutlet weak var idLabel: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postCountButton: UIButton!
    @IBOutlet weak var followerCountButton: UIButton!
    @IBOutlet weak var followCountButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func onAddContent(_ sender: Any) {
        self.tabBarController?.selectedIndex = 2
    }
    @IBAction func onSetting(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "SettingVC") as? SettingViewController else { return }
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    @IBAction func onEditProfile(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "EditVC") as? EditProfileViewController else { return }
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}
