//
//  NameSetViewController.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/20.
//

import UIKit
import RxSwift
class NameSetViewController: UIViewController, ViewModelBindType {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var genderField: UISegmentedControl!
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    
    let bag = DisposeBag()
    var viewModel: RegisterViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetting()
    }
    
    func uiSetting() {
        nameField.becomeFirstResponder()
    }
    
    func bindViewModel() {
        
        nameField.rx.text
            .orEmpty
            .bind(to: viewModel.nameSubject)
            .disposed(by: bag)
        
        birthDatePicker.rx.date
            .map {  $0.dateToStr(format: "yyyy-MM-dd") }
            .bind(to: viewModel.birthSubject)
            .disposed(by: bag)
        
        genderField.rx.value
            .map { $0 == 0 ? "남" : "여" }
            .bind(to: viewModel.genderSubject)
            .disposed(by: bag)

    }
    
    deinit {
        print("@@@@@@@ NameSetViewController VC Deinit @@@@@@@@@@")
    }
}
