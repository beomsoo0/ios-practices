//
//  SearchCollectionViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/24.
//

import UIKit

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpacing: CGFloat = 1
        let width: CGFloat = (collectionView.bounds.width - itemSpacing) / 3
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "ContentVC") as? ContentViewController else { return }
        
        var posts: [Post] = []
        do {
            posts = try viewModel.postsObservable.value()
        } catch { }
        
        let contentViewModel = ContentViewModel(posts)
        nextVC.viewModel = contentViewModel
//        nextVC.allPosts = allPosts
        nextVC.indexPath = indexPath
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}

class SearchCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var postImage: UIImageView!
    
}
