//
//  SceneCoordinator.swift
//  RxBeomstagram
//
//  Created by 김범수 on 2021/09/10.
//

import RxSwift
import RxCocoa

extension UIViewController {
    //if Nav -> firstVC else -> self
    var sceneViewController: UIViewController {
        return self.children.first ?? self
    }
}

protocol SceneCoordinatorType {
    @discardableResult
    func transition(to scene: Scene, using style: TransitionStyle, animated: Bool) -> Observable<Never>
}

class SceneCoordinator: SceneCoordinatorType {
    
    private let disposeBag = DisposeBag()
    
    private let window: UIWindow
    private var currentVC : UIViewController
    
    required init(window: UIWindow) {
        self.window = window
        currentVC = window.rootViewController!
    }
    
    @discardableResult
    func transition(to scene: Scene, using style: TransitionStyle, animated: Bool) -> Observable<Never> {
        
        let subject = PublishSubject<Void>()
        let target = scene.instantiate()

        switch style {
        case .root:
            currentVC = target.sceneViewController
            window.rootViewController = target
            subject.onCompleted()
        case .push:
            guard let navVC = currentVC.navigationController else {
                subject.onError(TransitionError.navigationControllerMissing)
                break
            }
            
            navVC.rx.willShow
                .subscribe(onNext: { event in
                    self.currentVC = event.viewController.sceneViewController
                })
                .disposed(by: disposeBag)
            
            navVC.pushViewController(target, animated: animated)
            currentVC = target.sceneViewController
            subject.onCompleted()
        case .modal:
            currentVC.present(target, animated: animated) {
                subject.onCompleted()
            }
            currentVC = target
        }
        
        return subject.ignoreElements()//??
    }
    
}







