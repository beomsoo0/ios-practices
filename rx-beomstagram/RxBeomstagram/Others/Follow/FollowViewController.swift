//
//  FollowViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/27.
//

import UIKit
import RxSwift
import RxCocoa

class FollowViewController: UIViewController {
    
    // MARK - Variables
    var viewModel: FollowViewModelType
    var disposeBag = DisposeBag()
    
    init(viewModel: FollowViewModelType = FollowViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        viewModel = FollowViewModel()
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        
        tableView.dataSource = nil
        
        viewModel.userSubject
            .map({ $0.followUsers.count })
            .subscribe(onNext: {
                self.followButton.setTitle("\($0) 팔로잉", for: .normal)
            })
            .disposed(by: disposeBag)

        viewModel.userSubject
            .map({ $0.followerUsers.count })
            .subscribe(onNext: {
                self.followerButton.setTitle("\($0) 팔로워", for: .normal)
            })
            .disposed(by: disposeBag)
        
        
        viewModel.followState
            .subscribe(onNext: {
                if $0 == true {
                    self.viewModel.userSubject
                        .map({ $0.followUsers })
                        .bind(to: self.tableView.rx.items(cellIdentifier: "FollowTableViewCell", cellType: FollowTableViewCell.self)) { idx, item, cell in
                            cell.profileImage.image = item.profileImage
                            cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.width * 0.5
                            cell.profileID.text = item.id
                            self.titleLabel.text = "팔로우"
                        }
                        .disposed(by: self.disposeBag)
                } else {
                    self.viewModel.userSubject
                        .map({ $0.followerUsers })
                        .bind(to: self.tableView.rx.items(cellIdentifier: "FollowTableViewCell", cellType: FollowTableViewCell.self)) { idx, item, cell in
                            cell.profileImage.image = item.profileImage
                            cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.width * 0.5
                            cell.profileID.text = item.id
                            self.titleLabel.text = "팔로워"
                        }
                        .disposed(by: self.disposeBag)
                }
            }).disposed(by: disposeBag)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followerButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func onFollow(_ sender: Any) {
        viewModel.followState.onNext(true)
    }
    @IBAction func onFollower(_ sender: Any) {
        viewModel.followState.onNext(false)
    }
}

extension FollowViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "FriendVC") as? FriendViewController else { return }
  
        var isFollow = Bool()
        var user = User()
        do {
            isFollow = try viewModel.followState.value()
            let u = try viewModel.userSubject.value()
            user = isFollow ? u.followUsers[indexPath.row] : u.followerUsers[indexPath.row]
        } catch { }
        let friendViewModel = FriendViewModel(user)
        nextVC.viewModel = friendViewModel
        self.navigationController?.pushViewController(nextVC, animated: true)
        return
    }
    
    
}

class FollowTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileID: UILabel!
    
}
