//
//  ViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/17.
//

import UIKit
import RxSwift
import SafariServices

class LoginViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var findPasswordButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    
    let viewModel = LoginViewModel()
    let disposeBag = DisposeBag()
    var coordinator: AppCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        
        emailField.rx.text
            .orEmpty
            .bind(to: viewModel.emailObserver)
            .disposed(by: disposeBag)

        passwordField.rx.text
            .orEmpty
            .bind(to: viewModel.passwordObserver)
            .disposed(by: disposeBag)

        viewModel.isValid
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.isValid
            .map { $0 ? 1 : 0.3 }
            .bind(to: loginButton.rx.alpha)
            .disposed(by: disposeBag)

        loginButton.rx.tap
            .subscribe(onNext: {
                AuthManager.shared.loginUser(email: self.emailField.text!, password: self.passwordField.text!) { [weak self] success in
                    if success {
                        
                        self?.coordinator?.pushHomeVC()
                    } else {
                        self?.alertMessage(message: "로그인 정보를 확인해주세요.")
                    }
                }
            })
            .disposed(by: disposeBag)

        registerButton.rx.tap
            .subscribe(onNext: {
                self.presentModalVC(vcName: "RegisterVC")
            })
            .disposed(by: disposeBag)
        
        findPasswordButton.rx.tap
            .subscribe(onNext: {
                self.openURL(urlString: "https://www.instagram.com/accounts/password/reset/")
            })
            .disposed(by: disposeBag)
        
        facebookLoginButton.rx.tap
            .subscribe(onNext: {
                self.openURL(urlString: "https://www.facebook.com/login.php?skip_api_login=1&api_key=124024574287414&kid_directed_site=0&app_id=124024574287414&signed_next=1&next=https%3A%2F%2Fwww.facebook.com%2Fdialog%2Foauth%3Fclient_id%3D124024574287414%26redirect_uri%3Dhttps%253A%252F%252Fwww.instagram.com%252Faccounts%252Fsignup%252F%26state%3D%257B%2522fbLoginKey%2522%253A%25221c0x5ynllrk8w1g588bjsnklwwvonldc19wly86p39jbf1bjwt7j%2522%252C%2522fbLoginReturnURL%2522%253A%2522%252Ffxcal%252Fdisclosure%252F%2522%257D%26scope%3Demail%26response_type%3Dcode%252Cgranted_scopes%26locale%3Dko_KR%26ret%3Dlogin%26fbapp_pres%3D0%26logger_id%3Db393094b-c2c3-4967-be88-8cc10ac79ef8%26tp%3Dunspecified&cancel_url=https%3A%2F%2Fwww.instagram.com%2Faccounts%2Fsignup%2F%3Ferror%3Daccess_denied%26error_code%3D200%26error_description%3DPermissions%2Berror%26error_reason%3Duser_denied%26state%3D%257B%2522fbLoginKey%2522%253A%25221c0x5ynllrk8w1g588bjsnklwwvonldc19wly86p39jbf1bjwt7j%2522%252C%2522fbLoginReturnURL%2522%253A%2522%252Ffxcal%252Fdisclosure%252F%2522%257D%23_%3D_&display=page&locale=ko_KR&pl_dbl=0")
            })
            .disposed(by: disposeBag)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.resignKeyBoard(emailField, passwordField)
    }

    private func openURL(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
}
