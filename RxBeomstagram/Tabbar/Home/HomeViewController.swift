//
//  HomeViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/18.
//

import UIKit

class HomeViewController: UIViewController {

    var homeViewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    @IBOutlet weak var tableView: UITableView!
    @IBAction func onAddContent(_ sender: Any) {
        self.tabBarController?.selectedIndex = 2
    }
}



