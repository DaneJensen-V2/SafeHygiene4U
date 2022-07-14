//
//  Review.swift
//  Safe Hygeine 4U
//
//  Created by Dane Jensen on 7/11/22.
//
import Foundation
public class review : NSObject, Codable {
    let location : String
    let date : Date
    let rating : Int
    let content : String
}
