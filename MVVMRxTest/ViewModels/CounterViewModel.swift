//
//  CounterViewModel.swift
//  MVVMRxTest
//
//  Created by 김범수 on 2022/05/10.
//

import UIKit
import RxSwift
import RxCocoa
import Moya


protocol ViewModelType: class {
    
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

class CounterViewModel: ViewModelType {

    let bag = DisposeBag()
    var provider = MoyaProvider<CounterAPI>()
    
    struct Input {
        var refresh: Observable<Void>
        var plusAction: Observable<Void>
        var minusAction: Observable<Void>
    }

    struct Output {
        var countedValue: Driver<Int>
    }
    
    func transform(input: Input) -> Output {
        let countedValue = BehaviorRelay<Int>(value: 0)
        
        let counterObservable = input.refresh
            .flatMapLatest { [provider] _ in
                return provider.rx.request(.init())
                    .map(CounterDataModel.self)
            }.share()
        
        counterObservable
            .map { $0.counterDefaultValue }
            .subscribe(onNext: {
                countedValue.accept($0)
            })
            .disposed(by: bag)
        
        Observable.merge(
            input.plusAction.map { 1 },
            input.minusAction.map { -1 }
        )
            .map { countedValue.value + $0 }
            .bind(to: countedValue)
            .disposed(by: bag)
        
        return Output(countedValue: countedValue.asDriver(onErrorJustReturn: 0))
    }
    
    
}
