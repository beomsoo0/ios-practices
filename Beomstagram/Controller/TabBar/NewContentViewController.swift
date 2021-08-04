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
    
    var allPhotos: PHFetchResult<PHAsset>!
    let imageManager = PHImageManager()
    var images: [UIImage] = []
    var firstImage: UIImage?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC = segue.destination as! PushContentViewController
        nextVC.contentImage = firstImage
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.allPhotos = PHAsset.fetchAssets(with: nil)
        
        switch PHPhotoLibrary.authorizationStatus(){
        case .authorized:
            print("앨범 접근 가능")
            fetchAllPhotos()
            collectionView.reloadData()
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
        
        let assetCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let asset = allPhotos.object(at: indexPath.item)
        let imgSize = CGSize(width: view.bounds.width / 4 - 10, height: view.bounds.width / 4 - 10)
        
        assetCell.representedAssetIdentifier = asset.localIdentifier
        DispatchQueue.main.async {
            self.imageManager.requestImage(for: asset, targetSize: imgSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                                        if assetCell.representedAssetIdentifier == asset.localIdentifier {
                                            assetCell.imageView.image = image
                                            self.images.append(image!)
                                            if indexPath.item == 0 {
                                                self.firstImage = image
                                                self.mainImage.image = self.firstImage
                                            }
                                        }
                                      })
        }
        return assetCell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("!")
        self.firstImage = self.images[indexPath.item]
        self.mainImage.image = self.firstImage
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = view.bounds.width / 4 - 10
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }
    
}
    
class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var representedAssetIdentifier: String!
}
