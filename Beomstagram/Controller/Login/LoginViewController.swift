//
//  LoginViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func loginSeleted(_ sender: Any) {
        AuthManager.shared.loginUser(email: email.text!, password: password.text!) { success in
            DispatchQueue.main.async {
                if success {
                    let TabBarVC = self.storyboard?.instantiateViewController(identifier: "TabBarVC")
                    TabBarVC?.modalPresentationStyle = .fullScreen
                    self.present(TabBarVC!, animated: true, completion: nil)
                }
                else {
                    let alert = UIAlertController(title: "로그인 실패", message: "아이디와 비밀번호를 다시 확인해주세요", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
