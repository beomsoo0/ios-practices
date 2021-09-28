//
//  AppDelegate.swift
//  SNS_Login
//
//  Created by 김범수 on 2021/09/26.
//

import UIKit
import Firebase
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import GoogleSignIn
import FBSDKCoreKit
//import NaverThirdPartyLogin

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        KakaoSDKCommon.initSDK(appKey: "27b0d91a2235bfbc4fdd365b9a6644e7")

        // Facebook
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        FBSDKCoreKit.Settings.appID = "255360429822786"
        
//        // 네이버 간편로그인 init
//            let instance = NaverThirdPartyLoginConnection.getSharedInstance()
//        // if) 앱설치 -> 앱로그인 else) -> 사파리
//            instance.isNaverAppOauthEnable = true
//            instance.isInAppOauthEnable = true
//
//            instance?.serviceUrlScheme = kServiceAppUrlScheme // 앱을 등록할 때 입력한 URL Scheme
//            instance?.consumerKey = kConsumerKey // 상수 - client id
//            instance?.consumerSecret = kConsumerSecret // pw
//            instance?.appName = kServiceAppName // app name
//        
//        // 네이버 로그인 화면이 새로 등장 -> 토큰을 요청하는 코드
//        NaverThirdPartyLoginConnection
//            .getSharedInstance()?
//            .receiveAccessToken(URLContexts.first?.url)
        
        
        return true
    }

//    // Kakao Login URL
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        if (AuthApi.isKakaoTalkLoginUrl(url)) {
//            return AuthController.handleOpenUrl(url: url)
//        }
//        return false
//    }
    
    // Google Login URL
//    @available(iOS 9.0, *)
//    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
//      return GIDSignIn.sharedInstance.handle(url)
//    }
    
    // Facebook Login URL
    func application(_ app: UIApplication,  open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
//    // Naver Login URL
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        NaverThirdPartyLoginConnection.getSharedInstance()?.application(app, open: url, options: options)
//            return true
//      }
    
    
    
    // MARK: UISceneSession Lifecycle

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }


}

