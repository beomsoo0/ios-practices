//
//  TableViewController.swift
//  RxPractice
//
//  Created by κΉλ²μ on 2021/09/08.
//

import UIKit
import RxSwift
import RxCocoa

class TableViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    let productObservable = Observable.of(appleProducts)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        productObservable.bind(to: tableView.rx.items(cellIdentifier: "productCell", cellType: ProductCell.self)) { index, item, cell in
            cell.categoryLabel.text = item.category
            cell.nameLabel.text = item.name
            cell.summaryLabel.text = item.summary
            cell.priceLabel.text = "\(item.price)μ"
        }
        .disposed(by: disposeBag)

//        tableView.rx.modelSelected(Product.self)
//            .subscribe(onNext: {
//                print($0.name)
//            })
//            .disposed(by: disposeBag)
//        
//        tableView.rx.itemSelected
//            .subscribe(onNext: {
//                self.tableView.deselectRow(at: $0, animated: true)
//            })
//            .disposed(by: disposeBag)
        
        Observable.zip(tableView.rx.modelSelected(Product.self),  tableView.rx.itemSelected)
            .bind { product, index in
                print(product.name)
                self.tableView.deselectRow(at: index, animated: true)
            }
            .disposed(by: disposeBag)
        
    }

}

class ProductCell: UITableViewCell {
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
}
