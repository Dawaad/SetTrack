//
//  Session.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 24/4/2023.
//

import Foundation

class Session{
    var name: String
    var exercises: [String]
    var date: Date
    
    init(name: String, exercises: [String], date: Date) {
        self.name = name
        self.exercises = exercises
        self.date = date
    }
}
