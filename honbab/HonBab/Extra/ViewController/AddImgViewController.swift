//
//  AddImgViewController.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/25.
//

import UIKit
import RxSwift
import Action

class AddImgViewController: UIViewController, ViewModelBindType {

    @IBOutlet weak var completeBtn: UIBarButtonItem!
    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let photoManager = PhotoManager()
    let bag = DisposeBag()
    var viewModel: AddImgViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
  
    func bindViewModel() {
        let itemSpacing: CGFloat = 1
        let width = (collectionView.bounds.width - itemSpacing) / 4
        let height = (collectionView.bounds.height - itemSpacing) / 4
        let imgSize = CGSize(width: width,  height: height)
        
        rx.viewWillAppear
            .map { [unowned self] _ in imgSize }
            .bind(to: viewModel.fetching)
            .disposed(by: bag)
        
        viewModel.photosSubject
            .bind(to: collectionView.rx.items(cellIdentifier: "AddImgCollectionViewCell", cellType: AddImgCollectionViewCell.self)) { [unowned self] (idx, photo, cell) in
                if idx == 0 { self.mainImg.image = photo }
                cell.imgView.image = photo
                cell.bounds.size = imgSize
            }
            .disposed(by: bag)
        
        collectionView.rx.itemSelected
            .withLatestFrom(Observable.combineLatest(collectionView.rx.itemSelected, viewModel.photosSubject))
            .subscribe(onNext: { [unowned self] (indexPath, photos) in
                self.mainImg.image = photos[indexPath.item]
            })
            .disposed(by: bag)
        
        completeBtn.rx.tap
            .map { [unowned self] _ in self.mainImg.image! }
            .bind(to: viewModel.complete)
            .disposed(by: bag)
        
        backBtn.rx.action = viewModel.backAction
    }

}

class AddImgCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgView: UIImageView!
}
