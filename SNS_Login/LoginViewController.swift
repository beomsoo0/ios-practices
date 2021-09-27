//
//  LoginViewController.swift
//  SNS_Login
//
//  Created by 김범수 on 2021/09/26.
//

import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import RxSwift
import FirebaseAuth
import RxCocoa
import GoogleSignIn
import Firebase
import FBSDKLoginKit

class LoginViewController: UIViewController {

    @IBOutlet weak var kakaoBtn: UIButton!
    @IBOutlet weak var googleBtn: GIDSignInButton!
    @IBOutlet weak var naverBtn: UIButton!
    
    @IBOutlet weak var appleBtn: UIButton!
    
    @IBOutlet weak var uidLabel: UILabel!
    @IBOutlet weak var kakaoUidBtn: UIButton!
    @IBOutlet weak var googleUidBtn: UIButton!
    @IBOutlet weak var naverUidBtn: UIButton!
    @IBOutlet weak var facebookUidBtn: UIButton!
    @IBOutlet weak var appleUidBtn: UIButton!
    @IBOutlet weak var firUidBtn: UIButton!
    @IBOutlet weak var facebookBtn: FBLoginButton!
    
    let bag = DisposeBag()
    let authManager = AuthManager.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        googleBtn.style = .standard

//        facebookBtn
        
        let loginButton = FBLoginButton()
        loginButton.center = view.center
        view.addSubview(loginButton)
        
    }

    func loginSuccess() {
        guard let logOutVC = self.storyboard?.instantiateViewController(identifier: "logOutVC") as? LogOutViewController else { return }
        self.modalPresentationStyle = .fullScreen
        self.present(logOutVC, animated: true, completion: nil)
    }
    
    
    @IBAction func login(){
        authManager.kakaoLogin()
            .subscribe { _ in
                self.loginSuccess()
            } onError: { error in
                print("카톡 로그인 실패!!!", error)
            }
            .disposed(by: self.bag)
    }

    @IBAction func firUidSelected(_ sender: Any) {
        guard let uid = authManager.firUid else {
            self.uidLabel.text = "No Uid"
            return
        }
        self.uidLabel.text = uid
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
    
    @IBAction func googleBtnSelected(_ sender: Any) {
        authManager.googleLogin(vc: self)
            .subscribe { success in
                if success == true {
                    self.loginSuccess()
                    print("true")
                } else {
                    print("false")
                }
            } onError: { error in
                print("error")
            } onCompleted: {
                print("complete")
            } onDisposed: {
                print("dispose")
            }
            .disposed(by: bag)

    }
    
//    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
//      if let error = error {
//        print(error.localizedDescription)
//        return
//      }
//      // ...
//    }
    
}


