//
//  AddContentViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/02.
//

import UIKit
import Photos
import PhotosUI

class NewContentViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainImage: UIImageView!

    @IBAction func cancelSeleted(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
    
    var allPhotos: PHFetchResult<PHAsset>!
    let imageManager = PHImageManager()
    
    var images: [UIImage] = []
    var mainImageVar: UIImage?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! PushContentViewController
        nextVC.contentImage = mainImageVar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("NewContent ViewDidLoad")
        self.allPhotos = PHAsset.fetchAssets(with: nil)
        
        switch PHPhotoLibrary.authorizationStatus(){
        case .authorized:
            print("앨범 접근 가능")
            fetchAllPhotos()
        case .notDetermined:
            print("권한 요청이 필요합니다.")
        case .denied:
            print("앨범 접근 허가가 필요합니다. 사용자에게 권한 요청 해야함.")
        case .restricted:
            print("앨범 접근 불가능")
        default:
            return
        }
    }
    private func fetchAllPhotos() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
    }
}

extension NewContentViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let assetCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }
        let asset = allPhotos.object(at: indexPath.item)
        let itemSpacing: CGFloat = 1
        let imgSize = CGSize(width: (collectionView.bounds.width - itemSpacing) / 4,  height: (collectionView.bounds.width - itemSpacing) / 4)
        
        assetCell.representedAssetIdentifier = asset.localIdentifier
        
        DispatchQueue.main.async {
            self.imageManager.requestImage(for: asset, targetSize: imgSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
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
    
    override func prepareForReuse() {
        super.prepareForReuse()

        self.representedAssetIdentifier = .none
        self.imageView.image = .none
    }

}
