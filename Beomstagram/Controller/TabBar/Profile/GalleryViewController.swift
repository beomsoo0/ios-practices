//
//  GalleryViewController.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/10.
//

import UIKit
import Photos
import PhotosUI

class GalleryViewController: UIViewController {

    var allPhotos: PHFetchResult<PHAsset>!
    let imageManager = PHImageManager()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainImage: UIImageView!
    var images: [UIImage] = []
    var mainImageVar: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    @IBAction func completeSeleted(_ sender: Any) {
        guard let editVC = self.storyboard?.instantiateViewController(identifier: "EditVC") as? EditProfileViewController else { return }
        editVC.receiveImage = mainImageVar
        print(editVC.receiveImage)
        //editVC.modalPresentationStyle = .fullScreen
        //present(editVC, animated: true, completion: nil)
        self.navigationController?.pushViewController(editVC, animated: true)
        //popViewController(animated: true)
    }
    
    private func fetchAllPhotos() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
    }
}

extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let assetCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as? GalleryCell else {
            return UICollectionViewCell()
        }
        let asset = allPhotos.object(at: indexPath.item)
        let itemSpacing: CGFloat = 1
        let imgSize = CGSize(width: (collectionView.bounds.width - itemSpacing) / 4,  height: (collectionView.bounds.width - itemSpacing) / 4)
        
        assetCell.representedAssetIdentifier = asset.localIdentifier
        
        DispatchQueue.main.async {
            self.imageManager.requestImage(for: asset, targetSize: imgSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
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
