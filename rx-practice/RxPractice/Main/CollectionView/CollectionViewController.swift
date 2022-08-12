//
//  CollectionViewController.swift
//  RxPractice
//
//  Created by 김범수 on 2021/09/08.
//

import UIKit
import RxSwift
import RxCocoa

class CollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let disposeBag = DisposeBag()
    let colorObservable = BehaviorSubject<[UIColor]>(value: MaterialBlue.allColors)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        
        colorObservable.bind(to: collectionView.rx.items(cellIdentifier: "colorCell", cellType: ColorCell.self)) { index, item, cell in
            cell.colorLabel.text = item.rgbHexString
            cell.backgroundColor = item
        }
        .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(UIColor.self)
            .subscribe(onNext: {
                print($0.rgbHexString)
            })
            .disposed(by: disposeBag)
        
    }

}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSpacing: CGFloat = 10
        let width: CGFloat = (collectionView.bounds.width - itemSpacing) / 2
        let height: CGFloat = width
        return CGSize(width: width, height: height)
    }
}

class ColorCell: UICollectionViewCell {
    @IBOutlet weak var colorLabel: UILabel!
}
