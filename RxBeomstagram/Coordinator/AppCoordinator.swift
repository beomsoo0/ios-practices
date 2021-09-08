//
//  AppCoordinator.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/09/07.
//

import UIKit
import FirebaseAuth

class AppCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController!
    var isLoggedIn: Bool = false
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.isNavigationBarHidden = true
        isLoggedIn = Auth.auth().currentUser?.uid != nil ? true : false
    }
    
    func start() {
        if isLoggedIn == true {
            pushHomeVC()
        } else {
            let story = UIStoryboard(name: "Main", bundle: nil)
            let vc = story.instantiateViewController(identifier: "LoginVC") as! LoginViewController
            vc.coordinator = self
            self.navigationController.pushViewController(vc, animated: false)
        }
    }
    
    func pushHomeVC() {
        guard let uid = AuthManager.shared.currentUid() else { return }
        DatabaseManager.shared.fetchUser(uid: uid) { user in
            user.posts = user.posts.sorted(by: {$0.cuid > $1.cuid })
            User.currentUser = user
            User.currentUserRx.onNext(User.currentUser)
        }
        
        let home = HomeCoordinator()
        home.parentCoordinator = self
        childCoordinators.append(home)
        let homeVC = home.startPush()
        
        let search = SearchCoordinator()
        search.parentCoordinator = self
        childCoordinators.append(search)
        let searchVC = search.startPush()
        
        let newContent = NewContentCoordinator()
        newContent.parentCoordinator = self
        childCoordinators.append(newContent)
        let newContentVC = newContent.startPush()
        
        let four = ProfileCoordinator()
        four.parentCoordinator = self
        childCoordinators.append(four)
        let fourVC = four.startPush()
        
        let profile = ProfileCoordinator()
        profile.parentCoordinator = self
        childCoordinators.append(profile)
        let profileVC = profile.startPush()
        
        let story = UIStoryboard(name: "Main", bundle: nil)
        let tabbarVC = story.instantiateViewController(identifier: "TabbarVC") as! UITabBarController
        tabbarVC.viewControllers = [homeVC, searchVC, newContentVC, fourVC, profileVC]

        self.navigationController.pushViewController(tabbarVC, animated: false)
        
    }
}





