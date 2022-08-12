//
//  AuthManager.swift
//  SNS_Login
//
//  Created by 김범수 on 2021/09/27.
//

import FirebaseAuth
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import RxSwift
import GoogleSignIn
import Firebase
import FBSDKLoginKit
import AuthenticationServices
import NaverThirdPartyLogin
import Alamofire

struct LoginModel {
    var email: String
    var password: String
}

class AuthManager {
    
    static let shared = AuthManager()
    let bag = DisposeBag()
    
    // Firebase //
    var firUid: String? {
        return Auth.auth().currentUser?.uid
    }

    
    func firLogin(loginModel: LoginModel) -> Observable<Bool> {   
        return Observable.create() { emitter in
            Auth.auth().signIn(withEmail: loginModel.email, password: loginModel.password) { result, error in
                guard result != nil, error == nil else {
                    emitter.onError(error!)
                    return
                }
                emitter.onNext(true)
            }
            return Disposables.create {
                emitter.onCompleted()
            }
        }
    }
    
    func firLoginByCredential(credential: AuthCredential) -> Observable<Bool> {
        return Observable.create() { emitter in
            Auth.auth().signIn(with: credential) { result, error in
                guard result != nil, error == nil else {
                    emitter.onError(error!)
                    return
                }
                emitter.onNext(true)
            }
            return Disposables.create {
                emitter.onCompleted()
            }
        }
    }
    
    func firRegister(loginModel: LoginModel /* 유저 정보 추가로 받기 */) -> Observable<Bool> {
        return Observable.create() { emitter in
            
            Auth.auth().createUser(withEmail: loginModel.email, password: loginModel.password) { result, error in
                guard result != nil, error == nil else {
                    emitter.onError(error!)
                    return
                }
                
                // 유저 정보 DB에 저장
//                let uid = result!.user.uid
//                Service.shared.insertNewUser(uid: uid, user: user)
//                    .subscribe(onNext: { success in
//                        if success {
                            emitter.onNext(true)
//                        } else {
//                            emitter.onNext(false)
//                        }
//                    })
//                    .disposed(by: self.bag)
            }
            return Disposables.create {
                emitter.onCompleted()
            }
        }
    }
    
    func firlogOut() -> Observable<Bool> {
        return Observable.create { emitter in
            do {
                try Auth.auth().signOut()
                emitter.onNext(true)
            } catch {
                emitter.onError(error)
            }
            return Disposables.create {
                emitter.onCompleted()
            }
        }
    }
    
    // Kakao //
    func kakaoLogin() -> Observable<Bool> {
        // 토큰 유무 체크
        return Observable.create { emitter in
            
            if AuthApi.hasToken() {
                // 토큰 유효성 체크
                UserApi.shared.accessTokenInfo { _, error in
                    if error != nil { // 토큰 만료 시
                        if UserApi.isKakaoTalkLoginAvailable() { // 카톡 어플 있을 시
                            // 간편 로그인
                            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                                if let error = error {  // 로그인 실패
                                    print("토큰(O), 토큰 유효(X), 카톡 어플, 카톡 로그인(X)")
                                    emitter.onError(error)
                                } else {    // 로그인 성공
                                    _ = oauthToken
                                    self.kakaoToFirLogin()
                                        .subscribe { _ in
                                            emitter.onNext(true)
                                        } onError: { error in
                                            print("토큰(O), 토큰 유효(X), 카톡 어플, 카톡 로그인(O), 파베 로그인(X)")
                                            emitter.onError(error)
                                        }
                                        .disposed(by: self.bag)
                                }
                            }
                        } else { // 카톡 어플 없을 시
                            UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                                if let error = error {
                                    print("토큰(X), 사파리, 카톡 로그인(X)")
                                    emitter.onError(error)
                                } else {
                                    _ = oauthToken
                                    self.kakaoToFirLogin()
                                        .subscribe { _ in
                                            emitter.onNext(true)
                                        } onError: { error in
                                            print("토큰(X), 사파리, 카톡 로그인(O), 파베 로그인(X)")
                                            emitter.onError(error)
                                        }
                                        .disposed(by: self.bag)
                                }
                            }
                        }
                    } else { // 토큰 유효 시
                        print("@@@토큰 유효 시")
                        self.kakaoToFirLogin()
                            .subscribe { _ in
                                emitter.onNext(true)
                            } onError: { error in
                                print("토큰(O), 토큰 유효(O), 카톡 어플, 카톡 로그인(O), 파베 로그인(X)")
                                emitter.onError(error)
                            }
                            .disposed(by: self.bag)
                    }
                }
            } else { // 토큰 없을 시
                if UserApi.isKakaoTalkLoginAvailable() { // 카톡 어플 있을 시
                    // 간편 로그인
                    UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                        if let error = error {  // 로그인 실패
                            print("토큰(X), 카톡 어플, 카톡 로그인(X)")
                            emitter.onError(error)
                        } else {    // 로그인 성공
                            _ = oauthToken
                            self.kakaoToFirLogin()
                                .subscribe { _ in
                                    emitter.onNext(true)
                                } onError: { error in
                                    print("토큰(X), 카톡 어플, 카톡 로그인(O), 파베 로그인(X)")
                                    emitter.onError(error)
                                }
                                .disposed(by: self.bag)
                        }
                    }
                } else {
                    UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                        if let error = error {
                            print("토큰(X), 사파리, 카톡 로그인(X)")
                            emitter.onError(error)
                        } else {
                            _ = oauthToken
                            self.kakaoToFirLogin()
                                .subscribe { _ in
                                    emitter.onNext(true)
                                } onError: { error in
                                    print("토큰(X), 사파리, 카톡 로그인(O), 파베 로그인(X)")
                                    emitter.onError(error)
                                }
                                .disposed(by: self.bag)
                        }
                    }
                }
            }
            
            return Disposables.create {
                emitter.onCompleted()
            }
        }
    }

    
    func kakaoToFirLogin() -> Observable<Bool> {
        return Observable.create { emitter in
            print("@@@kakaoToFirLogin")
            UserApi.shared.me { kuser, error in
                if let error = error { // 유저 정보 로딩 실패
                    print("토큰(O), 토큰 만료(O), 카톡 어플(O), 로그인(X), 유저 정보(X)", error)
                } else { // 파이어베이스 로그인
                    let tmpEmail = "\(String(describing: kuser!.id!))@kakao.com"
                    let tmpPassword = "\(String(describing: kuser!.id!))kakao"
                    let loginModel = LoginModel(email: tmpEmail, password: tmpPassword)
                    
                    self.firSNSLogin(loginModel: loginModel)
                        .subscribe { bool in
                            emitter.onNext(bool)
                        } onError: { error in
                            emitter.onError(error)
                        }
                        .disposed(by: self.bag)

                }
            }
            return Disposables.create {
                emitter.onCompleted()
            }
        }
    }
    
    func firSNSLogin(loginModel: LoginModel) -> Observable<Bool> {
        return Observable.create { emitter in
            self.firRegister(loginModel: loginModel)
                .subscribe { _ in
                    print("파이어베이스 회원가입 성공")
                    self.firLogin(loginModel: loginModel)
                        .subscribe { _ in
                            print("파이어베이스 로그인 성공")
                            emitter.onNext(true)
                        } onError: { error in
                            print("파이어베이스 로그인 오류")
                            emitter.onError(error)
                        }
                        .disposed(by: self.bag)
                } onError: { error in
                    print("파이어베이스 회원가입 오류")
                    let err = error as NSError
                    switch err.code {
                    case AuthErrorCode.wrongPassword.rawValue:
                        print("wrong password")
                        emitter.onError(error)
                    case AuthErrorCode.invalidEmail.rawValue:
                        print("invalid email")
                        emitter.onError(error)
                    case AuthErrorCode.accountExistsWithDifferentCredential.rawValue:
                        print("accountExistsWithDifferentCredential")
                        emitter.onError(error)
                    case AuthErrorCode.emailAlreadyInUse.rawValue:
                        print("email is alreay in use")
                        self.firLogin(loginModel: loginModel)
                            .subscribe { _ in
                                print("파이어베이스 로그인 성공")
                                emitter.onNext(true)
                            } onError: { error in
                                print("파이어베이스 로그인 오류")
                                emitter.onError(error)
                            }
                            .disposed(by: self.bag)
                    default:
                        print("unknown error: \(err.localizedDescription)")
                        emitter.onError(error)
                    }
                }
                .disposed(by: self.bag)
            return Disposables.create{
                emitter.onCompleted()
            }
        }
    }
    
    
    func kakaoLogOut() -> Observable<Bool> {
        return Observable.create { emitter in
            UserApi.shared.logout {(error) in
                if let error = error {
                    emitter.onError(error)
                }
                self.firlogOut()
                    .subscribe { bool in
                        emitter.onNext(bool)
                    } onError: { error in
                        emitter.onError(error)
                    }
                    .disposed(by: self.bag)
            }
            return Disposables.create {
                emitter.onCompleted()
            }
        }
    }
    
    
    // Google
    func googleLogin(vc: UIViewController) -> Observable<Bool> {
        return Observable.create { emitter in
            
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                return Disposables.create {
                    print("구글 clientID 에러")
                    emitter.onNext(false)
                }
            }
            
            // Create Google Sign In configuration object.
            let config = GIDConfiguration(clientID: clientID)

            // Start the sign in flow!
            GIDSignIn.sharedInstance.signIn(with: config, presenting: vc) { [unowned self] user, error in

              if let error = error {
                print("구글 로그인 실패")
                emitter.onError(error)
                return
              }

              guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
              else {
                print("구글 유저 정보 로딩 실패")
                emitter.onNext(false)
                return
              }

              let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
                self.firLoginByCredential(credential: credential)
                    .subscribe { success in
                        emitter.onNext(success)
                    } onError: { error in
                        print("구글 로그인 (O), 파이어베이스 로그인 (X)")
                        emitter.onError(error)
                    }
                    .disposed(by: self.bag)
            }
            
            
            
            return Disposables.create {
                emitter.onCompleted()
            }
        }
    }
    
    
    // Facebook
    func facebookLogin(vc: UIViewController) -> Observable<Bool> {
        
        return Observable.create { emitter in
            
            let manager = LoginManager()
            
            // 토큰 유효, 페북 로그인 필요 X
            if let token = AccessToken.current, !token.isExpired {
                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                self.firLoginByCredential(credential: credential)
                    .subscribe { success in
                        emitter.onNext(success)
                    } onError: { error in
                        print("@@@")
                        print("페북 로그인 (O), 파이어베이스 로그인 (X)")
                        emitter.onError(error)
                    }
                    .disposed(by: self.bag)
            } else {
                // 토큰 X, 페북 로그인 필요
                manager.logIn(permissions: ["public_profile"], from: vc) { result, error in
                    if let error = error {
                        print("Process error: \(error)")
                        return
                    }
                    guard let result = result else {
                        print("No Result")
                        return
                    }
                    if result.isCancelled {
                        print("Login Cancelled")
                        return
                    }
                    let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                    self.firLoginByCredential(credential: credential)
                        .subscribe { success in
                            emitter.onNext(success)
                        } onError: { error in
                            print("페북 로그인 (O), 파이어베이스 로그인 (X)")
                            emitter.onError(error)
                        }
                        .disposed(by: self.bag)
                }
            }
            return Disposables.create {
                emitter.onCompleted()
            }
        }
        
    }
    
    
    
    
    
}
