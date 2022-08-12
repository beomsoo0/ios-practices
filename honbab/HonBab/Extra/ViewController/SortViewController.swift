//
//  SortViewController.swift
//  HonBab
//
//  Created by 김범수 on 2021/10/07.
//

import UIKit
import RxSwift

class SortViewController: UIViewController, ViewModelBindType {
    @IBOutlet weak var sortSeg: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var completeBtn: UIBarButtonItem!
    @IBOutlet weak var backBtn: UIBarButtonItem!
    
    let bag = DisposeBag()
    var viewModel: SortViewModel!
    
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
        sortSeg.rx.value
            .map { SortingType(rawValue: $0) ?? .postDate }
            .bind(to: viewModel.sorting)
            .disposed(by: bag)
        
        viewModel.foodCategorySubject
            .bind(to: collectionView.rx.items(cellIdentifier: "SortCollectionViewCell", cellType: SortCollectionViewCell.self)) { [unowned self] (idx, food, cell) in
                cell.categoryImgView.image = food.image
                cell.categoryImgView.layer.cornerRadius = cell.categoryImgView.bounds.width * 0.5
                cell.categoryLabel.text = food.name
                cell.categoryLabel.sizeToFit()
                
                let itemSpacing: CGFloat = 1
                let width: CGFloat = (collectionView.bounds.width - itemSpacing) / 3
                let height: CGFloat = width
                cell.bounds.size = CGSize(width: width, height: height)
            }
            .disposed(by: bag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] idx in
                guard let cell = self.collectionView.cellForItem(at: idx) as? SortCollectionViewCell else { return }
                cell.categoryImgView.layer.borderWidth = 2
                cell.categoryImgView.layer.borderColor = UIColor.orange.cgColor
                self.viewModel.indexing.onNext(idx.item)
            })
            .disposed(by: bag)

        collectionView.rx.itemDeselected
            .subscribe(onNext: { [unowned self] idx in
                guard let cell = self.collectionView.cellForItem(at: idx) as? SortCollectionViewCell else { return }
                cell.categoryImgView.layer.borderWidth = 0
            })
            .disposed(by: bag)
        
        completeBtn.rx.tap
            .bind(to: viewModel.complete)
            .disposed(by: bag)
        
        backBtn.rx.action = viewModel.backAction
    }
    
    deinit {
        print("@@@@@@ SortViewController Deinit @@@@@@")
    }
    
}

class SortCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var categoryImgView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
}
