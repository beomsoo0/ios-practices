//
//  ChatViewController.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/20.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class ChatViewController: UIViewController, ViewModelBindType {

    // IBOutLet
    @IBOutlet weak var tableView: UITableView!
    
    // Property
    let bag = DisposeBag()
    var viewModel: ChatViewModel!
    
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
        
        viewModel.chatRoomsSubject
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: tableView.rx.items(cellIdentifier: "ChatViewTableViewCell", cellType: ChatViewTableViewCell.self)) { [unowned self] (idx, chatRoom, cell) in
                if let user = chatRoom.user {
                    if let imgURL = user.imgURL {
                        cell.profileImgView.kf.setImage(with: imgURL, placeholder: nil, options: [.transition(.fade(0.7))])
                    } else if let img = user.img {
                        cell.profileImgView.image = img
                    }
                    cell.nameLabel.text = " \(user.name)"
                }
                if let lastMsg = chatRoom.lastMsg {
                    cell.dateLabel.text = lastMsg.date_relative
                    cell.lastMsgTextView.text = lastMsg.content
                }
                
                // UI
                cell.profileImgView.layer.cornerRadius = cell.profileImgView.bounds.width * 0.4
                [cell.nameLabel, cell.dateLabel, cell.lastMsgTextView].forEach { $0?.sizeToFit() }
            }
            .disposed(by: bag)

        // Push ChatRoomVC
        tableView.rx.itemSelected
            .withLatestFrom(Observable.combineLatest(tableView.rx.itemSelected, viewModel.chatRoomsSubject))
            .map { [unowned self] in $1[$0.row] }
            .subscribe(onNext: { [unowned self] chatRoom in
                self.viewModel.pushChatRoomVC(otherUid: chatRoom.uid).execute()
            })
            .disposed(by: bag)
    }

    deinit {
        print("@@@@@@ ChatViewController Deinit @@@@@@")
    }
}

class ChatViewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMsgTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    
}
