//
//  DatabaseController.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 24/4/2023.
//

import Foundation
import FirebaseAuth
enum DatabaseChange{
    case add
    case remove
    case update
}

enum ListenerType{
    case all
    case exercise
    case routines
    case routine
    case sessions
}

protocol DatabaseListener: AnyObject{
    var listenerType: ListenerType {get set}
    func onExerciseChange(change: DatabaseChange, userExercises: [Exercise])
    
    func onRoutineChange(change: DatabaseChange, routines: [Routine])
    func onRoutineExerciseChange(change: DatabaseChange, routines: Routine)
}

protocol DatabaseProtocol: AnyObject{
    
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    //Authentication Methods
    func emailLogin(email:String, password: String)
    func emailCreateAccount(email:String, password: String)
    func googleSignIn(credential:AuthCredential)
//    //Exercise Methods
    func AddExerciseToFirebase(exercise: Exercise) -> Exercise
    func deleteExercise(exercise: Exercise) -> Bool
//
//
//    //Routine Creation Methods
    var selectedRoutine: Routine{get}
    func selectRoutine(routine:Routine) -> Void
    func addRoutineToFirebase(routine:Routine) -> Bool
    func addExerciseToRoutine(exercise:Exercise) -> Bool
    //Routine Removal Methods
    func removeExerciseFromRoutine(exercise:Exercise, routine: Routine) -> Bool
    func removeRoutine(routine:Routine) -> Bool
      //Fetching Methods
    
}
