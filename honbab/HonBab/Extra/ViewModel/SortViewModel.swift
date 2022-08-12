//
//  SortViewModel.swift
//  HonBab
//
//  Created by 김범수 on 2021/10/07.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxRelay
import Action

class SortViewModel: CommonViewModel {
    let bag = DisposeBag()

    let foodCategorySubject: BehaviorSubject<[FoodCategory]>
    let categorySubject: BehaviorSubject<String>
    
    let sorting: PublishRelay<SortingType>
    let indexing: PublishSubject<Int>
    let complete:  PublishRelay<Void>
    
    weak var homeVM: HomeViewModel!
    
    override init(sceneCoordinator: SceneCoordinator) {
        
        let foodCategory = [
            FoodCategory(name: "한식", image: UIImage(named: "Default_Profile")!),
            FoodCategory(name: "일식", image: UIImage(named: "Default_Profile")!),
            FoodCategory(name: "중식", image: UIImage(named: "Default_Profile")!),
            FoodCategory(name: "양식", image: UIImage(named: "Default_Profile")!),
            FoodCategory(name: "카페", image: UIImage(named: "Default_Profile")!),
            FoodCategory(name: "도시락", image: UIImage(named: "Default_Profile")!),
            FoodCategory(name: "패스트푸드", image: UIImage(named: "Default_Profile")!),
            FoodCategory(name: "편의점", image: UIImage(named: "Default_Profile")!),
            FoodCategory(name: "기타", image: UIImage(named: "Default_Profile")!),
            FoodCategory(name: "전부", image: UIImage(named: "Default_Profile")!)
        ]
        // Model Subject
        foodCategorySubject = BehaviorSubject<[FoodCategory]>(value: foodCategory)
        categorySubject = BehaviorSubject<String>(value: "전부")
        // ADT
        sorting = PublishRelay<SortingType>()
        indexing = PublishSubject<Int>()
        complete = PublishRelay<Void>()
        
        super.init(sceneCoordinator: sceneCoordinator)
        print("@@@@@@ SortViewModel Init @@@@@@")
        
        indexing
            .subscribe(onNext: { [unowned self] idx in
                self.categorySubject.onNext(foodCategory[idx].name)
            })
            .disposed(by: bag)
        
        complete
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.instance)
            .withLatestFrom(Observable.combineLatest(sorting, categorySubject))
            .subscribe(onNext: { [unowned self] (sort, category) in
                let categoryVM = CategoryViewModel(sceneCoordinator: sceneCoordinator, sort: sort, category: category)
                let categoryScene = Scene.category(categoryVM)
                self.sceneCoordinator.transition(to: categoryScene, using: .push, animated: true)
            })
            .disposed(by: bag)
    }

    
    
    deinit {
        print("@@@@@@ SortViewModel Deinit @@@@@@")
    }
}
