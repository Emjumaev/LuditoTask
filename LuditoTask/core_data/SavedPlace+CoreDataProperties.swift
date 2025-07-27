//
//  SavedPlace+CoreDataProperties.swift
//  
//
//  Created by Mekhriddin Jumaev on 27/07/25.
//
//

import Foundation
import CoreData


extension SavedPlace {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedPlace> {
        return NSFetchRequest<SavedPlace>(entityName: "SavedPlace")
    }

    @NSManaged public var address: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?

}
