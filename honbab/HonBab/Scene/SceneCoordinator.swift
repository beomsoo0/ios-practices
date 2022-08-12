//
//  SceneCoordinator.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/20.
//

import UIKit
import RxSwift
import RxCocoa

class SceneCoordinator {
    
    let window: UIWindow
    var currentVC: UIViewController
    
    
    required init (window: UIWindow) {
        self.window = window
        currentVC = window.rootViewController!
    }
    
    @discardableResult
    func transition(to scene: Scene, using style: TransitionStyle, animated: Bool) -> Completable {
        
        let subject = PublishSubject<Void>()
        let target = scene.instantiate()
        let bag = DisposeBag()
        
        switch style {
        
        case .root:
            currentVC = target.sceneViewController
            window.rootViewController = target
            subject.onCompleted()
            
        case .push:
            guard let curNavVC = currentVC.navigationController else {
                subject.onError(TransitionError.navigationControllerMissing)
                break
            }
            curNavVC.rx.willShow //?
                .subscribe(onNext: { event in
                    self.currentVC = event.viewController.sceneViewController
                })
                .disposed(by: bag)
            
            curNavVC.pushViewController(target, animated: animated)
            currentVC = target.sceneViewController
            subject.onCompleted()
            
        case .modal:
            target.modalPresentationStyle = .fullScreen
            currentVC.present(target, animated: animated) {
                subject.onCompleted()
            }
            currentVC = target
            subject.onCompleted()
        }
        
        return subject.ignoreElements() //?
    }
    
    @discardableResult
    func close(animated: Bool) -> Completable {
        return Completable.create { [unowned self] completable in
            if let presentingVC = self.currentVC.presentingViewController {
                self.currentVC.dismiss(animated: animated) {
                    self.currentVC = presentingVC.sceneViewController
                    completable(.completed)
                }
            } else if let navVC = self.currentVC.navigationController {
                guard navVC.popViewController(animated: animated) != nil else {
                    completable(.error(TransitionError.cannotPop))
                    return Disposables.create()
                }
                currentVC = navVC.viewControllers.last!
                completable(.completed)
            } else {
                completable(.error(TransitionError.unknown))
            }
            return Disposables.create()
        }
    }

    @discardableResult
    func popToRoot(animated: Bool) -> Completable {
        return Completable.create { [unowned self] completable in
            while let presentingVC = self.currentVC.presentingViewController {
                self.currentVC.dismiss(animated: animated) {
                    self.currentVC = presentingVC.sceneViewController
                }
            }
            if let navVC = self.currentVC.navigationController {
                guard navVC.popToRootViewController(animated: animated) != nil else {
                    completable(.error(TransitionError.cannotPop))
                    return Disposables.create()
                }
                currentVC = navVC.viewControllers.last!
                completable(.completed)
            } else {
                completable(.error(TransitionError.unknown))
            }
            return Disposables.create()
        }
    }
    
    @discardableResult
    func alert(titile: String, message: String, animated: Bool) -> Completable {
        let subject = PublishSubject<Void>()
        let alert = UIAlertController(title: titile, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
        self.currentVC.present(alert, animated: animated, completion: nil)
        subject.onCompleted()
        return subject.ignoreElements()
    }
    
    
    
}

extension UIViewController {
    var sceneViewController: UIViewController {
        return self.children.first ?? self
    }
    
}
