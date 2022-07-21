//
//  UserModel.swift
//  Safe Hygeine 4U
//  Created by Dane Jensen on 6/23/22.
//


import Foundation

//A new user will be created when someone creates an account, this info will be stored in DB

struct UserData : Codable{
    var Username : String
    var userID : String
    var email : String
    var ratings : [Int] //Change to an array of Ratings once ratings is done
    
}


