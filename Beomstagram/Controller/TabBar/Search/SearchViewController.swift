//
//  SearchViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit
import Firebase

class SearchViewController: UIViewController {

    var allContents: [ContentModel] = []
    
    @IBOutlet weak var searchCollectionView: UICollectionView!
    

    var allContentsModel = [AllContentModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Search viewDidLoad")
            }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Search viewWillAppear")
        DatabaseManager.shared.fetchAllContents { [weak self] allContentsModel in
            self?.allContentsModel = allContentsModel
            DispatchQueue.main.async {
                self?.searchCollectionView.reloadData()
            }
        }
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allContentsModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as? SearchCell else {
            return UICollectionViewCell()
        }
        cell.searchImage.image = allContentsModel[indexPath.item].content.image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpacing: CGFloat = 1
        let width: CGFloat = (collectionView.bounds.width - itemSpacing) / 3
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }
    
}

class SearchCell: UICollectionViewCell {
    
    @IBOutlet weak var searchImage: UIImageView!
}
