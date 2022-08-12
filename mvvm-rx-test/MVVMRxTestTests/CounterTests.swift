//
//  CounterTests.swift
//  MVVMRxTestTests
//
//  Created by 김범수 on 2022/05/10.
//

import XCTest
import RxTest
import RxSwift
import RxNimble
import Nimble
import Moya

@testable import MVVMRxTest

class CounterTests: XCTestCase {

    var viewModel: CounterViewModel!
    var output: CounterViewModel.Output!
    var scheduler: TestScheduler!
    var bag: DisposeBag!
    
    var refreshSubject: PublishSubject<Void>!
    var plusSubject: PublishSubject<Void>!
    var minusSubject: PublishSubject<Void>!
    
    
    override func setUp() {
        viewModel = CounterViewModel()
        bag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        refreshSubject = PublishSubject<Void>()
        plusSubject = PublishSubject<Void>()
        minusSubject = PublishSubject<Void>()
        viewModel.provider = MoyaProvider<CounterAPI>(endpointClosure: Endpoint.succeedEndpointClosure(CounterAPI.self,
                                                                                                       with: CounterDataModel(counterDefaultValue: 5)),
                                                      stubClosure: MoyaProvider.immediatelyStub)
        output = viewModel.transform(input: .init(refresh: refreshSubject.asObservable(),
                                                  plusAction: plusSubject.asObservable(),
                                                  minusAction: minusSubject.asObservable()))
    }
    
    func testCountedValue() {
        
        scheduler
            .createColdObservable([
                .next(0, ())
            ])
            .bind(to: refreshSubject)
            .disposed(by: bag)
        
        scheduler
            .createColdObservable([
                .next(10, ()),
                .next(20, ()),
                .next(30, ()),
            ])
            .bind(to: plusSubject)
            .disposed(by: bag)
        
        scheduler
            .createColdObservable([
                .next(25, ()),
            ])
            .bind(to: minusSubject)
            .disposed(by: bag)

        expect(self.output.countedValue).events(scheduler: scheduler, disposeBag: bag).to(equal(
                [
                    .next(0, 5),
                    .next(10, 6),
                    .next(20, 7),
                    .next(25, 6),
                    .next(30, 7)
                ]
            ))
        
    }

}
