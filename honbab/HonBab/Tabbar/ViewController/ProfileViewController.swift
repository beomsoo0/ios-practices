//
//  ProfileViewController.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/20.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import Action

class ProfileViewController: UIViewController, ViewModelBindType {
    
    // IBOutlet - Profile
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    // IBOutlet - Btn
    @IBOutlet weak var myPostBtn: UIButton!
    @IBOutlet weak var promiseBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var menuBtn: UIButton!
    // IBOutlet - TableView
    @IBOutlet weak var tableView: UITableView!
    
    // Property
    let bag = DisposeBag()
    var viewModel: ProfileViewModel!
  
    // Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    func uiSetting() {
        [myPostBtn, promiseBtn, likeBtn].forEach {
            $0?.layer.cornerRadius = 10
            $0?.setBackgroundColor(.lightGray, for: .normal)
            $0?.setBackgroundColor(.darkGray, for: .selected)
        }
        


//        viewModel.selected
//            .subscribe(onNext: { [unowned self] selected in
//                switch selected {
//                case .myPost:
//                    self.myPostBtn.isSelected = true
//                    self.promiseBtn.isSelected = false
//                    self.likeBtn.isSelected = false
//                case .promise:
//                    self.myPostBtn.isSelected = false
//                    self.promiseBtn.isSelected = true
//                    self.likeBtn.isSelected = false
//                case .like:
//                    self.myPostBtn.isSelected = false
//                    self.promiseBtn.isSelected = false
//                    self.likeBtn.isSelected = true
//                }
//            })
//            .disposed(by: bag)
    }
    
    func bindViewModel() {

        tableView.rx.setDelegate(self).disposed(by: bag)
        
        viewModel.curUserSubject
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] user in
                if let url = user.imgURL {
                    self.profileImgView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.7))])
                } else if let img = user.img {
                    self.profileImgView.image = img
                }
                self.profileImgView.layer.cornerRadius = self.profileImgView.bounds.width * 0.3
                self.nameLabel.text = user.name
            })
            .disposed(by: bag)
        
        
        viewModel.postsSubject
            .observeOn(MainScheduler.asyncInstance)
            .map { $0.sorted(by: { $0.postDate > $1.postDate }) }
            .bind(to: tableView.rx.items(cellIdentifier: "ProfileTableViewCell", cellType: ProfileTableViewCell.self)) { [unowned self] (idx, post, cell) in
                // Post
                if let imgURL = post.imgURL {
                    cell.postImgView.kf.setImage(with: imgURL, placeholder: nil, options: [.transition(.fade(0.7))])
                } else if let img = post.img {
                    cell.postImgView.image = img
                }
                cell.postTitleLabel.text = "(\(post.foodCategory)) \(post.place)"
                cell.postPromiseDateLabel.text = "날짜 : \(post.promiseDate_relative)"

                cell.postStatusLabel.text = "\(post.promise.curNum) / \(post.promise.maxPeople)"
                if post.promise.curNum == post.promise.maxPeople {
                    cell.postStatusLabel.textColor = .systemGray
                } else{
                    cell.postStatusLabel.textColor = .systemOrange
                }
                
                var dis = 0.0 // ditance 수정 필요
                self.viewModel.curUserSubject
                    .subscribe(onNext: { [unowned self] in
                        dis = post.calDistance(curUserPos: $0.curPosition ?? "0-0")
                    })
                    .disposed(by: bag)
                cell.postDistanceLabel.text = "거리 : \(String(format: "%.2fkm", dis))"

                // UI
                cell.postImgView.layer.cornerRadius = 8
            }
            .disposed(by: bag)

        // Btn Binding
        
        viewModel.selected
            .flatMap { [weak self] in
                Observable.from([
                    ($0 == .myPost, self?.myPostBtn),
                    ($0 == .promise, self?.promiseBtn),
                    ($0 == .like, self?.likeBtn)
                ])
            }
            .asDriver(onErrorJustReturn: (false, nil))
            .drive(onNext: { selected, btn in
                btn?.isSelected = selected
            })
            .disposed(by: bag)
        
        Observable.merge(
            myPostBtn.rx.tap.map { ProfilePostType.myPost },
            promiseBtn.rx.tap.map { ProfilePostType.promise },
            likeBtn.rx.tap.map { ProfilePostType.like }
            )
            .bind(to: viewModel.selected)
            .disposed(by: bag)

        
        // Push
        tableView.rx.itemSelected
            .withLatestFrom(Observable.combineLatest(tableView.rx.itemSelected, viewModel.postsSubject))
            .subscribe(onNext: { [unowned self] indexPath, posts in
                self.viewModel.pushPostVC(post: posts[indexPath.row], profileVM: self.viewModel).execute()
            })
            .disposed(by: bag)
        
        menuBtn.rx.action = viewModel.pushSettingVC()
    }


    deinit {
        print("@@@@@@ ProfileViewController Deinit @@@@@@")
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return CGFloat(120.0)
    }

}

class ProfileTableViewCell: UITableViewCell {
    @IBOutlet weak var postImgView: UIImageView!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postDistanceLabel: UILabel!
    @IBOutlet weak var postPromiseDateLabel: UILabel!
    @IBOutlet weak var postStatusLabel: UILabel!
}
