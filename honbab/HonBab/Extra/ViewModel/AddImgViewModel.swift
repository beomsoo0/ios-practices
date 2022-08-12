//
//  AddImgViewModel.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/25.
//

import Foundation
import RxSwift
import Action

class AddImgViewModel: CommonViewModel {

    let bag = DisposeBag()
    var photoManager = PhotoManager()
    let complete: PublishSubject<UIImage>
    let photosSubject: BehaviorSubject<[UIImage]>
    let fetching: PublishSubject<CGSize>
    weak var otherVM: ImgHasViewModel!
    
    override init(sceneCoordinator: SceneCoordinator) {
        complete = PublishSubject<UIImage>()
        photosSubject = BehaviorSubject<[UIImage]>(value: [])
        fetching = PublishSubject<CGSize>()
        
        super.init(sceneCoordinator: sceneCoordinator)
        print("@@@@@@ AddImgViewModel Init @@@@@@")
        
        fetching
            .subscribe(onNext: { [unowned self] imgSize in
                let photos = self.photoManager.fetchAllPhotos(imgSize: imgSize)
                print("$$$$$$$$$ PHOTOSIZE: ", photos[0].size)
                self.photosSubject.onNext(photos)
            })
            .disposed(by: bag)
        
        complete
            .subscribe(onNext: { [unowned self] img in
                self.otherVM.imgRelay.accept(img)
                self.backAction.execute()
            })
            .disposed(by: bag)
    }
    
    deinit {
        print("@@@@@@ AddImgViewModel Deinit @@@@@@")
    }
}
