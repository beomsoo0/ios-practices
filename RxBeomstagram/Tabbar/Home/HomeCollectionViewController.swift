//
//  HomeCollectionViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/27.
//

import UIKit

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return otherUsers.count + 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as? HomeCollectionViewCell else { return UICollectionViewCell() }
//        guard let user = indexPath.item == 0 ? User.currentUser : otherUsers[indexPath.item - 1] else { return UICollectionViewCell() }
//
//        cell.storyImageView.image = user.profileImage
//        cell.storyImageView.layer.cornerRadius = cell.storyImageView.bounds.width * 0.5
//        cell.storyIDLabel.text = user.id
//
//        return cell
//    }
    
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
