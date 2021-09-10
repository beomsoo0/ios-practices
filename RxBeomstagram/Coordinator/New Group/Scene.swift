//
//  Scene.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/09/10.
//

import RxSwift
import RxCocoa

enum Scene {
    case login(LoginViewModel)
    case tabbar(HomeViewModel, SearchViewModel, ProfileViewModel)
}

extension Scene {
    func instantiate() -> UIViewController {
        let mainStory = UIStoryboard(name: "Main", bundle: nil)
        
        switch self {
        case .login(let loginVM):
            guard let navVC = mainStory.instantiateViewController(identifier: "loginNavVC") as? UINavigationController else { fatalError() }
            guard var loginVC = navVC.viewControllers.first as? LoginViewController else { fatalError() }
            loginVC.bind(viewModel: loginVM)
            return loginVC
            
        case .tabbar(let homeVM, let searchVM, let profileVM):
            
            guard let homeNavVC = mainStory.instantiateViewController(identifier: "homeNavVC") as? UINavigationController,
                  var homeVC = homeNavVC.viewControllers.first as? HomeViewController
                  else { fatalError() }
            guard let searchNavVC = mainStory.instantiateViewController(identifier: "searchNavVC") as? UINavigationController,
                  var searchVC = searchNavVC.viewControllers.first as? SearchViewController
                  else { fatalError() }
            guard let newContentNavVC = mainStory.instantiateViewController(identifier: "newContentNavVC") as? UINavigationController,
                  var newContentVC = newContentNavVC.viewControllers.first as? NewContentViewController
                  else { fatalError() }
            guard let fourNavVC = mainStory.instantiateViewController(identifier: "fourNavVC") as? UINavigationController,
                  var fourVC = fourNavVC.viewControllers.first as? FourViewController
                  else { fatalError() }
            guard let profileNavVC = mainStory.instantiateViewController(identifier: "profileNavVC") as? UINavigationController,
                  var profileVC = profileNavVC.viewControllers.first as? ProfileViewController
                  else { fatalError() }
            
            //[x] viewModel Binding
            homeVC.bind(viewModel: homeVM)
            searchVC.bind(viewModel: searchVM)
            profileVC.bind(viewModel: profileVM)

            
            guard let tabbarVC = mainStory.instantiateViewController(identifier: "tabbarVC") as? UITabBarController else { fatalError() }
            tabbarVC.viewControllers = [homeNavVC, searchNavVC, newContentNavVC, fourNavVC, profileNavVC]
            return tabbarVC
        }
    }
    
    
}
