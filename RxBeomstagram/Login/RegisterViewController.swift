//
//  RegisterViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/17.
//

import UIKit
import RxSwift

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    let viewModel = RegisterViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        
        emailField.rx.text
            .orEmpty
            .bind(to: viewModel.emailObserver)
            .disposed(by: disposeBag)
        
        idField.rx.text
            .orEmpty
            .bind(to: viewModel.idObserver)
            .disposed(by: disposeBag)
        
        nameField.rx.text
            .orEmpty
            .bind(to: viewModel.nameObserver)
            .disposed(by: disposeBag)
        
        passwordField.rx.text
            .orEmpty
            .bind(to: viewModel.passwordObserver)
            .disposed(by: disposeBag)
        
        viewModel.isValid
            .bind(to: registerButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        viewModel.isValid
            .map { $0 ? 1 : 0.3 }
            .bind(to: registerButton.rx.alpha)
            .disposed(by: disposeBag)
        
        registerButton.rx.tap
            .subscribe(onNext: {
                AuthManager.shared.createNewUser(email: self.emailField.text!, password: self.passwordField.text!, name: self.nameField.text!, id: self.idField.text!) { success in
                    if success {
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else {
                        self.alertMessage(message: "회원 가입에 실패하였습니다.")
                    }
                }
            })
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .subscribe(onNext: {
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
    }
    

    
    @IBAction func completeSelected(_ sender: Any) {
        AuthManager.shared.createNewUser(email: emailField.text!, password: passwordField.text!, name: nameField.text!, id: idField.text!) { success in
            if success {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                self.alertMessage(message: "회원 가입에 실패하였습니다.")
            }
        }
    }
    
    @IBAction func backSelected(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
