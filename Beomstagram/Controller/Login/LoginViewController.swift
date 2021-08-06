//
//  LoginViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit

//View
class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func loginSeleted(_ sender: Any) {
        resignKeyBoardLogin()
        login()
    }
    
}

//View Model
extension LoginViewController {
    
    private func resignKeyBoardLogin() {
        email.resignFirstResponder()
        password.resignFirstResponder()
    }
    
    private func login() {
        AuthManager.shared.loginUser(email: email.text!, password: password.text!) { success in
            DispatchQueue.main.async {
                if success {
                    DatabaseManager.shared.loadUserInfo()
                    DatabaseManager.shared.loadContents()
                    let TabBarVC = self.storyboard?.instantiateViewController(identifier: "TabBarVC")
                    TabBarVC?.modalPresentationStyle = .fullScreen
                    self.present(TabBarVC!, animated: true, completion: nil)
                }
                else {
                    let alert = UIAlertController(title: "로그인 실패", message: "아이디 또는 비밀번호가 일치하지 않습니다.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
}
