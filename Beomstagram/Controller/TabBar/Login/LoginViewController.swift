//
//  LoginViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit

//View
class LoginViewController: UIViewController {

    var currentUser = UserModel.shared
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func loginSeleted(_ sender: Any) {
        resignKeyBoard(email, password)
        login(email: email.text, password: password.text)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearTextField(email, password)
    }
    
    func resignKeyBoard(_ textFields: UITextField...) {
        for textField in textFields {
            textField.resignFirstResponder()
        }
    }
    
    func clearTextField(_ textFields: UITextField...) {
        for textField in textFields {
            textField.text?.removeAll()
        }
    }
    
    private func login(email: String?, password: String?) {
        guard email != nil, password != nil else {
            print("@@@nil 발견@@@")
            return
        }
        
            AuthManager.shared.loginUser(email: email!, password: password!) { success in
                if success {
                    DatabaseManager.shared.fetchCurrentUserModel(userModel: self.currentUser) {
                        DispatchQueue.main.async {
                            let TabBarVC = self.storyboard?.instantiateViewController(identifier: "TabBarVC")
                            TabBarVC?.modalPresentationStyle = .fullScreen
                            self.present(TabBarVC!, animated: true, completion: nil)
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "로그인 실패", message: "아이디 또는 비밀번호가 일치하지 않습니다.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    

