//
//  Exercise.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 24/4/2023.
//

import Foundation
import FirebaseFirestoreSwift
enum ExerciseCategory: Int{
    case chest = 0
    case back = 1
    case biceps = 2
    case triceps = 3
    case legs = 4
    case shoulders = 5
}

enum CodingLeys: String, CodingKey{
    case id
    case name
    case exerciseDescription
    case category
}

class Exercise: NSObject, Codable{
    @DocumentID var id: String?
    var name: String?
    var exerciseDescription: String?
    var category: Int?
    
    
    
}

extension Exercise{
    var exerciseCategory: ExerciseCategory{
        get{
            return ExerciseCategory(rawValue: self.category!)!
        }
        set{
            self.category = newValue.rawValue
        }
    }
}
