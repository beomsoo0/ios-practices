//
//  PhotoManager.swift
//  Beomstagram
//
//  Created by 김범수 on 2021/08/11.
//

import Photos
import PhotosUI

class PhotoManager {
    
    static let shared = PhotoManager()
    
    var allPhotos: PHFetchResult<PHAsset>!
    let imageManager = PHImageManager()
    
    func fetchAllPhotos() {
        self.allPhotos = PHAsset.fetchAssets(with: nil)
        
        switch PHPhotoLibrary.authorizationStatus(){
        case .authorized:
            print("앨범 접근 가능")
            fetch()
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
    
    private func fetch() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
    }
}
