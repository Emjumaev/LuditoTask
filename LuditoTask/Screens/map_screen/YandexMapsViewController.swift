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

final class YandexMapsViewController: UIViewController {
    
    private lazy var mapView: YMKMapView = YMKMapView(frame: .zero)
    private let viewModel = YandexMapViewModel()
    private var isMapInitialized = false
    
    private lazy var searchView: MainSearchView = {
        let view = MainSearchView()
        view.searchTextField.isEnabled = false
        view.searchTextField.isUserInteractionEnabled = false
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(searchViewTapped))
        gestureRecognizer.cancelsTouchesInView = true
        view.addGestureRecognizer(gestureRecognizer)
        return view
    }()
    
    private lazy var orientationButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(orientationButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 32
        button.clipsToBounds = true
        button.backgroundColor = .white
        button.setImage(UIImage(named: "tabler_location-filled")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
        setupViewModelBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.startMapKit()
        
        if !isMapInitialized {
            viewModel.initializeUserLocationLayer(mapWindow: mapView.mapWindow, objectListener: self)
            viewModel.startUpdatingLocation()
            isMapInitialized = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopMapKit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - UI Initialization
    private func initViews() {
        view.addSubview(mapView)
        mapView.frame = view.bounds
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewModel.locationManager.delegate = self
        
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
    
    private func setupViewModelBindings() {
        viewModel.onMapMoveToPoint = { [weak self] point, zoom, duration in
            guard let self = self else { return }
            let cameraPosition = YMKCameraPosition(target: point, zoom: zoom, azimuth: 0, tilt: 0)
            self.mapView.mapWindow.map.move(
                with: cameraPosition,
                animation: YMKAnimation(type: .smooth, duration: Float(duration)),
                cameraCallback: nil
            )
        }
        
        viewModel.onPlacemarkAdded = { [weak self] placemark in
            placemark.addTapListener(with: self!)
        }
        
        viewModel.onShowAboutVC = { [weak self] geoObject in
            guard let self = self else { return }
            let vc = AboutViewController()
            vc.setGeoObject(geoObject)
            self.navigationController?.presentPanModal(vc)
        }
    }
    
    @objc private func searchViewTapped() {
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
        
        let vm = SearchViewModel()
        let vc = SearchPageViewController(vm, userLocation: viewModel.userLocation)
        vc.delegate = self
        self.navigationController?.presentPanModal(vc)
    }
    
    private func restoreSearchView() {
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
    
    @objc private func orientationButtonTapped() {
        viewModel.moveToUserLocation()
    }
}

extension YandexMapsViewController: SearchResultsDelegate {
    func viewWillDismiss() {
        restoreSearchView()
    }
    
    func didSelectSearchResult(_ result: YMKGeoObject) {
        viewModel.setGeoObject(result)
        if let point = result.geometry.first?.point {
            viewModel.addPlacemark(at: point, mapObjects: mapView.mapWindow.map.mapObjects, placemarkTapListener: self)
        }
    }
    
    func viewDidDismiss(_ geoObject: YMKGeoObject) {
        viewModel.setGeoObject(geoObject)
        viewModel.onShowAboutVC?(geoObject)
    }
}

extension YandexMapsViewController: YMKMapObjectTapListener {
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let placemark = mapObject as? YMKPlacemarkMapObject else {
            return false
        }
        viewModel.focusOnPlacemark(placemark)
        return true
    }
}

extension YandexMapsViewController: YMKUserLocationObjectListener {
    func onObjectAdded(with view: YMKUserLocationView) {
        view.pin.setIconWith(UIImage(named: "map_pin") ?? UIImage())
        view.arrow.setIconWith(UIImage(named: "map_pin") ?? UIImage())
    }
    
    func onObjectRemoved(with view: YMKUserLocationView) {}
    
    func onObjectUpdated(with view: YMKUserLocationView, event: YMKObjectEvent) {}
}

extension YandexMapsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            viewModel.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        viewModel.userLocation = location
        viewModel.onUserLocationUpdated?(location)
    }
}
