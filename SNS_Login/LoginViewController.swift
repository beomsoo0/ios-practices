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
import AuthenticationServices

class LoginViewController: UIViewController {

    @IBOutlet weak var kakaoBtn: UIButton!

    @IBOutlet weak var naverBtn: UIButton!
    @IBOutlet weak var facebookBtn: UIButton!
    @IBOutlet weak var googleBtn: UIButton!
    @IBOutlet weak var uidLabel: UILabel!
    @IBOutlet weak var kakaoUidBtn: UIButton!
    @IBOutlet weak var firUidBtn: UIButton!

    
    let bag = DisposeBag()
    let authManager = AuthManager.shared
    override func viewDidLoad() {
        super.viewDidLoad()

        let appleBtn = ASAuthorizationAppleIDButton(type: .signIn, style: .whiteOutline)
        appleBtn.frame = CGRect(x: naverBtn.frame.minX, y: naverBtn.frame.maxY + 20, width: naverBtn.bounds.width, height: naverBtn.bounds.height)
        self.view.addSubview(appleBtn)
        appleBtn.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        
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
    
    @IBAction func facebookBtnSelected(_ sender: Any) {
        authManager.facebookLogin(vc: self)
            .subscribe { success in
                if success == true {
                    self.loginSuccess()
                    print("true")
                } else {
                    print("true")
                }
            } onError: { error in
                print("error!!!!")
                print(error)
            } onCompleted: {
                print("complete")
            } onDisposed: {
                print("dispose")
            }
            .disposed(by: bag)

    }
    
    // Naver Login
    
    @IBAction func naverLoginSelected(_ sender: Any) {

//        authManager.naverLogin()
    }
    
    
    
    
    // Apple Login
    @objc
    func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

}

// Apple Login
extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            
            
//            let credential = OAuthProvider.credential(withProviderID: "apple.com",
//                                                          IDToken: idTokenString,
//                                                          rawNonce: nonce)
        
//            1. 애플 개발자 등록하여 로그인 기능 설정
//            2. 프로젝트 -> Capability에서 signin 추가
//            3. 현재 함수 내에서 firebase 로그인 기능 추가
        
            // For the purpose of this demo app, store the `userIdentifier` in the keychain.
//            self.saveUserInKeychain(userIdentifier)
            
            // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
//            self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)
        
        case let passwordCredential as ASPasswordCredential:
        
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            // For the purpose of this demo app, show the password credential as an alert.
//            DispatchQueue.main.async {
//                self.showPasswordCredentialAlert(username: username, password: password)
//            }
            
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Fail")
    }
    
    
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}






