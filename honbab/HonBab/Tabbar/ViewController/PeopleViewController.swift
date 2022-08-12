//
//  PeopleViewController.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/25.
//

import UIKit
import RxSwift
import Kingfisher

class PeopleViewController: UIViewController, ViewModelBindType {

    // IBOutlet
    @IBOutlet weak var tableView: UITableView!
    
    // Property
    let bag = DisposeBag()
    var viewModel: PeopleViewModel!

    // Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // Binding
    func bindViewModel() {
        rx.viewWillAppear
            .take(1)
            .map { _ in () }
            .bind(to: viewModel.fetching)
            .disposed(by: bag)
        
        viewModel.usersSubject
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: tableView.rx.items(cellIdentifier: "PeopleTableViewCell", cellType: PeopleTableViewCell.self)) { [unowned self] (idx, user, cell) in
                if let imgURL = user.imgURL {
                    cell.profileImgView.kf.setImage(with: imgURL, placeholder: nil, options: [.transition(.fade(0.7))])
                } else if let img = user.img {
                    cell.profileImgView.image = img
                }
                cell.nameLabel.text = user.name
                cell.subLabel.text = "\(user.age) \(user.gender)"
                
                // Push ChatRoomVC
                cell.chatBtn.rx.action = self.viewModel.pushChatRoomVC(idx: idx)
                
                // UI
                cell.profileImgView.layer.cornerRadius = cell.profileImgView.bounds.width * 0.4
                [cell.nameLabel, cell.subLabel].forEach { $0?.sizeToFit() }
            }
            .disposed(by: bag) 

    }

    deinit {
        print("@@@@@@ PeopleViewController Deinit @@@@@@")
    }
}

// TableView Cell
class PeopleTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var chatBtn: UIButton!
}
