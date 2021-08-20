//
//  DetailViewController.swift
//  CandySearch
//
//  Created by 김범수 on 2021/08/20.
//

import UIKit

class DetailViewController: UIViewController {

    var candy: Candy?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = UIImage(named: candy!.name)
        titleLabel.text = candy?.name
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
