//
//  AddContentViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit


class NewContentViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainImage: UIImageView!

    @IBAction func cancelSeleted(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
    
    let photoManager = PhotoManager.shared
    
    var images: [UIImage] = []
    var mainImageVar: UIImage?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! PushContentViewController
        nextVC.contentImage = mainImageVar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoManager.uploadPhotoLibrary()
    }
}

extension NewContentViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoManager.allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let assetCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let asset = photoManager.allPhotos.object(at: indexPath.item)
        let itemSpacing: CGFloat = 1
        let imgSize = CGSize(width: (collectionView.bounds.width - itemSpacing) / 4,  height: (collectionView.bounds.width - itemSpacing) / 4)
        
        assetCell.representedAssetIdentifier = asset.localIdentifier
        
        DispatchQueue.main.async {
            self.photoManager.imageManager.requestImage(for: asset, targetSize: imgSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                if assetCell.representedAssetIdentifier == asset.localIdentifier {
                    assetCell.imageView.image = image
                    self.images.append(image!)
                    if indexPath.item == 0 {
                        self.mainImageVar = image
                        self.mainImage.image = self.mainImageVar
                    }
                }
            })
        }
        return assetCell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.mainImageVar = self.images[indexPath.item]
        print(indexPath.item)
        self.mainImage.image = self.mainImageVar
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpacing: CGFloat = 1
        let width: CGFloat = (collectionView.bounds.width - itemSpacing) / 4
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }
    
}
    
class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var representedAssetIdentifier: String!
}
