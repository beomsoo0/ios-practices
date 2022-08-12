//
//  LoginViewController.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/20.
//

import UIKit
import RxSwift
import RxCocoa

import FirebaseAuth
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

class LoginViewController: UIViewController, ViewModelBindType {

    // UI
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pswdField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    // SNS Btn
    @IBOutlet weak var kakaoBtn: UIButton!
    @IBOutlet weak var naverBtn: UIButton!
    @IBOutlet weak var facebookBtn: UIButton!
    @IBOutlet weak var googleBtn: UIButton!
    @IBOutlet weak var appleBtn: UIButton!
    
    let bag = DisposeBag()
    var viewModel: LoginViewModel!
    
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
        [loginBtn, registerBtn].forEach {
            $0?.layer.cornerRadius = 8
        }
        [kakaoBtn, naverBtn, facebookBtn, googleBtn, appleBtn].forEach {
            $0?.titleLabel?.text = ""
        }
        textFieldInit()
    }
    
    func bindViewModel() {
        
        emailField.rx.text
            .orEmpty
            .bind(to: viewModel.emailRelay)
            .disposed(by: bag)
        
        pswdField.rx.text
            .orEmpty
            .bind(to: viewModel.pswdRelay)
            .disposed(by: bag)
        
        viewModel.loginValid
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] in
                self?.loginBtn.isEnabled = $0
                self?.loginBtn.alpha = $0 ? 1 : 0.7
            })
            .disposed(by: bag)
        
        // Login Thread??
        loginBtn.rx.tap
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                self.viewModel.login()
                    .subscribe { [weak self] success in
                        switch success {
                        case .completed:
                            print("로그인 성공")
                            self?.textFieldInit()
                            self?.viewModel.pushTabbarVC().execute()
                        case .error(let error):
                            print("로그인 오류 \(error.localizedDescription)")
                            self?.viewModel.alertAction(title: "로그인 실패", message: "이메일, 패스워드를 확인해주세요.", animated: true).execute()
                        }
                    }
                    .disposed(by: self.bag)
            })
            .disposed(by: bag)
        
        registerBtn.rx.action = viewModel.pushRegisterVC()
    }

    func textFieldInit() {
        [emailField, pswdField].forEach {
            $0?.text = ""
            $0?.resignFirstResponder()
        }
    }
    
    
}
