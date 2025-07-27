//
//  CoreDataManager.swift
//  LuditoTask
//
//  Created by Mekhriddin Jumaev on 27/07/25.
//

import Foundation
import CoreData
import YandexMapsMobile

enum SavePlaceError: Error {
    case noCoordinates
    case duplicatePlace
    case coreDataSaveFailed(Error)
}

final class CoreDataManager {
    static let shared = CoreDataManager()

    private let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "Places")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func saveContext() {
        let ctx = persistentContainer.viewContext
        if ctx.hasChanges {
            do {
                try ctx.save()
            } catch {
                print("Core Data Save Error: \(error)")
            }
        }
    }

    func savePlace(_ model: YMKGeoObject, completion: @escaping (Result<Void, SavePlaceError>) -> Void) {
        guard let point = model.geometry.first?.point else {
            completion(.failure(.noCoordinates))
            return
        }

        let name = model.name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let latitude = point.latitude
        let longitude = point.longitude

        if isDuplicatePlace(name: name, latitude: latitude, longitude: longitude) {
            completion(.failure(.duplicatePlace))
            return
        }

        let place = SavedPlace(context: context)
        place.name = name
        place.address = model.descriptionText
        place.latitude = latitude
        place.longitude = longitude

        do {
            try context.save()
            completion(.success(()))
        } catch {
            completion(.failure(.coreDataSaveFailed(error)))
        }
    }


    func fetchPlaces(sortedBy sortKey: String = "name") -> [SavedPlace] {
        let request: NSFetchRequest<SavedPlace> = SavedPlace.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: true)]

        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch places: \(error)")
            return []
        }
    }

    func deletePlace(_ place: SavedPlace) {
        context.delete(place)
        saveContext()
    }

    private func isDuplicatePlace(name: String, latitude: Double, longitude: Double) -> Bool {
        let request: NSFetchRequest<SavedPlace> = SavedPlace.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "name ==[c] %@", name),
            NSPredicate(format: "latitude == %lf", latitude),
            NSPredicate(format: "longitude == %lf", longitude)
        ])

        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("Failed to check for duplicates: \(error)")
            return false
        }
    }
}
