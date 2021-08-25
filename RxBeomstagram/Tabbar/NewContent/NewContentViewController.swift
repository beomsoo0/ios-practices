//
//  NewContentViewController.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/08/17.
//

import UIKit

class NewContentViewController: UIViewController {

    // MARK - Variables
    let photoManager = PhotoManager.shared
    var passingImage: UIImage?
    
    // MARK - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        photoManager.fetchAllPhotos()
        collectionView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK - Outlets
    @IBOutlet weak var mainPhoto: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func cancelSelected(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func nextSelected(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "UploadVC") as? UploadViewController else { return }
        nextVC.modalPresentationStyle = .fullScreen
        nextVC.recieveImage = passingImage
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}


