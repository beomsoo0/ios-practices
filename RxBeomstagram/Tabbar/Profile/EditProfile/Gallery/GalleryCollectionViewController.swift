//
//  GalleryCollectionViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/24.
//

import UIKit

extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoManager.allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let assetCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as? GalleryCell else {
            return UICollectionViewCell()
        }
        let asset = photoManager.allPhotos.object(at: indexPath.item)
        let itemSpacing: CGFloat = 1
        let imgSize = CGSize(width: (collectionView.bounds.width - itemSpacing) / 4,  height: (collectionView.bounds.width - itemSpacing) / 4)
        
        assetCell.representedAssetIdentifier = asset.localIdentifier
        
        DispatchQueue.main.async {
            self.photoManager.imageManager.requestImage(for: asset, targetSize: imgSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                if assetCell.representedAssetIdentifier == asset.localIdentifier {
                    assetCell.photo.image = image
                    if indexPath.item == 0 {
                        self.passImage = image
                        self.mainImage.image = image
                    }
                }
            })
        }
        return assetCell
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? GalleryCell else { return }
        self.passImage = cell.photo.image
        self.mainImage.image = cell.photo.image
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpacing: CGFloat = 1
        let width: CGFloat = (collectionView.bounds.width - itemSpacing) / 4
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }
    
}
