//
//  SearchViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit
import Firebase

class SearchViewController: UIViewController {

    let allContentsModel = AllContentsModel.shared
    
    @IBOutlet weak var searchCollectionView: UICollectionView!
    
    @IBAction func reload(_ sender: Any) {
        searchCollectionView.reloadData()
        print("검색바 총 이미지 수 :", allContentsModel.contents.count)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        DatabaseManager.shared.loadAllContents()
    }
    
     
    
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allContentsModel.contents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCell", for: indexPath) as! SearchCell
        cell.searchImage.image = allContentsModel.contents[indexPath.item].image
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
    
   // var content: ContentModel
}
