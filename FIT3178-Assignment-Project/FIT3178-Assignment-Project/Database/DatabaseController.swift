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
    func onSessionSubmision(change: DatabaseChange, sessions: [Session])
}

protocol DatabaseProtocol: AnyObject{
    
    func cleanup()
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    //Authentication Methods
    func emailLogin(email:String, password: String)
    func emailCreateAccount(email:String, password: String)
    func googleSignIn(credential:AuthCredential)
    func signOut()
//    //Exercise Methods
    func AddExerciseToFirebase(exercise: Exercise) -> Exercise
    func deleteExercise(exercise: Exercise) -> Bool
//
//
//    //Routine Creation Methods
    var selectedRoutine: Routine? {get}
    func selectRoutine(routine:Routine) -> Void
    func addRoutineToFirebase(routine:Routine) -> Bool
    func addExerciseToRoutine(exercise:Exercise, set:Int) -> Bool
    //Routine Removal Methods
    func removeExerciseFromRoutine(exercise:ExerciseDetails, routine: Routine) -> Bool
    func removeRoutine(routine:Routine) -> Bool
    func updateExerciseSetCountInRoutine(exercise: ExerciseDetails, set: Int,routine: Routine) -> Bool
      //Fetching Methods
    
    //Session Methods
    var activeSession: Session?{get}
    func setActiveSession()
    func addSesssionToFirebase()
    //Core Data Methods
    func deleteSessionFromCoreData(session:CoreSession)
    func fetchStoredSessionFromCoreData() -> CoreSession?
    func saveSessionToCoreData(session: Session)
    
    func updateSetWeight(weight: Int, exerciseID: String, setNum: Int) -> Void
    func updateSetRest(rest: Int, exerciseID: String, setNum: Int) -> Void
    func updateSetReps(reps: Int, exerciseID: String, setNum: Int) -> Void
    
    //Transform Method
    func routineToSession(routine: Routine) -> Session
    
    //Statistic Method
    var statRoutine: Routine?{get}
    var statExercise: Exercise?{get}
    
    func setStatRoutine(routine: Routine)
    func setStatExercise(exercise: Exercise)
    
    func retrieveDataForGraph(routine: Routine, exercise: Exercise) -> [Int]
}
