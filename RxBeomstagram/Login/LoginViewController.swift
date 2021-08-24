//
//  ViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/17.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.resignKeyBoard(emailField, passwordField)
    }
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func loginSelected(_ sender: Any) {
        AuthManager.shared.loginUser(email: emailField.text!, password: passwordField.text!) { success in
            if success {
                guard let uid = AuthManager.shared.currentUid() else { return }
                DatabaseManager.shared.fetchUser(uid: uid) {user in
                    User.currentUser = user
                    self.presentModalVC(vcName: "TabbarVC")
                }
            } else {
                self.alertMessage(message: "로그인 정보를 확인해주세요.")
            }
        }
    }
    
    @IBAction func registerSelected(_ sender: Any) {
        self.presentModalVC(vcName: "RegisterVC")
    }
    
}

