//
//  AppDelegate.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/20.
//

import UIKit
import Firebase
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Messaging
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        //
        
        KakaoSDKCommon.initSDK(appKey: "c7f4272bc12f691cc88f945c9a0b4e4d")
        
        FirebaseApp.configure()
        let coordinator = SceneCoordinator(window: window!)
        
        if Auth.auth().currentUser == nil {
            let loginVM = LoginViewModel(sceneCoordinator: coordinator)
            let loginScene = Scene.login(loginVM)
            coordinator.transition(to: loginScene, using: .root, animated: false)
        } else {
            let homeVM = HomeViewModel(sceneCoordinator: coordinator)
            let peopleVM = PeopleViewModel(sceneCoordinator: coordinator)
            let nearVM = NearViewModel(sceneCoordinator: coordinator)
            let chatVM = ChatViewModel(sceneCoordinator: coordinator)
            let profileVM = ProfileViewModel(sceneCoordinator: coordinator)
            
            // rootView 설정
            let loginVM = LoginViewModel(sceneCoordinator: coordinator)
            let loginScene = Scene.login(loginVM)
            let target = loginScene.instantiate()
            coordinator.currentVC = target.sceneViewController
            coordinator.window.rootViewController = target

            let tabbarScene = Scene.tabbar(homeVM, peopleVM, nearVM, chatVM, profileVM)
            coordinator.transition(to: tabbarScene, using: .push, animated: false)
        }

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }
        
        return false
    }



    
    
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

extension AppDelegate: UNUserNotificationCenterDelegate {
    // For Push Message - Foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.list, .banner, .badge, .sound])
        completionHandler([.alert, .badge, .sound])
    }
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      Messaging.messaging().apnsToken = deviceToken
    }
}


extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("FCM 토큰 갱신 \(token)")
    }
}
