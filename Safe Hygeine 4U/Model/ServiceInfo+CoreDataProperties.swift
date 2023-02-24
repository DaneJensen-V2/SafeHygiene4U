//
//  ServiceInfo+CoreDataProperties.swift
//  
//
//  Created by Dane Jensen on 7/13/22.
//
//

import Foundation
import CoreData


extension ServiceInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ServiceInfo> {
        return NSFetchRequest<ServiceInfo>(entityName: "ServiceInfo")
    }

    @NSManaged public var address: String?
    @NSManaged public var hostName: String?
    @NSManaged public var hours: [String]?
    @NSManaged public var image: String?
    @NSManaged public var isOnGoogle: Bool
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var pricing: String?
    @NSManaged public var rating: Double
    @NSManaged public var serviceDetails: [String]?
    @NSManaged public var reviews: Int
    @NSManaged public var serviceType: String?
    @NSManaged public var website: String? 
    @NSManaged public var isEvent: Bool
    @NSManaged public var isVerified: Bool
    @NSManaged public var notes: String?
    
}
