//
//  VMBinding.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/09/10.
//

import UIKit

protocol ViewModelBindType {
    associatedtype ViewModelType
    
    var viewModel: ViewModelType! { get set }
    func bindViewModel()
}

extension ViewModelBindType where Self: UIViewController {
    mutating func bind(viewModel: Self.ViewModelType) {
        self.viewModel = viewModel
        loadViewIfNeeded()

        bindViewModel()
    }
}

class CommonViewModel: NSObject {
    let sceneCoordinator: SceneCoordinatorType
    
    init(sceneCoordinator: SceneCoordinatorType) {
        self.sceneCoordinator = sceneCoordinator
    }
}
