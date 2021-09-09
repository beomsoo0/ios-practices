//
//  CustomPropertyViewController.swift
//  RxPractice
//
//  Created by 김범수 on 2021/09/09.
//

import UIKit
import RxSwift
import RxCocoa


class CustomPropertyViewController: UIViewController {

    @IBOutlet weak var resetButton: UIBarButtonItem!
    @IBOutlet weak var slider: UISlider!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        slider.rx.value
            .map { UIColor(cgColor: CGColor(gray: CGFloat($0), alpha: 1)) }
            .bind(to: view.rx.backgroundColor)
            .disposed(by: disposeBag)

        resetButton.rx.tap
            .subscribe(onNext: {
                self.slider.value = 0.5
                self.view.backgroundColor = UIColor(cgColor: CGColor(gray: 0.5, alpha: 1))
            })
            .disposed(by: disposeBag)
        
        
//        slider.rx.color
//            .bind(to: view.rx.backgroundColor)
//            .disposed(by: disposeBag)
//
//        resetButton.rx.tap
//            .map { _ in UIColor(white: 0.5, alpha: 1.0) }
//            .bind(to: slider.rx.color.asObserver(), view.rx.backgroundColor.asObserver())
//            .disposed(by: disposeBag)
        
    }

}

extension Reactive where Base: UISlider {
    
    var color: ControlProperty<UIColor> {
        return base.rx.controlProperty(editingEvents: .valueChanged) { slider in
            UIColor(white: CGFloat(slider.value), alpha: 1.0)
        } setter: { slider, color in
            var white = CGFloat(1)
            color.getWhite(&white, alpha: nil)
            slider.value = Float(white)
        }

    }
    
}
