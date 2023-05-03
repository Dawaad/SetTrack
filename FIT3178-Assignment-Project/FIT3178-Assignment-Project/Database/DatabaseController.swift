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
    
}

protocol DatabaseListener: AnyObject{
    var listenerType: ListenerType {get set}
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
    func AddExerciseToFirebase(exercise: Exercise) -> Bool
//    func deleteExercise() -> Void
//
//
//    //Routine Creation Methods
//    func addExerciseToRoutine(exercise:Exercise) -> Bool
//    func removeExerciseFromRoutine(exercise:Exercise) -> Bool
      //Fetching Methods
    func fetchUserExercises(userID: String) -> [Exercise]
}
