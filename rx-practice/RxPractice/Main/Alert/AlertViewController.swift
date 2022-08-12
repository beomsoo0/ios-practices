//
//  AlertViewController.swift
//  RxPractice
//
//  Created by 김범수 on 2021/09/08.
//

import UIKit
import RxSwift
import RxCocoa

class AlertViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var currentButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var changeButton: UIButton!
    
    let colorObservable = Observable.of(Color.self)
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        currentButton.rx.tap
            .flatMap({ [unowned self] in
                self.currentAlert(title: "Current Color", message: self.mainView.backgroundColor?.rgbHexString)
            })
            .subscribe(onNext: { [unowned self] actionType in
                switch actionType {
                case .ok:
                    print(self.mainView.backgroundColor?.rgbHexString)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        resetButton.rx.tap
            .flatMap { [unowned self] in
                self.resetAlert(title: "Reset Color", message: "Reset to Black")
            }
            .subscribe(onNext: { [unowned self] actionType in
                switch actionType {
                case .ok:
                    mainView.backgroundColor = UIColor.black
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        changeButton.rx.tap
            .flatMap { [unowned self] in
                self.changeAlert(colors: MaterialBlue.allColors, title: "Change Color", message: "Changing Color?")
            }
            .subscribe(onNext: { [unowned self] color in
                mainView.backgroundColor = color
            })
            .disposed(by: disposeBag)
    }

    
    enum ActionType {
        case ok, cancle
    }
    
    func currentAlert(title: String, message: String?) -> Observable<ActionType> {
        return Observable.create { [weak self] observer in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ok", style: .default, handler: nil)
            observer.onNext(.ok)
            observer.onCompleted()
            
            alert.addAction(okAction)
            self?.present(alert, animated: true, completion: nil)
            return Disposables.create {
//                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func resetAlert(title: String, message: String) -> Observable<ActionType> {
        return Observable.create { [weak self] observer in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ok", style: .default) { _ in
                observer.onNext(.ok)
                observer.onCompleted()
            }
            let cancleAction = UIAlertAction(title: "cancle", style: .default) { _ in
                observer.onNext(.cancle)
                observer.onCompleted()
            }
            alert.addAction(okAction)
            alert.addAction(cancleAction)
            self?.present(alert, animated: true, completion: nil)
            return Disposables.create {
                alert.dismiss(animated: true, completion: nil)
            }

        }
    }
    
    func changeAlert(colors: [UIColor], title: String, message: String) -> Observable<UIColor> {
        return Observable.create { [weak self] observer in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            colors.forEach { color in
                let colorAction = UIAlertAction(title: color.rgbHexString, style: .default) { _ in
                    observer.onNext(color)
                    observer.onCompleted()
                }
                alert.addAction(colorAction)
            }
            self?.present(alert, animated: true, completion: nil)
            return Disposables.create {
                alert.dismiss(animated: true, completion: nil)
            }
            
        }
    }
    
    
}

