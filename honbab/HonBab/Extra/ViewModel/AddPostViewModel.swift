//
//  AddPostViewModel.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/25.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import NMapsMap

class AddPostViewModel: CommonViewModel, ImgHasViewModel {
    let bag = DisposeBag()

    let curUserSubject: BehaviorSubject<User>
    let postSubject: PublishSubject<Post>
    var imgRelay: BehaviorRelay<UIImage>
    let placeRelay: PublishRelay<String>
    let contentRelay: PublishRelay<String>
    let dateRelay: PublishRelay<String>
    let positionRelay: PublishRelay<String>
    let maxPeopleRelay: BehaviorRelay<Int>
    let categoryRelay: PublishRelay<String>
    let curLatLngRelay: PublishRelay<NMGLatLng>
    
    let upload: PublishRelay<Void>
    let complete: PublishRelay<String>
    
    init(sceneCoordinator: SceneCoordinator, homeVM: HomeViewModel) {
        curUserSubject = Service.shared.curUserSubject
        postSubject = PublishSubject<Post>()
        imgRelay = BehaviorRelay<UIImage>(value: UIImage(named: "Default_Profile")!)
        placeRelay = PublishRelay<String>()
        contentRelay = PublishRelay<String>()
        dateRelay = PublishRelay<String>()
        positionRelay = PublishRelay<String>()
        maxPeopleRelay = BehaviorRelay<Int>(value: 5)
        categoryRelay = PublishRelay<String>()
        curLatLngRelay = PublishRelay<NMGLatLng>()
        
        upload = PublishRelay<Void>()
        complete = PublishRelay<String>()
        
        super.init(sceneCoordinator: sceneCoordinator)
        print("@@@@@@ AddPostViewModel Init @@@@@@")
        
        Observable.combineLatest(imgRelay, placeRelay, contentRelay, dateRelay, positionRelay, maxPeopleRelay, categoryRelay)
            .subscribe(onNext: { [unowned self] img, place, content, date, position, maxPeople, foodCategory in
                let uid = AuthManager.shared.curUid()!
                let promise = Promise(hostUid: uid, maxPeople: maxPeople)
                let post = Post(puid: "Non", img: img, imgURL: nil, place: place, content: content, date: date, uid: uid, position: position, postDate: Date().dateToStr(format: "yyyy-MM-dd-hh-mm"), promise: promise, foodCategory: foodCategory)
                self.postSubject.onNext(post)
            })
            .disposed(by: bag)
        

        // UploadLogin : CompletBtn -> Position Fechting -> Upload -> homVM Adding -> Back
        
        upload.withLatestFrom(postSubject)
            .subscribe(onNext: { [unowned self] post in
                Service.shared.uploadPost(post: post)
                    .subscribe({ success in
                        switch success {
                        case .success(let puid):
                            self.complete.accept(puid)
                        case .error(let error):
                            // errorSubject
                            print("업로드 에러")
                        }
                    })
                    .disposed(by: self.bag)
            })
            .disposed(by: bag)
        
        complete
            .withLatestFrom(Observable.combineLatest(complete, postSubject, curUserSubject, homeVM.postsSubject))
            .subscribe(onNext: { [unowned self] (puid, upLoadPost, curUser, posts) in
                // CurUser (For ProfileVC)
                upLoadPost.puid = puid
                upLoadPost.user = curUser
                curUser.postPuids.append(upLoadPost.puid)
                self.curUserSubject.onNext(curUser)
                // Posts (For HomeVC)
                var newPost = posts
                newPost.insert(upLoadPost, at: 0)
                homeVM.postsSubject.onNext(newPost)
                homeVM.scrolling.onNext(0)
                backAction.execute()
            })
            .disposed(by: bag)
            
    }
    
    func modalAddImgVC(addPostVM: AddPostViewModel) -> CocoaAction {
        return CocoaAction { [unowned self] _ in
            let addImgVM = AddImgViewModel(sceneCoordinator: self.sceneCoordinator)
            let addImgScene = Scene.addImg(addImgVM)
            addImgVM.otherVM = addPostVM
            return self.sceneCoordinator.transition(to: addImgScene, using: .modal, animated: true).asObservable().map { _ in }      
        }
    }

    func curDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-hh-mm"
        let dateStr = dateFormatter.string(from: date)
        return dateStr
    }
    
    deinit {
        print("@@@@@@ AddPostViewModel Deinit @@@@@@")
    }
}
