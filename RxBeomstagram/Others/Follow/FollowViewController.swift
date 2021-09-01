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

    var isFollow: Bool!
    
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
        
        viewModel.followSubject
            .observe(on: MainScheduler.instance)
            .map({ $0.count })
            .subscribe(onNext: {
                self.followButton.setTitle("\($0) 팔로잉", for: .normal)
            })
            .disposed(by: disposeBag)
        
        viewModel.followerSubject
            .observe(on: MainScheduler.instance)
            .map({ $0.count })
            .subscribe(onNext: {
                self.followerButton.setTitle("\($0) 팔로워", for: .normal)
            })
            .disposed(by: disposeBag)
        
        tableView.dataSource = nil
        if isFollow == true {
            viewModel.followSubject
                .observe(on: MainScheduler.instance)
                .bind(to: tableView.rx.items(cellIdentifier: "FollowTableViewCell", cellType: FollowTableViewCell.self)) { idx, item, cell in
                    cell.profileImage.image = item.profileImage
                    cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.width * 0.5
                    cell.profileID.text = item.id
                }
                .disposed(by: disposeBag)
        } else {
            viewModel.followerSubject
                .observe(on: MainScheduler.instance)
                .bind(to: tableView.rx.items(cellIdentifier: "FollowTableViewCell", cellType: FollowTableViewCell.self)) { idx, item, cell in
                    cell.profileImage.image = item.profileImage
                    cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.width * 0.5
                    cell.profileID.text = item.id
                }
                .disposed(by: disposeBag)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followerButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func onFollow(_ sender: Any) {
//        if isFollow == true {
//
//        }
//        else {
//            isFollow = !isFollow
//            updateUI()
//            self.tableView.reloadData()
//        }
    }
    @IBAction func onFollower(_ sender: Any) {
//        if isFollow == true {
//            isFollow = !isFollow
//            updateUI()
//            self.tableView.reloadData()
//        }
//        else {
//
//        }
    }
}

extension FollowViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "FriendVC") as? FriendViewController else { return }
  
//        let users = isFollow == true ? followUsers : followerUsers
//        let user = users[indexPath.row]
//        nextVC.user = user
        self.navigationController?.pushViewController(nextVC, animated: true)
        return
    }
    
    
}

class FollowTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileID: UILabel!
    
}
