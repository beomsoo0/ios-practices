//
//  ProfileCollectionViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/23.
//

import UIKit

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return user.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCollectionViewCell", for: indexPath) as? PostCollectionViewCell else { return UICollectionViewCell() }
        let post = user.posts[indexPath.item]
        
        cell.postImage.image = post.image
        cell.post = post
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpacing: CGFloat = 1
        let width: CGFloat = (collectionView.bounds.width - itemSpacing) / 3
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "ContentVC") as? ContentViewController else { return }
        nextVC.allPosts = user.posts
        nextVC.indexPath = indexPath
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}

class PostCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var postImage: UIImageView!
    var post: Post?
    
}
