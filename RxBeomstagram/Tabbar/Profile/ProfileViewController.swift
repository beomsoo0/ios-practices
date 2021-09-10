//
//  ProfileViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/18.
//

import UIKit
import RxSwift

class ProfileViewController: UIViewController, ViewModelBindType {

    // MARK - Variables
    var viewModel: ProfileViewModel!
    var disposeBag = DisposeBag()

    // MARK - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK - UI functions
    
    func bindViewModel() {
        // id
        viewModel.idText
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { self.idLabel.setTitle($0, for: .normal) })
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
            .observe(on: MainScheduler.instance)
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

        var user = User(uid: "", id: "", name: "")
        do {
            user = try viewModel.curUserObservable.value()
        } catch {}

        let followViewModel = FollowViewModel(isFollow: false, user: user)
        nextVC.viewModel = followViewModel
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func onFollow(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "FollowVC") as? FollowViewController else { return }

        var user = User(uid: "", id: "", name: "")
        do {
            user = try viewModel.curUserObservable.value()
        } catch {}

        let followViewModel = FollowViewModel(isFollow: true, user: user)
        nextVC.viewModel = followViewModel
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
    
    @IBAction func onChange(_ sender: Any) {
        User.currentUser.id = "바뀜"

        User.currentUserRx
            .onNext(User.currentUser)
            
    }
}
