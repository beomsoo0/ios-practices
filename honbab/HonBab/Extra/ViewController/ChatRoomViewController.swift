//
//  ChatRoomViewController.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/26.
//

import UIKit
import Action
import RxSwift
import Kingfisher
import RxViewController

class ChatRoomViewController: UIViewController, ViewModelBindType {

    // IBOutlet
    @IBOutlet weak var msgTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var backBtn: UIBarButtonItem!
    
    let bag = DisposeBag()
    var viewModel: ChatRoomViewModel!
    
    // Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //In ViewDidLoad (For TableView Reverse)
        tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi))
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func bindViewModel() {
        
        tableView.rx.willBeginDragging
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
            .map{ _ in ()}
            .bind(to: viewModel.fetching)
            .disposed(by: bag)
        
        // Bind UI
        msgTF.rx.text
            .orEmpty
            .bind(to: viewModel.contentRelay)
            .disposed(by: bag)

        sendBtn.rx.tap
            .bind(to: viewModel.sending)
            .disposed(by: bag)
        
        viewModel.complete
            .filter { [unowned self] _ in self.tableView.contentSize.height != 0 }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] _ in
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
                self.msgTF.text = ""
            })
            .disposed(by: bag)
        
        viewModel.chatRoomSubject
            .observeOn(MainScheduler.asyncInstance)
            .map { $0.messages }
            .bind(to: tableView.rx.items) { [unowned self] (tv, row, msg) -> UITableViewCell in
                let indexPath = IndexPath.init(item: row, section: 0)
                
                if msg.fromUid == AuthManager.shared.curUid()! {
                  let cell = tv.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell

                    cell.msgLabel.text = msg.content
                    cell.msgLabel.numberOfLines = 0
                    cell.dateLabel.text = msg.date_hour_minute
                    
                    //In cellForRowAtIndexPath (For TableView Reverse)
                    cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                    cell.layer.borderWidth = 1.0
                    cell.layer.borderColor = UIColor.systemBackground.cgColor
                    return cell
                } else {
                    let cell = tv.dequeueReusableCell(withIdentifier: "OtherMessageCell", for: indexPath) as! OtherMessageCell

                    self.viewModel.chatRoomSubject
                        .map { $0.user }
                        .subscribe(onNext: { [unowned self] user in
                            guard let user = user else { return }
                            if let imgURL = user.imgURL {
                                cell.profileImgView.kf.setImage(with: imgURL, placeholder: nil, options: [.transition(.fade(0.7))])
                            } else if let img = user.img {
                                cell.profileImgView.image = img
                            }
                            cell.profileImgView.layer.cornerRadius = cell.profileImgView.bounds.width / 2
                            cell.nameLabel.text = user.name
                        })
                        .disposed(by: self.bag)
         
                    cell.msgLabel.text = msg.content
                    cell.msgLabel.numberOfLines = 0
                    cell.dateLabel.text = msg.date_hour_minute
                    
                    //In cellForRowAtIndexPath (For TableView Reverse)
                    cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                    cell.layer.borderWidth = 1.0
                    cell.layer.borderColor = UIColor.systemBackground.cgColor
                    
                    return cell
                }
            }
            .disposed(by: bag)


        backBtn.rx.tap
            .bind(to: viewModel.back)
            .disposed(by: bag)
    }

    
}


class MyMessageCell: UITableViewCell {
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var msgImgView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
}

class OtherMessageCell: UITableViewCell {
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var msgImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
}
