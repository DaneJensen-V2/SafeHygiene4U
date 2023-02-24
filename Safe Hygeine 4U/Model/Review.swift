//
//  Review.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 7/11/22.
//
import Foundation
struct review : Codable {
    let location : String
    let date : String
    let rating : Int
    let content : String
    let user : String
    
    enum CodingKeys: CodingKey {
         case location
         case date
         case rating
         case content
        case user
     }
}
struct reviewDate {
    let location : String
    let date : Date
    let rating : Int
    let content : String
    let user : String
}
