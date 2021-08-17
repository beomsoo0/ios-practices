//
//  RegisterViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/17.
//

import UIKit

class RegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
    }
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func completeSelected(_ sender: Any) {
        AuthManager.shared.createNewUser(email: emailField.text!, password: passwordField.text!, name: nameField.text!, id: idField.text!) { success in
            if success {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                self.alertMessage(title: "회원가입 실패", message: "회원 가입 정보를 확인해주세요.")
            }
        }
    }
    
    @IBAction func backSelected(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
