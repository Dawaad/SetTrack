//
//  Session.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 24/4/2023.
//

import Foundation
import FirebaseFirestoreSwift
class Session: NSObject, Codable{
    @DocumentID var id: String?
    var name: String?
    var userID: String?
    var date: Date?
    var exercises: [SessionExercise]?
    
}

class SessionExercise: NSObject, Codable{
    var exercise: Exercise
    var sets: Int
    var reps: [Int]
    
    init(exercise: Exercise, sets: Int) {
        self.exercise = exercise
        self.sets = sets
        self.reps = []
    }
}
