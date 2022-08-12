//
//  TabbarViewController.swift
//  HonBab
//
//  Created by 김범수 on 2021/10/12.
//

import UIKit

class TabbarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 9.0, *) {
            self.tabBar.selectedImageTintColor = UIColor.label
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

}
