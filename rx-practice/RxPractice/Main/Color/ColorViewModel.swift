//
//  ColorViewModel.swift
//  RxPractice
//
//  Created by 김범수 on 2021/09/08.
//

import Foundation
import RxSwift
import RxCocoa

class ColorViewModel {
    
    let disposeBag = DisposeBag()
    
    var redVal = BehaviorSubject<CGFloat>(value: 0)
    var greenVal = BehaviorSubject<CGFloat>(value: 0)
    var blueVal = BehaviorSubject<CGFloat>(value: 0)
    
    var viewColor = BehaviorSubject<UIColor>(value: UIColor.black)
    
    var myColor = Color(red: 0, green: 0, blue: 0)
    
    init() {
        
        redVal.map{ red -> UIColor in
            self.myColor = Color(red: red, green: self.myColor.green, blue: self.myColor.blue)
            return self.myColor.setColor()
        }
        .bind(to: viewColor)
        .disposed(by: disposeBag)
        
        greenVal.map{ green -> UIColor in
            self.myColor = Color(red: self.myColor.red, green: green, blue: self.myColor.blue)
            return self.myColor.setColor()
        }
        .bind(to: viewColor)
        .disposed(by: disposeBag)
        
        redVal.map{ blue -> UIColor in
            self.myColor = Color(red: self.myColor.red, green: self.myColor.green, blue: blue)
            return self.myColor.setColor()
        }
        .bind(to: viewColor)
        .disposed(by: disposeBag)
        
        
//        Observable.combineLatest(redVal, greenVal, blueVal)
//            .map{ UIColor(red: $0, green: $1, blue: $2, alpha: 1) }
//            .bind(to: viewColor)
//            .disposed(by: disposeBag)
        
    }
    
    func clear() {
        redVal.onNext(0)
        greenVal.onNext(0)
        blueVal.onNext(0)
    }
    
}

class Color {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    
    init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    func setColor() -> UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
