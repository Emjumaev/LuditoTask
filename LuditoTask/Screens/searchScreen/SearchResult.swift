//
//  SearchResult.swift
//  LuditoTask
//
//  Created by Mekhriddin Jumaev on 28/07/25.
//

import YandexMapsMobile
import Foundation

struct SearchResult {
    let geoObject: YMKGeoObject
    let name: String?
    let address: String?
    let distance: Double?
}
