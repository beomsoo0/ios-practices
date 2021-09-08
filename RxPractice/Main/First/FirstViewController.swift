//
//  FirstViewController.swift
//  RxPractice
//
//  Created by 김범수 on 2021/09/08.
//

import UIKit
import RxSwift
import RxCocoa

class FirstViewController: UIViewController {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    
    let disposeBag = DisposeBag()
    
//    let textRelay = BehaviorRelay(value: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainLabel.text = "\(self)"
        
        inputTextField.rx.text
            .orEmpty
            .bind(to: displayLabel.rx.text)
            .disposed(by: disposeBag)
        
//        inputTextField.rx.text
//            .orEmpty
//            .bind(to: textRelay)
//            .disposed(by: disposeBag)
//
//        textRelay
//            .bind(to: displayLabel.rx.text)
//            .disposed(by: disposeBag)
        
        
    }
    


}
