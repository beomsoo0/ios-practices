//
//  FullViewController.swift
//  GoodAsOldPhones
//
//  Created by 김범수 on 2021/08/18.
//

import UIKit

class FullViewController: UIViewController {

    var product: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = product?.name
        if let imageName = product?.fullscreenImageName {
            fullImage.image = UIImage(named: imageName)
        }

    }

    @IBOutlet weak var fullImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBAction func onAddToCart(_ sender: UIButton) {
        print("HaHaHa")
    }
    
}
