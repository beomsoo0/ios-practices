//
//  VMBinding.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/20.
//

import UIKit
import Action
import RxSwift

protocol ViewModelBindType {
    
    associatedtype ViewModelType
    
    var viewModel: ViewModelType! { get set }
    func bindViewModel()
}

extension ViewModelBindType where Self: UIViewController {
    
    mutating func bind(viewModel: Self.ViewModelType) {
        self.viewModel = viewModel
        loadViewIfNeeded()//?
        
        bindViewModel()
    }
    
}

class CommonViewModel: NSObject { //?
    
    let sceneCoordinator: SceneCoordinator
    
    init (sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }
    
    lazy var backAction = CocoaAction { [unowned self] in
        return self.sceneCoordinator.close(animated: true).asObservable().map { _ in }
    }
    
    lazy var potToRootAction = CocoaAction { [unowned self] in
        return self.sceneCoordinator.popToRoot(animated: true).asObservable().map { _ in }
    }
    
    func alertAction(title: String, message: String, animated: Bool) -> CocoaAction {
        return CocoaAction { [unowned self] _ in
            return self.sceneCoordinator.alert(titile: title, message: message, animated: animated).asObservable().map { _ in }
        }
    }
    
}
