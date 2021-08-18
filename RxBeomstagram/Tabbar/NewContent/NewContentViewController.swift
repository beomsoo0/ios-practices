//
//  NewContentViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/17.
//

import UIKit

class NewContentViewController: UIViewController {

    let photoManager = PhotoManager.shared
    var passingImage: UIImage?
    var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoManager.fetchAllPhotos()
        collectionView.reloadData()
    }

    @IBAction func cancelSelected(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func nextSelected(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "UploadVC") as? UploadViewController else { return }
        nextVC.modalPresentationStyle = .fullScreen
        nextVC.recieveImage = passingImage
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBOutlet weak var mainPhoto: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
}

extension NewContentViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoManager.allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell else {
            return UICollectionViewCell()
        }
        let asset = photoManager.allPhotos.object(at: indexPath.item)
        let itemSpacing: CGFloat = 1
        let imgSize = CGSize(width: (collectionView.bounds.width - itemSpacing) / 4,  height: (collectionView.bounds.width - itemSpacing) / 4)
        DispatchQueue.main.async {
            self.photoManager.imageManager.requestImage(for: asset, targetSize: imgSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                imageCell.photo.image = image
                self.images.append(image!)
                if indexPath.item == 0 {
                    self.mainPhoto.image = image
                    self.passingImage = image
                }
            })
        }
        return imageCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpacing: CGFloat = 1
        let width: CGFloat = (collectionView.bounds.width - itemSpacing) / 4
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        mainPhoto.image = images[indexPath.item]
        passingImage = images[indexPath.item]
    }
}

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var photo: UIImageView!
}
