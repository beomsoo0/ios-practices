//
//  CustomEventViewController.swift
//  RxPractice
//
//  Created by 김범수 on 2021/09/09.
//

import UIKit
import RxSwift
import RxCocoa

class CustomEventViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var countButton: UILabel!
    @IBOutlet weak var doneBtn: UIButton!

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textField.layer.borderWidth = 3
        textField.layer.borderColor = UIColor.gray.cgColor
        
        textField.rx.text
            .orEmpty
            .map { "\($0.count)" }
            .bind(to: countButton.rx.text)
            .disposed(by: disposeBag)
            
        doneBtn.rx.tap
            .subscribe(onNext: {
                self.textField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        textField.rx.editingBegin
            .map { UIColor.red }
            .bind(to: textField.rx.borderColor)
            .disposed(by: disposeBag)
        
        textField.rx.editingEnd
            .map { UIColor.gray }
            .bind(to: textField.rx.borderColor)
            .disposed(by: disposeBag)
        
    }
 

}

extension Reactive where Base: UITextField {
    
    var borderColor: Binder<UIColor> {
        return Binder(self.base) { textField, color in
            textField.layer.borderColor = color.cgColor
        }
    }
    
    var editingBegin: ControlEvent<Void> {
        return controlEvent(.editingDidBegin)
    }
    
    var editingEnd: ControlEvent<Void> {
        return controlEvent(.editingDidEnd)
    }
    
}
