//
//  RegisterViewController.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/20.
//

import UIKit
import RxSwift
import Action
class RegisterViewController: UIViewController, ViewModelBindType {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var completeBtn: UIBarButtonItem!
    @IBOutlet weak var backBtn: UIBarButtonItem!
   
    let bag = DisposeBag()
    var viewModel: RegisterViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        // First Fage Exception
        rx.viewWillAppear
            .map { _ in .idSet }
            .bind(to: viewModel.subViewSubject)
            .disposed(by: bag)
        
        // UI Setting
        viewModel.subViewSubject
            .skip(1)
            .subscribe(onNext: { [unowned self] subView in
                switch subView {
                case .idSet:
                    self.navigationItem.title = "이메일 / 비밀번호"
                    self.viewModel.loginValid
                        .bind(to: self.completeBtn.rx.isEnabled)
                        .disposed(by: self.bag)
                case .nameSet:
                    self.navigationItem.title = "이름 / 성별 / 생일"
                    self.viewModel.nameValid
                        .bind(to: self.completeBtn.rx.isEnabled)
                        .disposed(by: self.bag)
                case .imgSet:
                    self.navigationItem.title = "프로필 사진"
                    
                default:
                    break
                }
            })
            .disposed(by: bag)
        
        // SubView Present
        viewModel.subViewSubject
            .skip(1)
            .subscribe(onNext: { [unowned self] subView in
                switch subView {
                case .login:
                    self.viewModel.backAction.execute()
                case .complete:
                    self.viewModel.register()
                        .subscribe{ [unowned self] result in
                            switch result {
                            case .completed:
                                print("회원가입 성공")
                                self.viewModel.pushTabbarVC().execute()
                            case .error(let error):
                                print("회원가입 실패 error: ", error.localizedDescription)
                                self.viewModel.subViewSubject.onNext(.idSet)
                                self.viewModel.alertAction(title: "회원가입 실패", message: "가입 정보를 확인해 주세요.", animated: false).execute()
                            }
                        }
                        .disposed(by: self.bag)
                    
                default :
                    self.containerView.addSubview(self.children[subView.rawValue].view)
                    self.didMove(toParent: self.children[subView.rawValue])
                }
            })
            .disposed(by: bag)
        
        completeBtn.rx.tap
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.asyncInstance)
            .bind(to: viewModel.complete)
            .disposed(by: bag)
        
        backBtn.rx.tap
            .bind(to: viewModel.back)
            .disposed(by: bag)
    }
    
    deinit {
        print("@@@@@@@ RegisterViewController Deinit @@@@@@@@@@")
    }

    
}
