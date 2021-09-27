//
//  LogOutViewController.swift
//  SNS_Login
//
//  Created by 김범수 on 2021/09/26.
//

import UIKit
import KakaoSDKAuth
import KakaoSDKUser
import RxSwift
import FirebaseAuth

class LogOutViewController: UIViewController {

    @IBOutlet weak var uidLabel: UILabel!
    
    let authManager = AuthManager.shared
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func firLogOutSelected(_ sender: Any) {
        authManager.firlogOut()
            .subscribe { _ in
                print("Firebase logout() success.")
                self.dismiss(animated: true, completion: nil)
            } onError: { error in
                print("Firebase logout() Fail.")
                print(error)
            }
            .disposed(by: self.bag)

    }
    @IBAction func kakaoLogOutSelected(_ sender: Any) {
        authManager.kakaoLogOut()
            .subscribe { _ in
                print("Kakao logout() success.")
                self.dismiss(animated: true, completion: nil)
            } onError: { error in
                print("Kakao logout() Fail.")
                print(error)
            }
            .disposed(by: self.bag)
    }

    @IBAction func kakaoUidSelected(_ sender: Any) {
        UserApi.shared.me { user, _ in
            if let user = user {
                if let id = user.id {
                    self.uidLabel.text = "\(id)"
                } else {
                    self.uidLabel.text = "No Uid"
                }
            } else {
                self.uidLabel.text = "No Uid"
            }
        }
    }
    
    @IBAction func firUidSelected(_ sender: Any) {
        guard let uid = authManager.firUid else {
            self.uidLabel.text = "No Uid"
            return
        }
        self.uidLabel.text = uid
    }
}
