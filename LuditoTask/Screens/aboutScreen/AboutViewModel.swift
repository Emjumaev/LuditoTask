//
//  AboutViewModel.swift
//  LuditoTask
//
//  Created by Mekhriddin Jumaev on 28/07/25.
//

import UIKit
import PanModal
import YandexMapsMobile
import SnapKit

class AboutViewModel {

    private var geoObject: YMKGeoObject?
    private let coreDataManager: CoreDataManager
    
    var onUpdateUI: ((String, String, String) -> Void)?
    var onShowConfirmationAlert: ((String, String, @escaping () -> Void) -> Void)?
    var onShowResultAlert: ((String) -> Void)?
    
    init(coreDataManager: CoreDataManager = CoreDataManager.shared) {
        self.coreDataManager = coreDataManager
    }
    
    func setGeoObject(_ geoObject: YMKGeoObject) {
        self.geoObject = geoObject
        let name = geoObject.name ?? "Unknown Place"
        let address = geoObject.descriptionText ?? "No address available"
        let reviewText = "517 оценок"
        print("AboutViewModel: Updating UI with name: \(name), address: \(address), reviews: \(reviewText)")
        onUpdateUI?(name, address, reviewText)
    }
    
    func makeFavorite() {
        guard let geoObject = geoObject else {
            onShowResultAlert?("Ошибка: нет данных об объекте")
            return
        }
        let title = "Добавить адрес в избранное"
        let message = geoObject.name ?? "Без названия"

        onShowConfirmationAlert?(title, message) {
            self.coreDataManager.savePlace(geoObject) { result in
                let alertMessage: String
                switch result {
                case .success:
                    alertMessage = "Адрес добавлен в избранное: \(geoObject.name ?? "")"
                case .failure(let error):
                    switch error {
                    case .noCoordinates:
                        alertMessage = "Ошибка: не удалось получить координаты."
                    case .duplicatePlace:
                        alertMessage = "Адрес уже добавлен в избранное."
                    case .coreDataSaveFailed(let err):
                        alertMessage = "Ошибка при сохранении: \(err.localizedDescription)"
                    }
                }

                self.onShowResultAlert?(alertMessage)
            }
        }
    }
}
