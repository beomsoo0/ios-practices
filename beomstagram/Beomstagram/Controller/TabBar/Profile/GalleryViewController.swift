//
//  GalleryViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/10.
//

import UIKit

class GalleryViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainImage: UIImageView!
    
    weak var EditProfileViewControllerDelegate: EditProfileViewController?
    let photoManager = PhotoManager.shared
    
    var images: [UIImage] = []
    var mainImageVar: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoManager.fetchAllPhotos()
    }
    
    @IBAction func completeSeleted(_ sender: Any) {
        EditProfileViewControllerDelegate?.changeImage = mainImageVar
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelSeleted(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

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
                    self.images.append(image!)
                    if indexPath.item == 0 {
                        self.mainImageVar = image
                        self.mainImage.image = image
                    }
                }
            })
        }
        return assetCell
    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.mainImageVar = self.images[indexPath.item]
        self.mainImage.image = self.mainImageVar
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpacing: CGFloat = 1
        let width: CGFloat = (collectionView.bounds.width - itemSpacing) / 4
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }
    
}

class GalleryCell: UICollectionViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    var representedAssetIdentifier: String!
}
