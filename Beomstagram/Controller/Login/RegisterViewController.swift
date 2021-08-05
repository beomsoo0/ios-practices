//
//  RegisterViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit

class RegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!

    @IBOutlet weak var name: UITextField!
    
    @IBOutlet weak var id: UITextField!
    @IBAction func registerSelected(_ sender: Any) {
        resignKeyBoardRegister()
        register()
    }
}

extension RegisterViewController {
    
    private func resignKeyBoardRegister() {
        password.resignFirstResponder()
        email.resignFirstResponder()
        name.resignFirstResponder()
        id.resignFirstResponder()
    }
    
    private func register() {
        AuthManager.shared.createNewUser(email: email.text!, password: password.text!, name: name.text!, id: id.text!) {success in
            DispatchQueue.main.async {
                if success {
                    self.dismiss(animated: true, completion: nil)
                }
                else {
                    let alert = UIAlertController(title: "회원가입 오류", message: "회원 가입 정보를 확인해주세요", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
}

