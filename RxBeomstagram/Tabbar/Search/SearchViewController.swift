//
//  SearchViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/18.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {

    var allPosts = [Post]()
    
    
    let viewModel = SearchViewModel()
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = nil
        viewModel.postsObservable
            .observe(on: MainScheduler.instance)
            .bind(to: collectionView.rx.items(cellIdentifier: "SearchCollectionViewCell", cellType: SearchCollectionViewCell.self)) { index, item, cell in
                cell.postImage.image = item.image
            }.disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
}

