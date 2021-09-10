//
//  HomeCoordinator.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/09/07.
//

import UIKit

class HomeCoordinator: Coordinator {
    
    var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    private var navigationController: UINavigationController!
    
    init() {
        self.navigationController = .init()
    }
    
    func start() {
        DispatchQueue.main.async {
            let story = UIStoryboard(name: "Main", bundle: nil)
            
            let homeVC = story.instantiateViewController(identifier: "HomeVC") as! HomeViewController
            homeVC.coordinator = self
            self.navigationController.isNavigationBarHidden = true
            
            let vc = story.instantiateViewController(identifier: "TabbarVC") as! UITabBarController
            self.navigationController.pushViewController(vc, animated: false)
        }
    }
    
    func startPush() -> UINavigationController {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let firstVC = story.instantiateViewController(identifier: "HomeVC") as! HomeViewController
        firstVC.coordinator = self
        firstVC.navigationController?.isNavigationBarHidden = true
        navigationController.setViewControllers([firstVC], animated: false)
        return navigationController
    }
    
    func pushFriendVC(model: FriendViewModel) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        guard let nextVC = story.instantiateViewController(identifier: "FriendVC") as? FriendViewController else { return }
        nextVC.viewModel = model
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
//    func tabbarIndex(index: Int) {
//        let story = UIStoryboard(name: "Main", bundle: nil)
//        
//        let homeVC = story.instantiateViewController(identifier: "HomeVC") as! HomeViewController
//        homeVC.tabBarController?.selectedIndex = index
//
//        let tabbarVC = story.instantiateViewController(identifier: "TabbarVC") as! UITabBarController
//        tabbarVC.selectedIndex = index
//    }
    
}
