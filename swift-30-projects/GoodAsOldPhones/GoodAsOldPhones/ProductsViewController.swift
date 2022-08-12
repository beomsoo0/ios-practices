//
//  ViewController.swift
//  GoodAsOldPhones
//
//  Created by 김범수 on 2021/08/18.
//

import UIKit

class ProductsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var products: [Product]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        products = [
          Product(name: "1907 Wall Set", cellImageName: "image-cell1", fullscreenImageName: "phone-fullscreen1"),
          Product(name: "1921 Dial Phone", cellImageName: "image-cell2", fullscreenImageName: "phone-fullscreen2"),
          Product(name: "1937 Desk Set", cellImageName: "image-cell3", fullscreenImageName: "phone-fullscreen3"),
          Product(name: "1984 Moto Portable", cellImageName: "image-cell4", fullscreenImageName: "phone-fullscreen4")
        ]
    }

}

extension ProductsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductsCell", for: indexPath) as? ProductsCell else { return UITableViewCell() }
        guard let products = products else { return cell }
        
        let product = products[indexPath.row]
        
        cell.productsLabel.text = product.name
        cell.productsImage.image = UIImage(named: product.cellImageName)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "FullVC") as? FullViewController else { return }
        nextVC.product = products?[indexPath.row]
        self.navigationController?.pushViewController(nextVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

class ProductsCell: UITableViewCell {
    @IBOutlet weak var productsImage: UIImageView!
    @IBOutlet weak var productsLabel: UILabel!
}
