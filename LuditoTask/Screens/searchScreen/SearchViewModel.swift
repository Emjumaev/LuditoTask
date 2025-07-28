//
//  SearchViewModel.swift
//  LuditoTask
//
//  Created by Mekhriddin Jumaev on 28/07/25.
//

import Foundation
import YandexMapsMobile
import CoreLocation

class SearchViewModel {
    var userLocation: CLLocation?
    private let searchManager: YMKSearchManager
    private var searchSession: YMKSearchSession?
    var selectedGeoObject: YMKGeoObject?
    
    var searchResults: [SearchResult] = []
    var onSearchResultsUpdated: (() -> Void)?
    
    init() {
        self.searchManager = YMKSearchFactory.instance().createSearchManager(with: .combined)
    }
    
    func searchForPlace(_ searchText: String) {
        searchSession?.cancel()
        
        guard !searchText.isEmpty else {
            searchResults = []
            onSearchResultsUpdated?()
            return
        }
        
        let userPoint: YMKPoint
        if let location = userLocation {
            userPoint = YMKPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        } else {
            userPoint = YMKPoint(latitude: 41.2995, longitude: 69.2401)
        }
        
        let searchOptions = YMKSearchOptions()
        searchOptions.searchTypes = [.geo, .biz]
        searchOptions.userPosition = userPoint
        
        searchSession = searchManager.submit(
            withText: searchText,
            geometry: YMKGeometry(point: userPoint),
            searchOptions: searchOptions,
            responseHandler: { [weak self] (searchResponse, error) in
                guard let self = self else { return }
                if let response = searchResponse {
                    let geoObjects = response.collection.children.compactMap { $0.obj }
                    self.searchResults = geoObjects.map { geoObject in
                        let info = self.extractInfo(from: geoObject)
                        return SearchResult(geoObject: geoObject, name: info.name, address: info.address, distance: info.distance)
                    }
                    if self.userLocation != nil {
                        self.searchResults.sort { (a, b) -> Bool in
                            let distA = a.distance ?? Double.greatestFiniteMagnitude
                            let distB = b.distance ?? Double.greatestFiniteMagnitude
                            return distA < distB
                        }
                    }
                    self.onSearchResultsUpdated?()
                } else if let error = error {
                    print("Search error: \(error.localizedDescription)")
                }
            }
        )
    }
    
    private func extractInfo(from geoObject: YMKGeoObject) -> (name: String?, address: String?, distance: Double?) {
        var distance: Double? = nil
        print("yyyy", geoObject.geometry.first?.point)
        print("zzzz", userLocation)
        if let userLocation = userLocation,
           let targetPoint = geoObject.geometry.first?.point {
            let geoLocation = CLLocation(latitude: targetPoint.latitude, longitude: targetPoint.longitude)
            distance = userLocation.distance(from: geoLocation)
        }
        print("xxxx", distance)
        return (geoObject.name, geoObject.descriptionText, distance)
    }
}
