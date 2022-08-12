//
//  BindOneViewController.swift
//  RxPractice
//
//  Created by 김범수 on 2021/09/08.
//

import UIKit
import RxSwift
import RxCocoa

class BindOneViewController: UIViewController {

    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var colorSeg: UISegmentedControl!
    
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()

        colorSeg.rx.value
            .bind(to: colorLabel.rx.segmentedValue)
            .disposed(by: disposeBag)
            
//        colorSeg.rx.value
//            .subscribe(onNext: { [weak self] val in
//                switch val {
//                case 0:
//                    self?.colorLabel.text = "Red"
//                    self?.colorLabel.textColor = .red
//                case 1:
//                    self?.colorLabel.text = "Green"
//                    self?.colorLabel.textColor = .green
//                case 2:
//                    self?.colorLabel.text = "Blue"
//                    self?.colorLabel.textColor = .blue
//                default:
//                    self?.colorLabel.text = "None"
//                    self?.colorLabel.textColor = .black
//                }
//            })
//            .disposed(by: disposeBag)
            
    }
    


}

extension Reactive where Base: UILabel {
    
    var segmentedValue: Binder<Int> {
        return Binder(self.base) { label, index in
            switch index {
            case 0:
                label.text = "Red"
                label.textColor = .red
            case 1:
                label.text = "Green"
                label.textColor = .green
            case 2:
                label.text = "Blue"
                label.textColor = .blue
            default:
                label.text = "None"
                label.textColor = .black
            }
        }
    }
    
}
