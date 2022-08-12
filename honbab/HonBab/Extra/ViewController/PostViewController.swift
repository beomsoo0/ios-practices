//
//  PostViewController.swift
//  HonBab
//
//  Created by 김범수 on 2021/10/01.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher
import NMapsMap
import Action

class PostViewController: UIViewController, ViewModelBindType {
   
    // IBOutlet - Post
    @IBOutlet weak var postImgView: UIImageView!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postSubLabel: UILabel!

    @IBOutlet weak var postCategoryLabel: UILabel!
    @IBOutlet weak var postContentLabel: UITextView!
    
    // IBOutlet - User
    @IBOutlet weak var userProfileImgView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userSubLabel: UILabel!
    // IBOutlet - View
    @IBOutlet weak var mapView: NMFMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    // IBOutlet - Btn
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var promiseBtn: UIButton!
    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBOutlet weak var shareBtn: UIButton!
    
    let bag = DisposeBag()
    var viewModel: PostViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        settingUI()
        mapViewSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.clipsToBounds = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    func settingUI() {
        [mapView].forEach {
            $0?.layer.cornerRadius = ($0?.bounds.width ?? 0) * 0.5
        }
        
        [promiseBtn, chatBtn].forEach {
            $0?.isSelected = false
        }
        
        likeBtn.setTitle("", for: .normal)
        self.navigationItem.rightBarButtonItem?.title = ""
    }
    
    func bindViewModel() {
        collectionView.delegate = nil
        collectionView.dataSource = nil
        
        rx.viewWillAppear
            .take(1)
            .map { _ in () }
            .bind(to: viewModel.fetching)
            .disposed(by: bag)
        
        viewModel.postSubject
            .subscribe(onNext: { [unowned self] post in
                if let imgURL = post.imgURL {
                    self.postImgView.kf.setImage(with: imgURL, placeholder: nil, options: [.transition(.fade(0.7))])
                } else if let img = post.img {
                    self.postImgView.image = img
                }
               
                self.postContentLabel.text = post.content

                
                var dis = 0.0 // ditance 수정 필요
                self.viewModel.curUserSubject
                    .subscribe(onNext: { [unowned self] in
                        dis = post.calDistance(curUserPos: $0.curPosition ?? "0-0")
                    })
                    .disposed(by: bag)

                self.postTitleLabel.text = post.place
                self.postSubLabel.text = "\(post.promiseDate_relative) " + String(format: "%.2fkm", dis)
                self.postCategoryLabel.text = post.foodCategory
                
                self.promiseBtn.setTitle("  \(post.promise.curNum) / \(post.promise.maxPeople)", for: .normal)
            })
            .disposed(by: bag)

        viewModel.usersSubject
            .map { $0.first }
            .subscribe(onNext: { [unowned self] user in
                guard let user = user else { return }
                if let imgURL = user.imgURL {
                    self.userProfileImgView.kf.setImage(with: imgURL, placeholder: nil, options: [.transition(.fade(0.7))])
                } else if let img = user.img {
                    self.userProfileImgView.image = img
                }
                self.userProfileImgView.layer.cornerRadius = self.userProfileImgView.bounds.width * 0.5
                
                self.userNameLabel.text = user.name
                self.userSubLabel.text = "\(user.age) \(user.gender)"
                
                self.userNameLabel.sizeToFit()
                self.userSubLabel.sizeToFit()
            })
            .disposed(by: bag)
        
        viewModel.usersSubject
            .bind(to: collectionView.rx.items(cellIdentifier: "PostCollectViewCell", cellType: PostCollectViewCell.self)) { [unowned self] (idx, user, cell) in
                if let imgURL = user.imgURL {
                    cell.userImgView.kf.setImage(with: imgURL, placeholder: nil, options: [.transition(.fade(0.7))])
                } else if let img = user.img {
                    cell.userImgView.image = img
                }
                cell.userImgView.layer.cornerRadius = cell.userImgView.bounds.width * 0.5

                cell.userInfoLabel.text = "\(user.name) \(user.age) \(user.gender)"
                cell.userInfoLabel.sizeToFit()
                
            }
            .disposed(by: bag)
        
        // Map
        viewModel.postSubject
            .map { $0.position }
            .subscribe(onNext: { [unowned self] position in
                self.settingMap(position: position)
            })
            .disposed(by: bag)
        
        // Btn
        viewModel.promiseValid
            .subscribe(onNext: { [unowned self] (isContain, isFull) in
                let img = isContain ? UIImage(systemName: "minus")! : UIImage(systemName: "plus")!
                self.promiseBtn.setImage(img, for: .normal)
                let isEnable = isContain == false && isFull == true ? false : true
                self.promiseBtn.isEnabled = isEnable
            })
            .disposed(by: bag)
        
        promiseBtn.rx.tap
            .bind(to: viewModel.promising)
            .disposed(by: bag)
        
        chatBtn.rx.action = viewModel.pushChatRoomVC()
        
        shareBtn.rx.tap
            .withLatestFrom(viewModel.postSubject)
            .subscribe(onNext: { [unowned self] post in
                print("@@@@@@")
                let activityItems: [Any] = [post.content]
                let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                self.present(activityVC, animated: true)
            })
            .disposed(by: self.bag)
        
        backBtn.rx.action = viewModel.backAction
    }
    

    
    func settingMap(position: String) {
        let posLatLng = position.components(separatedBy: "-").map { Double($0)! }

        let latLng = NMGLatLng(lat: posLatLng[0], lng: posLatLng[1])
        // 카메라 위치 변경
        let cameraUpdate = NMFCameraUpdate(scrollTo: latLng)
        mapView.moveCamera(cameraUpdate)
        // 마커 생성
        let curMarker = NMFMarker(position: latLng)
        curMarker.iconImage = NMF_MARKER_IMAGE_BLACK
        curMarker.iconTintColor = .red
        curMarker.mapView = mapView
    }


    func mapViewSetting() {
        // Zoom and Scroll
        mapView.allowsZooming = false
        mapView.allowsScrolling = false
        mapView.allowsTilting = false
        mapView.allowsRotating = false
        
        // Map display Info
        mapView.setLayerGroup(NMF_LAYER_GROUP_BUILDING, isEnabled: true)
        mapView.setLayerGroup(NMF_LAYER_GROUP_TRANSIT, isEnabled: true)
    }
}

class PostCollectViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var userInfoLabel: UILabel!
    
}
