//
//  Exercise.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 24/4/2023.
//

import Foundation
import FirebaseFirestoreSwift


enum CodingKeys: String, CodingKey{
    case id
    case name
    case instructions
    case difficulty
    case category

}

class Exercise: NSObject, Codable{
    var id: String?
    var name: String?
    var isCustom: Bool?
    var userID: String?
    var instructions: String?
    var difficulty: String?
    var category: String?
    
    
    
}


