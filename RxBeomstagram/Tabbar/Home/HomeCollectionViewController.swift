//
//  HomeCollectionViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/27.
//

import UIKit

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let verticalSpacing: CGFloat = 5
        let height: CGFloat = collectionView.bounds.height - verticalSpacing
        let width: CGFloat = height * 0.85
        return CGSize(width: width, height: height)
    }
    
}

class HomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var storyImageView: UIImageView!
    @IBOutlet weak var storyIDLabel: UILabel!
    
}
