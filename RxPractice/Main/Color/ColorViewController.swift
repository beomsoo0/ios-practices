//
//  ColorViewController.swift
//  RxPractice
//
//  Created by 김범수 on 2021/09/08.
//

import UIKit
import RxCocoa
import RxSwift

class ColorViewController: UIViewController {

    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var redScroll: UISlider!
    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var greenScroll: UISlider!
    @IBOutlet weak var greenLabel: UILabel!
    @IBOutlet weak var blueScroll: UISlider!
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    
    let disposeBag = DisposeBag()
    let viewModel = ColorViewModel()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        redScroll.rx.value
            .map { CGFloat($0) }
            .bind(to: viewModel.redVal)
            .disposed(by: disposeBag)
        
        greenScroll.rx.value
            .map { CGFloat($0) }
            .bind(to: viewModel.greenVal)
            .disposed(by: disposeBag)
        
        blueScroll.rx.value
            .map { CGFloat($0) }
            .bind(to: viewModel.blueVal)
            .disposed(by: disposeBag)
        
        viewModel.viewColor
            .bind(to: colorView.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        viewModel.redVal
            .map { "\(Int($0 * 255))" }
            .bind(to: redLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.greenVal
            .map { "\(Int($0 * 255))" }
            .bind(to: greenLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.blueVal
            .map { "\(Int($0 * 255))" }
            .bind(to: blueLabel.rx.text)
            .disposed(by: disposeBag)
        
        clearButton.rx.tap
            .subscribe(onNext: {
                self.clearSlider()
                self.viewModel.clear()
            })
            .disposed(by: disposeBag)

    }
 
    func clearSlider() {
        redScroll.value = 0
        greenScroll.value = 0
        blueScroll.value = 0
    }
}
