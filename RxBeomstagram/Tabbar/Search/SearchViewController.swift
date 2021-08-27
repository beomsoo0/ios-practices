//
//  SearchViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/18.
//

import UIKit

class SearchViewController: UIViewController {

    var allPosts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DatabaseManager.shared.fetchAllPosts { [weak self] posts in
            self?.allPosts = posts
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
}

