//
//  Scene.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/20.
//

import UIKit

enum Scene {
    case login(LoginViewModel)
    case register(RegisterViewModel)
    case tabbar(HomeViewModel, PeopleViewModel, NearViewModel, ChatViewModel, ProfileViewModel)
    case addPost(AddPostViewModel)
    case addImg(AddImgViewModel)
    case chatRoom(ChatRoomViewModel)
    case post(PostViewModel)
    case sort(SortViewModel)
    case category(CategoryViewModel)
    case setting(SettingViewModel)
}

extension Scene {
    
    func instantiate() -> UIViewController {
            
        let loginStory = UIStoryboard(name: "Login", bundle: nil)
        let tabbarStory = UIStoryboard(name: "Tabbar", bundle: nil)
        let extraStory = UIStoryboard(name: "Extra", bundle: nil)
        
        switch self {
        
        case .login(let loginVM):
            guard let loginNavVC = loginStory.instantiateViewController(identifier: "loginNavVC") as? UINavigationController,
                  var loginVC = loginNavVC.viewControllers.first as? LoginViewController else {
                fatalError()
                break
            }
            loginVC.bind(viewModel: loginVM)
            return loginNavVC
        case .register(let registerVM):
            guard let registerNavVC = loginStory.instantiateViewController(identifier: "registerNavVC") as? UINavigationController,
                  var registerVC = registerNavVC.viewControllers.first as? RegisterViewController else {
                fatalError()
                break
            }
            
            guard var idSetVC = loginStory.instantiateViewController(identifier: "idSetVC")
                      as? IdSetViewController,
                  var nameSetVC = loginStory.instantiateViewController(identifier: "nameSetVC") as? NameSetViewController,
                  var imgSetVC = loginStory.instantiateViewController(identifier: "imgSetVC") as? ImgSetViewController else {
                fatalError()
                break
            }
            registerVC.bind(viewModel: registerVM)
            idSetVC.bind(viewModel: registerVM)
            nameSetVC.bind(viewModel: registerVM)
            imgSetVC.bind(viewModel: registerVM)
            
            registerVC.addChild(idSetVC)
            registerVC.addChild(nameSetVC)
            registerVC.addChild(imgSetVC)

//            registerVC.containerView.addSubview(idSetVC.view)  // VC에서 처리중
//            idSetVC.didMove(toParent: registerVC)
        
            return registerVC
            

        case .tabbar(let homeVM, let peopleVM, let nearVM, let chatVM, let profileVM):
            guard let homeNavVC = tabbarStory.instantiateViewController(identifier: "homeNavVC") as?            UINavigationController,
                  var homeVC = homeNavVC.viewControllers.first as? HomeViewController,
                  let nearNavVC = tabbarStory.instantiateViewController(identifier: "nearNavVC") as? UINavigationController,
                  let peopleNavVC = tabbarStory.instantiateViewController(identifier: "peopleNavVC") as? UINavigationController,
                  var peopleVC = peopleNavVC.viewControllers.first as? PeopleViewController,
                  var nearVC = nearNavVC.viewControllers.first as? NearViewController,
                  let chatNavVC = tabbarStory.instantiateViewController(identifier: "chatNavVC") as? UINavigationController,
                  var chatVC = chatNavVC.viewControllers.first as? ChatViewController,
                  let profileNavVC = tabbarStory.instantiateViewController(identifier: "profileNavVC") as? UINavigationController,
                  var profileVC = profileNavVC.viewControllers.first as? ProfileViewController
            else {
                fatalError()
                break
            }

            homeNavVC.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
            peopleNavVC.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
            nearNavVC.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "map"), selectedImage: UIImage(systemName: "map.fill"))
            chatNavVC.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "message"), selectedImage: UIImage(systemName: "message.fill"))
            profileNavVC.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "gear"), selectedImage: UIImage(systemName: "gear.fill"))
            
            homeVC.bind(viewModel: homeVM)
            peopleVC.bind(viewModel: peopleVM)
            nearVC.bind(viewModel: nearVM)
            chatVC.bind(viewModel: chatVM)
            profileVC.bind(viewModel: profileVM)

            guard let tabbarNavVC = tabbarStory.instantiateViewController(identifier: "tabbarNavVC") as? UINavigationController,
                  let tabbarVC = tabbarNavVC.viewControllers.first as? UITabBarController else {
                fatalError()
                break
            }
            tabbarVC.viewControllers = [homeNavVC, peopleNavVC, nearNavVC, chatNavVC, profileNavVC]
            
            return tabbarVC

        // Extra
        case .addPost(let addPostVM):
            guard let addPostNavVC = extraStory.instantiateViewController(identifier: "addPostNavVC") as? UINavigationController,
                  var addPostVC = addPostNavVC.viewControllers.first as? AddPostViewController else {
                fatalError()
                break
            }
            addPostVC.bind(viewModel: addPostVM)
            return addPostVC
        case .addImg(let addImgVM):
            guard let addImgNavVC = extraStory.instantiateViewController(identifier: "addImgNavVC") as? UINavigationController,
                  var addImgVC = addImgNavVC.viewControllers.first as? AddImgViewController else {
                fatalError()
                break
            }
            addImgVC.bind(viewModel: addImgVM)
            return addImgNavVC
            
        case .chatRoom(let chatRoomVM):
            guard let chatRoomNavVC = extraStory.instantiateViewController(identifier: "chatRoomNavVC") as? UINavigationController,
                  var chatRoomVC = chatRoomNavVC.viewControllers.first as? ChatRoomViewController else {
                fatalError()
                break
            }
            chatRoomVC.bind(viewModel: chatRoomVM)
            return chatRoomVC
        
        
        case .post(let postVM):
            guard let postNavVC = extraStory.instantiateViewController(identifier: "postNavVC") as? UINavigationController,
                  var postVC = postNavVC.viewControllers.first as? PostViewController else {
                fatalError()
                break
            }
            postVC.bind(viewModel: postVM)
            return postVC
        
        case .sort(let sortVM):
            guard let sortNavVC = extraStory.instantiateViewController(identifier: "sortNavVC") as? UINavigationController,
                  var sortVC = sortNavVC.viewControllers.first as? SortViewController else {
                fatalError()
                break
                  }
            sortVC.bind(viewModel: sortVM)
            return sortVC
            
        case .category(let categoryVM):
            guard let categoryNavVC = extraStory.instantiateViewController(identifier: "categoryNavVC") as? UINavigationController,
                  var categoryVC = categoryNavVC.viewControllers.first as? CategoryViewController else {
                fatalError()
                break
                  }
            categoryVC.bind(viewModel: categoryVM)
            return categoryVC
            
        case .setting(let settingVM):
            guard let settingNavVC = extraStory.instantiateViewController(identifier: "settingNavVC") as? UINavigationController,
                  var settingVC = settingNavVC.viewControllers.first as? SettingViewController else {
                      fatalError()
                      break
                  }
            settingVC.bind(viewModel: settingVM)
            return settingVC
        }
    
    }
}

