//
//  SideMenuViewController.swift
//  HonBab
//
//  Created by 김범수 on 2021/10/11.
//

import UIKit
import SafariServices
import RxSwift
import Action

//View
class SettingViewController: UIViewController, ViewModelBindType {

    // IBOutlet
    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // Property
    let bag = DisposeBag()
    var viewModel: SettingViewModel!
    
    // Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // Binding
    func bindViewModel() {
       
        viewModel.settingSubject
            .bind(to: tableView.rx.items(cellIdentifier: "SettingCell")) { [unowned self] (idx, setting, cell) in
                cell.textLabel?.text = setting.title
            }
            .disposed(by: bag)
        
        tableView.rx.itemSelected
            .withLatestFrom(Observable.combineLatest(tableView.rx.itemSelected, viewModel.settingSubject))
            .subscribe(onNext: { [unowned self] (indexPath, setting) in
                // section 아직 0
                switch setting[indexPath.row].title {
                case "프로필 편집":
                    self.didTabProfileEdit()
                case "친구 초대":
                    self.didTabFriendInvite()
                case "게시물 보관":
                    self.didTabSavedContents()
                case "네이버":
                    self.openURL(type: .naver)
                case "구글":
                    self.openURL(type: .google)
                case "다음":
                    self.openURL(type: .daum)
                case "로그아웃":
                    self.viewModel.logOutBtnSelected()
                        .observeOn(MainScheduler.asyncInstance)
                        .subscribe { [unowned self] success in
                            switch success {
                            case .completed:
                                self.viewModel.potToRootAction.execute()
                            case .error(let error):
                                print("로그아웃 실패 \(error.localizedDescription)")
                                let alert = UIAlertController(title: "로그아웃 실패", message: "로그아웃에 실패하였습니다.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                        .disposed(by: self.bag)
                default:
                    break
                }
            })
            .disposed(by: bag)
        
        backBtn.rx.action = viewModel.backAction
        
    }

    
    private func didTabProfileEdit() {
    }
    private func didTabFriendInvite() {
    }
    private func didTabSavedContents() {
    }
    
    private func openURL(type: SettingURLType) {
        let urlString: String
        
        switch type {
        case .naver: urlString = "https://www.naver.com/"
            
        case .google: urlString = "https://www.google.com/"
            
        case .daum: urlString = "https://www.daum.net/"
        }
        guard let url = URL(string: urlString) else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    
}

