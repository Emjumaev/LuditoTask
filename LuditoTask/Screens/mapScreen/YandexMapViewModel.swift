//
//  YandexMapViewModel.swift
//  LuditoTask
//
//  Created by Mekhriddin Jumaev on 28/07/25.
//

import UIKit
import YandexMapsMobile
import PanModal
import CoreLocation
import SnapKit

class YandexMapViewModel {

    private var mapKit: YMKMapKit
    var locationManager: CLLocationManager
    private var userLocationLayer: YMKUserLocationLayer?
    private var currentPlacemark: YMKPlacemarkMapObject?
    private var currentGeoObject: YMKGeoObject?
    private var isUserLayerInitialized = false
    var userLocation: CLLocation?
    
    var onUserLocationUpdated: ((CLLocation) -> Void)?
    var onMapMoveToPoint: ((YMKPoint, Float, TimeInterval) -> Void)?
    var onPlacemarkAdded: ((YMKPlacemarkMapObject) -> Void)?
    var onShowAboutVC: ((YMKGeoObject) -> Void)?
    
    init(mapKit: YMKMapKit = YMKMapKit.sharedInstance(), locationManager: CLLocationManager = CLLocationManager()) {
        self.mapKit = mapKit
        self.locationManager = locationManager
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startMapKit() {
        mapKit.onStart()
    }
    
    func stopMapKit() {
        userLocationLayer?.setObjectListenerWith(nil)
        userLocationLayer = nil
        isUserLayerInitialized = false
    }
    
    func initializeUserLocationLayer(mapWindow: YMKMapWindow, objectListener: YMKUserLocationObjectListener?) {
        guard !isUserLayerInitialized else { return }
        
        userLocationLayer = mapKit.createUserLocationLayer(with: mapWindow)
        userLocationLayer?.setVisibleWithOn(true)
        userLocationLayer?.setObjectListenerWith(objectListener)
        userLocationLayer?.isHeadingModeActive = false
        isUserLayerInitialized = true
    }
    
    func startUpdatingLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func addPlacemark(at point: YMKPoint, mapObjects: YMKMapObjectCollection, placemarkTapListener: YMKMapObjectTapListener?) {
        if let current = currentPlacemark {
            mapObjects.remove(with: current)
        }
        let newPlacemark = mapObjects.addPlacemark(with: point)
        newPlacemark.setIconWith(UIImage(named: "pinpoint")!)
        currentPlacemark = newPlacemark
        currentPlacemark?.addTapListener(with: placemarkTapListener!)
        onPlacemarkAdded?(newPlacemark)
        moveMapTo(point: point, zoom: 15, duration: 0.3)
    }
    
    func focusOnPlacemark(_ placemark: YMKPlacemarkMapObject) {
        moveMapTo(point: placemark.geometry, zoom: 15, duration: 0.3)
        if let geoObject = currentGeoObject {
            onShowAboutVC?(geoObject)
        }
    }
    
    func moveToUserLocation() {
        guard let location = userLocation else {
            print("User location not available.")
            return
        }
        let point = YMKPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        moveMapTo(point: point, zoom: 15, duration: 0.5)
    }
    
    func setGeoObject(_ geoObject: YMKGeoObject) {
        self.currentGeoObject = geoObject
    }
    
    private func moveMapTo(point: YMKPoint, zoom: Float, duration: TimeInterval) {
        onMapMoveToPoint?(point, zoom, duration)
    }
}
