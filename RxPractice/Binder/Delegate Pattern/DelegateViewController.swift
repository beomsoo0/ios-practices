//
//  DelegateViewController.swift
//  RxPractice
//
//  Created by 김범수 on 2021/09/09.
//

import UIKit
import MapKit
import CoreLocation
import RxSwift
import RxCocoa

class DelegateViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let disposeBag = DisposeBag()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        locationManager.rx.didUpdateLocations
            .subscribe(onNext: { locations in
                print(locations)
            })
            .disposed(by: disposeBag)
        
        locationManager.rx.didUpdateLocations
            .map { $0[0] }
            .bind(to: mapView.rx.center)
            .disposed(by: disposeBag)
        
        
        
    }


}

extension Reactive where Base: MKMapView {
    public var center: Binder<CLLocation> {
        return Binder(self.base) { mapView, location in
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
            self.base.setRegion(region, animated: true)
        }
    }
}

extension CLLocationManager: HasDelegate {
    public typealias Delegate = CLLocationManagerDelegate
}

class RxCLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType, CLLocationManagerDelegate {
    
    weak private(set) var locationManager: CLLocationManager?
    
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
        super.init(parentObject: locationManager, delegateProxy: RxCLLocationManagerDelegateProxy.self)
        
    }
    
    static func registerKnownImplementations() {
        self.register {
            RxCLLocationManagerDelegateProxy(locationManager: $0)
        }
    }
}

extension Reactive where Base: CLLocationManager {
    var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base)
    }
    
    var didUpdateLocations: Observable<[CLLocation]> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:)))
            .map { parameters in
                return parameters[1] as! [CLLocation]
            }
    }
}
