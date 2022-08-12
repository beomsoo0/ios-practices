//
//  ViewController.swift
//  iospj
//
//  Created by 김범수 on 2021/07/15.
//

import UIKit

class ViewController: UIViewController {

    var current_Value = 0
    
    @IBOutlet weak var Price_label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }

    @IBAction func showAlert(_ sender: Any) {
        
        let message = "옹심이는    ♥️\(current_Value)♥️ 입니다."
        
        let alert = UIAlertController(title: "Hello", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Button Success", style: .default, handler: {action in self.refresh()})
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func refresh()
    {
        let randomPrice = arc4random_uniform(10000) + 1
        current_Value = Int(randomPrice)
        Price_label.text = "♥️\(current_Value)♥️"
    }
}

