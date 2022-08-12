//
//  RegisterViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var id: UITextField!


    @IBAction func backSelected(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerSelected(_ sender: Any) {
        resignKeyBoard(email, password, name, id)
        register(email: email.text, password: password.text, name: name.text, id: id.text)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func resignKeyBoard(_ textFields: UITextField...) {
        for textField in textFields {
            textField.resignFirstResponder()
        }
    }
    
    func register(email: String?, password: String?, name: String?, id: String?) {
        guard email != nil, password != nil, name != nil, id != nil else {
            print("@@@ nil 발견 @@@")
            return
        }
        AuthManager.shared.createNewUser(email: email!, password: password!, name: name!, id: id!) { success in
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
