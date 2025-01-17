//
//  Car+CoreDataProperties.swift
//  CarsCoreData
//
//  Created by Firdavs Bagirov on 10/29/20.
//
//

import Foundation
import CoreData


extension Car {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Car> {
        return NSFetchRequest<Car>(entityName: "Car")
    }

    @NSManaged public var imageData: Data?
    @NSManaged public var lastStarted: Date?
    @NSManaged public var mark: String?
    @NSManaged public var model: String?
    @NSManaged public var myChoise: Bool
    @NSManaged public var rating: Double
    @NSManaged public var timesDriven: Int16
    @NSManaged public var tintColor: NSObject?

}

extension Car : Identifiable {

}
