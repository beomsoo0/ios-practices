//
//  ProfileImgSetViewController.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/20.
//

import UIKit
import RxSwift
import Photos

// Delegate 패턴
class ImgSetViewController: UIViewController, ViewModelBindType {
    
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let photoManager = PhotoManager()
    let bag = DisposeBag()
    var viewModel: RegisterViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
  
    func bindViewModel() {
        viewModel.imgSubject
            .bind(to: mainImg.rx.image)
            .disposed(by: bag)   
    }
    
    deinit {
        print("@@@@@@@ ImgSetViewController VC Deinit @@@@@@@@@@")
    }

}


extension ImgSetViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoManager.allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let imageSetCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImgSetCollectionViewCell", for: indexPath) as? ImgSetCollectionViewCell else {
            return UICollectionViewCell()
        }
        let asset = photoManager.allPhotos.object(at: indexPath.item)
        let itemSpacing: CGFloat = 1
        let imgSize = CGSize(width: (collectionView.bounds.width - itemSpacing) / 4,  height: (collectionView.bounds.width - itemSpacing) / 4)
        
        self.photoManager.imageManager.requestImage(for: asset, targetSize: imgSize, contentMode: .aspectFill, options: nil, resultHandler: { [unowned self] image, _ in
            if let image = image {
                imageSetCell.imgView.image = image
                if indexPath.item == 0 {
                    self.viewModel.imgSubject.onNext(image)
                }
            }
        })
        return imageSetCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpacing: CGFloat = 2
        let width: CGFloat = (collectionView.bounds.width - itemSpacing) / 4
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let imageSetCell = collectionView.cellForItem(at: indexPath) as? ImgSetCollectionViewCell else { return }
        if let selectedImg = imageSetCell.imgView.image {
            imageSetCell.imgView.layer.borderWidth = 1.5
            imageSetCell.imgView.layer.borderColor = UIColor.orange.cgColor
            viewModel.imgSubject.onNext(selectedImg)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let imageSetCell = collectionView.cellForItem(at: indexPath) as? ImgSetCollectionViewCell else { return }
        if let selectedImg = imageSetCell.imgView.image {
            imageSetCell.imgView.layer.borderWidth = 0
            imageSetCell.imgView.layer.borderColor = UIColor.systemBackground.cgColor
        }
    }
}

class ImgSetCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
}
