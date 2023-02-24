//
//  Hygiene Service.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 6/18/22.
//

import Foundation
import Lottie

//Struct for a hygiene service with all the info needed
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

enum serviceTypes : String{
    case shower, clothing, nonProfit
}

//
//  OnboaringSlide.swift
//  Yummie
//
//  Created by Emmanuel Okwara on 30/01/2021.
//

import UIKit

struct OnboardingSlide {
    let title: String
    let description: String
    let animation: LottieAnimation
}
