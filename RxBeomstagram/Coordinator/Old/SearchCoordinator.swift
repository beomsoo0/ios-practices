//
//  SearchCoordinator.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/09/07.
//

import UIKit

class SearchCoordinator: Coordinator {
    
    var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    private var navigationController: UINavigationController!
    
    init() {
        self.navigationController = .init()
    }
    
    func start() {
        
    }
    
    func startPush() -> UINavigationController {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let firstVC = story.instantiateViewController(identifier: "SearchVC") as! SearchViewController
        firstVC.navigationController?.isNavigationBarHidden = true
        navigationController.setViewControllers([firstVC], animated: false)
        return navigationController
    }
}
