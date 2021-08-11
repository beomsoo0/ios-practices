//
//  TestViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/11.
//

import UIKit

class TestViewController: UIViewController {

    var currentModel = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("## test View Load")
        DatabaseManager.shared.fetchUserModel { userModel in
            self.currentModel = userModel
            print("## IN CLOSURE MODEL : \(self.currentModel)")
        }

    }

}
