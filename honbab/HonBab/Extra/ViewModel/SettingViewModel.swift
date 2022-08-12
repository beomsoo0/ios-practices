//
//  SideMenuViewModel.swift
//  HonBab
//
//  Created by 김범수 on 2021/10/11.
//

import Foundation
import RxSwift
import Action

struct SettingModel {
    let title: String
}

enum SettingURLType {
    case naver, google, daum
}

class SettingViewModel: CommonViewModel {
    
    let bag = DisposeBag()
    let settingSubject: BehaviorSubject<[SettingModel]>
        
    override init(sceneCoordinator: SceneCoordinator) {
        let data: [SettingModel] =  [SettingModel(title: "프로필 편집"),
                                         SettingModel(title: "친구 초대"),
                                         SettingModel(title: "게시물 보관"),
                                         SettingModel(title: "네이버"),
                                         SettingModel(title: "구글"),
                                         SettingModel(title: "다음"),
                                         SettingModel(title: "로그아웃")]
        
        settingSubject = BehaviorSubject<[SettingModel]>(value: data)
        
        super.init(sceneCoordinator: sceneCoordinator)
        print("@@@@@@ SettingViewModel Init @@@@@@")
    }
    
    func logOutBtnSelected() -> Completable {
        return Completable.create { [unowned self] completable in
            AuthManager.shared.logOut_Auth()
                .subscribe({ [unowned self] success in
                    switch success {
                    case .completed:
                        Service.shared = Service()
//                        Service.shared.initServicePostParameter()
                        completable(.completed)
                    case .error(let error):
                        completable(.error(error))
                    }
                })
                .disposed(by: self.bag)
            return Disposables.create()
        }
    }

    deinit {
        print("@@@@@@ SettingViewModel Deinit @@@@@@")
    }
}
