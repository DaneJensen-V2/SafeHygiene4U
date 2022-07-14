//
//  FullServiceInfo.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 7/11/22.
//

import Foundation
import CoreLocation
import CoreData

struct fullServiceInfo : Codable{
    var name : String
    var latitude : Double
    var longitude : Double
    var address : String?
    var serviceType : String
    var Pricing : String
    var isOnGoogle : Bool
    var hours : String?
    var serviceDetails : [String]
    var phoneNumber : String?
    var hostName : String?
    var rating : Double
    var reviews : [review]
    var image : String?
}

@objc public enum serviceDetailTypes : Int16 {
    case shower
    case church
}
public class serviceDetail : NSObject{
    let type : serviceDetailTypes
    let serviceDescription : String?
    
    
    init(type : serviceDetailTypes, serviceDescription : String?){
        self.type = type
        self.serviceDescription = serviceDescription
    }
}

public class hours : NSObject{
    let day : Int
    let hours : String
    
    init(day : Int, hours : String){
        self.day = day
        self.hours = hours
    }
}
