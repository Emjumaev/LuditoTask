//
//  FavoriteViewModel.swift
//  LuditoTask
//
//  Created by Mekhriddin Jumaev on 28/07/25.
//

import UIKit
import SnapKit

class FavoriteViewModel {

    private var places: [SavedPlace] = []
    private let coreDataManager: CoreDataManager
    
    var onPlacesUpdated: (([SavedPlace], Bool) -> Void)?
    
    init(coreDataManager: CoreDataManager = CoreDataManager.shared) {
        self.coreDataManager = coreDataManager
    }
    
    func fetchSavedPlaces() {
        places = coreDataManager.fetchPlaces(sortedBy: "name")
        onPlacesUpdated?(places, places.isEmpty)
    }
    
    func deletePlace(at index: Int) {
        let placeToDelete = places[index]
        coreDataManager.deletePlace(placeToDelete)
        places.remove(at: index)
        onPlacesUpdated?(places, places.isEmpty)
    }
    
    func numberOfPlaces() -> Int {
        return places.count
    }
    
    func place(at index: Int) -> SavedPlace {
        return places[index]
    }
}
