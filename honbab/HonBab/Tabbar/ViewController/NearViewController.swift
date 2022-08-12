//
//  NearViewController.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/20.
//

import UIKit
import NMapsMap
import RxSwift
import Kingfisher
import CoreLocation
import RxCocoa

class NearViewController: UIViewController, ViewModelBindType, CLLocationManagerDelegate {

    // IBOutlet
    @IBOutlet weak var mapView: NMFMapView!
    
    // Parameter
    var viewModel: NearViewModel!
    let bag = DisposeBag()
    var locationManager: CLLocationManager!
    var markers = [NMFMarker]()
    
    // Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mapViewSetting()
        bindViewModel()
        fetchCurLatLng()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func bindViewModel() {
        
        // 지도 Bound 정보 전송
        rx.viewWillAppear
            .map { [unowned self] _ in self.mapView.contentBounds }
            .bind(to: viewModel.curBoundsSubject)
            .disposed(by: bag)
 
        
        viewModel.mapPostsSubject
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] mapPosts in
                self.addPostsMarker(mapPosts: mapPosts)
            })
            .disposed(by: bag)
      
        
    }
    
    func mapViewSetting() {
        // Delegate
        mapView.addCameraDelegate(delegate: self)
        mapView.touchDelegate = self
        mapView.removeOptionDelegate(delegate: self)
        
        // Current Position
        mapView.positionMode = .direction
        
        // Add View
        let zoomView = NMFZoomControlView(frame: CGRect(x: view.bounds.maxX - 60, y: view.bounds.maxY - 190, width: 30, height: 90))
        let locationBtn = NMFLocationButton(frame: CGRect(x: view.bounds.minX + 10, y:  view.bounds.maxY - 170, width: 50, height: 50))
        
        zoomView.mapView = mapView
        locationBtn.mapView = mapView
        locationBtn.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                print("###")
                
                let coor = locationManager.location?.coordinate
                let latitude = coor?.latitude ?? 0
                let longitude = coor?.longitude ?? 0
                let latLng = NMGLatLng(lat: latitude, lng: longitude)
                
                let cameraUpdate = NMFCameraUpdate(scrollTo: latLng)
                mapView.moveCamera(cameraUpdate)
            })
            .disposed(by: bag)
        
        view.addSubview(zoomView)
        view.addSubview(locationBtn)
        
        // Zoom and Scroll
        mapView.minZoomLevel = 5.0
        mapView.maxZoomLevel = 18.0
        mapView.allowsZooming = true
        mapView.allowsScrolling = true
        mapView.allowsTilting = false
        mapView.allowsRotating = false
        
        // Map display Info
        mapView.setLayerGroup(NMF_LAYER_GROUP_BUILDING, isEnabled: true)
        mapView.setLayerGroup(NMF_LAYER_GROUP_TRANSIT, isEnabled: true)
    }

    func fetchCurLatLng() {
        //locationManager 인스턴스 생성 및 델리게이트 생성
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        //포그라운드 상태에서 위치 추적 권한 요청
        locationManager.requestWhenInUseAuthorization()
        
        //배터리에 맞게 권장되는 최적의 정확도
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //위치업데이트
        locationManager.startUpdatingLocation()

        //위도 경도 가져오기
        let coor = locationManager.location?.coordinate
        let latitude = coor?.latitude ?? 0
        let longitude = coor?.longitude ?? 0
        let latLng = NMGLatLng(lat: latitude, lng: longitude)
        
        let latLngStr = "\(latLng.lat)-\(latLng.lng)"
        self.viewModel.curPositionSubject.onNext(latLngStr)
    }
    
    func addPostsMarker(mapPosts: [MapPost]) {
        markers.map { [unowned self] in $0.mapView = nil } // 안됨
        markers = []

        mapPosts.forEach { [unowned self] mapPost in
            let lat = mapPost.latLng.lat
            let lng = mapPost.latLng.lng
            
            let coordi = NMGLatLng(lat: lat, lng: lng)
            
            let marker = NMFMarker(position: coordi)
            
            // 시간 차이로 마커 색깔 만들기
            marker.iconImage = NMF_MARKER_IMAGE_BLACK
//            marker.iconTintColor = findMarkerColor(date: promiseDate.strToDate())
            
            marker.touchHandler = { [unowned self] (overlay: NMFOverlay) -> Bool in
                
                Service.shared.fetchPost(puid: mapPost.puid)
                    .subscribe(onNext: { [unowned self] post in
                        self.viewModel.pushPostVC(post: post, nearVM: self.viewModel).execute()
                    })
                    .disposed(by: bag)
                
                return true
            }
            marker.mapView = self.mapView
            markers.append(marker)
        }
    }
    
    func findMarkerColor(date: Date) -> UIColor {
        let curDate = Date()
        
        let timeIntervalDiff = date.timeIntervalSinceReferenceDate -  curDate.timeIntervalSinceReferenceDate
        let dayDiff = timeIntervalDiff / 86400
        
        if dayDiff < 0 {
            return UIColor.gray
        } else if dayDiff < 1 {
            return UIColor.red
        } else if dayDiff < 5 {
            return UIColor.orange
        } else if dayDiff < 10 {
            return UIColor.green
        } else {
            return UIColor.blue
        }
    }
    
    deinit {
        print("@@@@@@ NearViewController Deinit @@@@@@")
    }
}


extension NearViewController: NMFMapViewCameraDelegate, NMFMapViewOptionDelegate, NMFMapViewTouchDelegate {
    // Touch
    private func mapView(_ mapView: NMFMapView, didTapMap latlng: Any!, point: CGPoint) {
        print("Touched: \(String(describing: latlng))")
    }
    // Camera
    func mapViewRegionIsChanging(_ mapView: NMFMapView, byReason reason: Int) {
        print(mapView.cameraPosition)
        print("카메라 변경 - reason: \(reason)")
        print("#####")
    }
    
    // 카메라 이동 후 실행됨
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        viewModel.curBoundsSubject.onNext( self.mapView.contentBounds )
    }
    
}
