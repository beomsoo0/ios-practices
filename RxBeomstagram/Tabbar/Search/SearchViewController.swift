//
//  SearchViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/18.
//

import UIKit

class SearchViewController: UIViewController {

    var searchViewModel = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        collectionView.reloadData()
        print("$$$$$$  Search  $$$$$")
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
}

