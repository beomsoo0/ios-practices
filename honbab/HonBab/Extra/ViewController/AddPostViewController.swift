//
//  AddPostViewController.swift
//  HonBab
//
//  Created by 김범수 on 2021/09/25.
//

import UIKit
import RxSwift
import NMapsMap

class AddPostViewController: UIViewController, ViewModelBindType, CLLocationManagerDelegate {

    // IBOutlet - Update Info
    @IBOutlet weak var uploadImg: UIImageView!
    @IBOutlet weak var contentLabel: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var placeLabel: UITextField!
    @IBOutlet weak var maxPeopleSlider: UISlider!
    @IBOutlet weak var maxPeopleLabel: UILabel!
    @IBOutlet weak var pickerTextField: UITextField!
    // IBOutlet - mapView
    @IBOutlet weak var mapView: NMFMapView!
    // IBOutlet - Btn
    @IBOutlet weak var imgAddBtn: UIButton!
    @IBOutlet weak var completeBtn: UIBarButtonItem!
    @IBOutlet weak var backBtn: UIBarButtonItem!
    
    
    // Property
    var viewModel: AddPostViewModel!
    let bag = DisposeBag()
    var locationManager: CLLocationManager!
    var curMarker = NMFMarker()
    
    // Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mapViewSetting()
        pickerSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    func pickerSetting() {

        let pickerView = UIPickerView()
        var pickerData = ["한식", "일식", "중식", "양식", "카페", "도시락", "패스트푸드", "편의점", "기타"]
        let doneToolBar = UIToolbar()
        let doneBarButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: nil)
        
        pickerTextField.rx.text
            .orEmpty
            .bind(to: viewModel.categoryRelay)
            .disposed(by: bag)
        
        doneBarButton.rx.tap
            .subscribe(onNext: { [unowned self] _ in
                let i = pickerView.selectedRow(inComponent: 0)
                self.pickerTextField.text = pickerData[i]
                self.pickerTextField.resignFirstResponder()
            })
            .disposed(by: bag)
        
        //여기서 pickerData를 Observable해서 PickerView에 Binding합니다.
        _ = Observable.just(pickerData)
            .bind(to: pickerView.rx.itemTitles) { [unowned self] (_, item) in
                return "\(item)"
            }
            .disposed(by: bag)
        
        doneToolBar.sizeToFit()
        doneToolBar.items = [doneBarButton]
        pickerTextField.inputAccessoryView = doneToolBar
        pickerTextField.inputView = pickerView
        
    }
    
    func bindViewModel() {
        mapView.addCameraDelegate(delegate: self)
        
        // Upload Info Binding
        viewModel.imgRelay
            .bind(to: uploadImg.rx.image)
            .disposed(by: bag)
        
        placeLabel.rx.text
            .orEmpty
            .bind(to: viewModel.placeRelay)
            .disposed(by: bag)
        
        viewModel.curLatLngRelay
            .subscribe(onNext: { [unowned self] latLng in
                self.addMarker(latLng: latLng)
                self.viewModel.positionRelay.accept("\(latLng.lat)-\(latLng.lng)")
            })
            .disposed(by: bag)
        fetchCurLatLng()
        
        
        contentLabel.rx.text
            .orEmpty
            .bind(to: viewModel.contentRelay)
            .disposed(by: bag)
        
        maxPeopleSlider.rx.value
            .map { Int( $0 * 10 ) }
            .bind(to: viewModel.maxPeopleRelay)
            .disposed(by: bag)
        
        viewModel.maxPeopleRelay
            .map { "\($0)명" }
            .bind(to: maxPeopleLabel.rx.text)
            .disposed(by: bag)
        
        datePicker.rx.date
            .map { $0.dateToStr(format: "yyyy-MM-dd-hh-mm") }
            .bind(to: viewModel.dateRelay)
            .disposed(by: bag)
        

        
        // Push or Modal
        imgAddBtn.rx.action = viewModel.modalAddImgVC(addPostVM: viewModel)
        
//        viewModel.complete
//            .subscribe(onNext: { [unowned self] _ in
//                self.viewModel.backAction.execute()
//            })
//            .disposed(by: bag)
        // Complete
        completeBtn.rx.tap
            .bind(to: viewModel.upload)
            .disposed(by: bag)
        
//        completeBtn.rx.action = viewModel.backAction
        backBtn.rx.action = viewModel.backAction
    }
    
    
    
    
    func mapViewSetting() {
        // Delegate
//        mapView.addCameraDelegate(delegate: self)
//        mapView.touchDelegate = self
//        mapView.removeOptionDelegate(delegate: self)
        
        // Current Position
        mapView.positionMode = .direction
        
//        // Add View
//        let zoomView = NMFZoomControlView(frame: CGRect(x: view.bounds.maxX - 60, y: view.bounds.maxY - 190, width: 30, height: 90))
//        let locationBtn = NMFLocationButton(frame: CGRect(x: view.bounds.minX + 10, y:  view.bounds.maxY - 170, width: 50, height: 50))
//        zoomView.mapView = mapView
//        locationBtn.mapView = mapView
//        view.addSubview(zoomView)
//        view.addSubview(locationBtn)
        
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
        self.viewModel.curLatLngRelay.accept(latLng)
    }
    
    func addMarker(latLng: NMGLatLng) {
        curMarker.mapView = nil

        let marker = NMFMarker(position: latLng)
        marker.iconImage = NMF_MARKER_IMAGE_BLACK
        marker.mapView = self.mapView
        curMarker = marker
    }
    
    
}

extension AddPostViewController: NMFMapViewCameraDelegate {
    // 카메라 이동 후 실행됨
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        let lat = self.mapView.latitude
        let lng = self.mapView.longitude
        let latLng = NMGLatLng(lat: lat, lng: lng)
        viewModel.curLatLngRelay.accept(latLng)
    }
    
}
