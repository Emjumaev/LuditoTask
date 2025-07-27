//
//  File.swift
//  LuditoTask
//
//  Created by Mekhriddin Jumaev on 24/07/25.
//

import UIKit
import YandexMapsMobile
import PanModal
import CoreLocation

final class YandexMapSampleViewController: UIViewController, UIGestureRecognizerDelegate, CLLocationManagerDelegate, YMKUserLocationObjectListener {
    
    var currentGeoObject: YMKGeoObject? = nil
    
    // MARK: - YMKUserLocationObjectListener
    func onObjectAdded(with view: YMKUserLocationView) {
        view.pin.setIconWith(UIImage(named: "map_pin") ?? UIImage())
        view.arrow.setIconWith(UIImage(named: "map_pin") ?? UIImage())
    }

    func onObjectRemoved(with view: YMKUserLocationView) {}

    func onObjectUpdated(with view: YMKUserLocationView, event: YMKObjectEvent) {}

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
    }

    // MARK: - Properties
    lazy var mapView: YMKMapView = YMKMapView(frame: .zero)
    var currentPlacemark: YMKPlacemarkMapObject?
    let locationManager = CLLocationManager()
    var userLocationLayer: YMKUserLocationLayer?
    var userLocation: CLLocation?
    var isMapInitialized = false

    lazy var searchView: MainSearchView = {
        let view = MainSearchView()
        view.searchTextField.isEnabled = false
        view.searchTextField.isUserInteractionEnabled = false
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(searchViewTapped))
        gestureRecognizer.cancelsTouchesInView = true
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        return view
    }()

    lazy var orientationButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(orientationButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 32
        button.clipsToBounds = true
        button.backgroundColor = .white
        button.setImage(UIImage(named: "tabler_location-filled")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        YMKMapKit.sharedInstance().onStart()

        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
            
            if !isMapInitialized {
                mapKitUserLocation()
                isMapInitialized = true
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        userLocationLayer?.setObjectListenerWith(nil)
        
        userLocationLayer = nil
        isUserLayerInitialized = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    var isUserLayerInitialized = false

    // MARK: - MapKit User Location
    func mapKitUserLocation() {
        guard !isUserLayerInitialized else { return }

        userLocationLayer = YMKMapKit.sharedInstance().createUserLocationLayer(with: mapView.mapWindow)
        userLocationLayer?.setVisibleWithOn(true)
        userLocationLayer?.setObjectListenerWith(self)
        userLocationLayer?.isHeadingModeActive = false
        isUserLayerInitialized = true
    }

    // MARK: - UI Initialization
    private func initViews() {
        view.addSubview(mapView)
        mapView.frame = view.bounds
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(searchView)
        searchView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(56)
        }

        view.addSubview(orientationButton)
        orientationButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-120)
            make.height.width.equalTo(64)
        }
    }

    @objc func searchViewTapped() {
        let offsetY = -searchView.frame.maxY

        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 0.8,
            options: [.curveEaseInOut],
            animations: {
                self.searchView.transform = CGAffineTransform(translationX: 0, y: offsetY)
            }
        )
        let vc = SearchPageViewController()
        vc.userLocation = userLocation
        vc.delegate = self
        self.navigationController?.presentPanModal(vc)
    }

    func restoreSearchView() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 0.7,
            options: [.curveEaseInOut],
            animations: {
                self.searchView.transform = .identity
            }
        )
    }

    @objc func orientationButtonTapped() {
        guard let location = userLocation else {
            print("User location not available.")
            return
        }

        let point = YMKPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let cameraPosition = YMKCameraPosition(target: point, zoom: 15, azimuth: 0, tilt: 0)

        mapView.mapWindow.map.move(
            with: cameraPosition,
            animation: YMKAnimation(type: .smooth, duration: 0.5),
            cameraCallback: nil
        )
    }

    func addPlacemarkAtPoint(_ point: YMKPoint) {
        if let current = currentPlacemark {
            mapView.mapWindow.map.mapObjects.remove(with: current)
        }
        let newPlacemark = mapView.mapWindow.map.mapObjects.addPlacemark(with: point)
        newPlacemark.setIconWith(UIImage(named: "pinpoint")!)
        currentPlacemark = newPlacemark
        currentPlacemark?.addTapListener(with: self)

        mapView.mapWindow.map.move(
            with: YMKCameraPosition(target: point, zoom: 15, azimuth: 0, tilt: 0),
            animation: YMKAnimation(type: .smooth, duration: 0.3),
            cameraCallback: nil
        )
    }
}

// MARK: - Search Results Delegate
extension YandexMapSampleViewController: SearchResultsDelegate {
    func viewWillDismiss() {
        restoreSearchView()
    }
    
    func didSelectSearchResult(_ result: YMKGeoObject) {
        if let point = result.geometry.first?.point {
            addPlacemarkAtPoint(point)
        }
    }
    
    func viewDidDismiss(_ geoObject: YMKGeoObject) {
        showAboutVC(geoObject)
    }
    
    func showAboutVC(_ geoObject: YMKGeoObject) {
        self.currentGeoObject = geoObject
        let vc = AboutViewController()
        vc.setGeoObject(geoObject)
        self.navigationController?.presentPanModal(vc)
    }
}

extension YandexMapSampleViewController: YMKMapObjectTapListener {
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let placemark = mapObject as? YMKPlacemarkMapObject else {
            return false
        }
        self.focusOnPlacemark(placemark)
        return true
    }
    
    func focusOnPlacemark(_ placemark: YMKPlacemarkMapObject) {
        mapView.mapWindow.map.move(
            with: YMKCameraPosition(target: placemark.geometry, zoom: 15, azimuth: 0, tilt: 0),
            animation: YMKAnimation(type: YMKAnimationType.smooth, duration: 0.3),
            cameraCallback: nil
        )
        if let geoObject = currentGeoObject {
            showAboutVC(geoObject)
        }
    }
}
