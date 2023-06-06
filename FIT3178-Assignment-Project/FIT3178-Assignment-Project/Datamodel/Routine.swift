//
//  Routine.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 24/4/2023.
//

import Foundation

import Foundation
import FirebaseFirestoreSwift




class Routine: NSObject, Codable{
    @DocumentID var id: String?
    var name: String?
    var userID: String?
    var exercises: [ExerciseDetails] = []
    
}

class ExerciseDetails: NSObject, Codable{
    var exercise: Exercise
    var sets: Int
    
    init(exercise: Exercise, sets: Int) {
        self.exercise = exercise
        self.sets = sets
        
    }
}
