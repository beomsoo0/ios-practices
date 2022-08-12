//
//  GalleryViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/24.
//

import UIKit

class GalleryViewController: UIViewController {

    // MARK - Variables
    let photoManager = PhotoManager.shared
    var passImage: UIImage?
    weak var EditProfileViewControllerDelegate: EditProfileViewController?
    
    // MARK - Variables
    override func viewDidLoad() {
        super.viewDidLoad()
        photoManager.fetchAllPhotos()
    }
    
    // MARK - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mainImage: UIImageView!
   
    @IBAction func completeSeleted(_ sender: Any) {
        self.navigationController?.navigationBar.isHidden = false
        EditProfileViewControllerDelegate?.changeImage = passImage
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cancelSeleted(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
