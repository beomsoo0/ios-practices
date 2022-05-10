//
//  CounterViewController.swift
//  MVVMRxTest
//
//  Created by 김범수 on 2022/05/10.
//

import UIKit
import RxSwift
import RxCocoa

class CounterViewController: UIViewController {

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    
    let bag = DisposeBag()
    let viewModel = CounterViewModel()
    
    private lazy var input = CounterViewModel.Input(refresh: .just(()),
                                                    plusAction: plusButton.rx.tap.asObservable(),
                                                    minusAction: minusButton.rx.tap.asObservable())
    private lazy var output = viewModel.transform(input: input)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
    
    private func bind() {
        output.countedValue.map { String($0) }.drive(countLabel.rx.text).disposed(by: bag)
    }


}

