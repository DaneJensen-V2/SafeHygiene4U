//
//  Hygiene Service.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 6/18/22.
//

import Foundation

struct hygieneService : Codable{
    var latitude : Double
    var longitude : Double
    var serviceType : String
    var rating : Int
    var title : String
    var info : String
    
    enum CodingKeys: String, CodingKey {
        
        case latitude
        case longitude
        case serviceType
        case rating
        case title
        case info
        
    }
}

enum serviceTypes {
    case bathroom, shower, partner, laundromat
}
class HygieneAnnotations: NSObject {
    var services:[HygieneAnnotation]
     
    override init(){
       //build an array of pizza loactions literally
        services = [HygieneAnnotation(33.58963,-111.83879, title: "Bathroom 1", subtitle:"Free Bathroom", type: .bathroom, rating: 3)]
        services += [HygieneAnnotation(33.59083,-111.83705, title: "Shower 1", subtitle:"Free Shower", type: .shower, rating: 5)]
        services += [HygieneAnnotation(33.59726,-111.84319, title: "Shower 2", subtitle:"Free Shower", type: .shower, rating: 1)]
        services += [HygieneAnnotation(37.32774,-122.02730, title: "Bathroom 2", subtitle:"Free Bathroom", type: .bathroom, rating: 5)]
        services += [HygieneAnnotation(37.33631,-122.03586, title: "Shower 3", subtitle:"Free Shower", type: .shower, rating: 3)]
        services += [HygieneAnnotation(37.32440,-122.03598, title: "Bathroom 3", subtitle:"Free Bathroom", type: .bathroom, rating: 1)]
    
    }
}
