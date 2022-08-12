//
//  GestureViewController.swift
//  RxPractice
//
//  Created by 김범수 on 2021/09/08.
//

import UIKit
import RxSwift
import RxCocoa

class GestureViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet var panGesture: UIPanGestureRecognizer!

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainView.center = view.center
        
        panGesture.rx.event
            .subscribe(onNext: { [unowned self] gesture in
                guard let target = gesture.view else { return }
                
                let translation = gesture.translation(in: self.view)
                target.center.x += translation.x
                target.center.y += translation.y
                
                gesture.setTranslation(.zero, in: self.view)
                
            })
            .disposed(by: disposeBag)
        
        
    }
 
}
