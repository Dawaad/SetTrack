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
    var routineID: String?
    var name: String?
    var userID: String?
    var startDateTime: Date?
    var endDateTime: Date?
    var exercises: [SessionExercise]?
    
    private enum CodingKeys: String, CodingKey {
            case id
            case name
            case userID
            case routineID
            case startDateTime
            case endDateTime
            case exercises
        }
    
}

class SessionExercise: NSObject, Codable{
    var exercise: Exercise
    var sets: Int
    var performance: [SetRepWeight]
    
    init(exercise: Exercise, sets: Int, performance: [SetRepWeight]) {
        self.exercise = exercise
        self.sets = sets
        self.performance = performance
    }
   
}

class SetRepWeight: NSObject, Codable{
    var rep: Int
    var weight: Int
    var restTime: Int
    
    init(rep: Int, weight: Int, restTime: Int) {
        self.rep = rep
        self.weight = weight
        self.restTime = restTime
    }
    
    
}
