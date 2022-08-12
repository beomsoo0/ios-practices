//
//  IdSetViewController.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/20.
//

import UIKit
import RxSwift
class IdSetViewController: UIViewController, ViewModelBindType {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pswdField: UITextField!
    
    let bag = DisposeBag()
    var viewModel: RegisterViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetting()
    }
    
    func uiSetting() {
        self.navigationItem.title = "이메일 / 비밀번호"
        emailField.becomeFirstResponder()
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

    }
    
    deinit {
        print("@@@@@@@ IdSetViewController VC Deinit @@@@@@@@@@")
    }

}
