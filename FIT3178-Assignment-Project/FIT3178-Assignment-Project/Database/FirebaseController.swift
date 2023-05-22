//
//  FirebaseController.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 24/4/2023.
//

import Foundation

import FirebaseFirestoreSwift
import Firebase
import FirebaseAuth

class FirebaseController: NSObject, DatabaseProtocol{
  
    
    
    
    
    
    
    
    
    
   
    var selectedRoutine: Routine
    var database: Firestore
    var authController: Auth
    var usersRef: CollectionReference?
    var exercisesRef: CollectionReference?
    var routinesRef: CollectionReference?
    var listeners = MulticastDelegate<DatabaseListener>()
    var currentUser: FirebaseAuth.User?
//    var authListenerHandler: AuthStateDidChangeListenerHandle?
    var allExercises: [Exercise] = [Exercise]()
    var allRoutines: [Routine] = [Routine]()
    override init() {
        
        FirebaseApp.configure()
        selectedRoutine = Routine()
        authController = Auth.auth()
        database = Firestore.firestore()
        usersRef = database.collection("users")
        exercisesRef = database.collection("exercises")
        routinesRef = database.collection("routines")
        super.init()
        
        let authListenerHandler = authController.addStateDidChangeListener{
            (_,user) in
            if user != nil{
                self.currentUser = user!
                //Set Up Listeners and parsers pls daddy
                self.setUpExercisesListen(user: user!)
                
                
                
            }
            
        }
       
    }
    
    func cleanup() {
        
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == .exercise || listener.listenerType == .all{
            listener.onExerciseChange(change: .update, userExercises: allExercises)
        }
        if listener.listenerType == .routines || listener.listenerType == .all{
            listener.onRoutineChange(change: .update, routines: allRoutines)
        }
        if listener.listenerType == .routine || listener.listenerType == .all{
            listener.onRoutineExerciseChange(change: .update, routines: selectedRoutine)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    
    func emailLogin(email: String, password: String) {
       
        authController.signIn(withEmail: email, password: password){ authResult, error in
            if let error = error{
                print("Sign in failed \(error)")
                
                return
            }
            guard let user = authResult?.user else{
             
                return
            }
            
            
            
        }
      
    }
    
    func emailCreateAccount(email: String, password: String)  {
        
        authController.createUser(withEmail: email, password: password){
            (authResult, error) in
            if let error = error{
                print("Error creating user: \(error)")
                
                return
            }
            guard let user = authResult?.user else{

                return
            }
            
            self.usersRef?.document(user.uid).setData([
                "email":email
            ]){
                error in
                if let error = error{
                    print("Error inserting using into database \(error)")
                 
                    return
                }
            }
        }
  
    }
    
    func googleSignIn(credential: AuthCredential) {
        authController.signIn(with: credential){authResult, error in
            if let error = error{
                print("Sign in through google failed \(error)")
                return
            }
            guard let user = authResult?.user else{
                return
            }
        }
    }
    
    func AddExerciseToFirebase(exercise: Exercise) -> Exercise {
        exercise.userID = currentUser?.uid
        do{
            if let exerciseRef = try exercisesRef?.addDocument(from: exercise){
                exercise.id = exerciseRef.documentID
                
                allExercises.append(exercise)
                
            }
        } catch {
            print("Failed to add exercise to firestore")
           
           
            
        }
        
        return exercise
        
        
    }
    func deleteExercise(exercise: Exercise) -> Bool {
        if let exerciseID = exercise.id{
            exercisesRef?.document(exerciseID).delete()
            allExercises = allExercises.filter{$0.id != exerciseID}
            return true
            //There needs to be a way to delete this exercise from all routines
        }
        return false
    }
  
    
    func getExerciseByID(_ id: String) -> Exercise?{
       
        for exercise in allExercises{
            if exercise.id == id{
                return exercise
            }
        }
        return nil
    }
    
    func setUpExercisesListen(user: FirebaseAuth.User){
        
        exercisesRef?.whereField("userID",isEqualTo: user.uid).getDocuments{(querySnapshot, error) in
            if let error = error{
                print("Error Retrieving Exercises \(error)")
            }
                
                    else{
                        
                        if querySnapshot!.documents.count > 0 {
                            self.parseExerciseSnapshot(snapshot: (querySnapshot?.documents)!)
                            return
                        }
                        else{
                            print("No Documents Found")
                            return
                        }
                        
                    }
                }
                return
            }
            
            func parseExerciseSnapshot(snapshot: [QueryDocumentSnapshot]) {
                for exercise in snapshot{
                   let retrievedExercises = Exercise()
                    retrievedExercises.name = exercise.data()["name"] as? String
                    retrievedExercises.userID = exercise.data()["userID"] as? String
                    retrievedExercises.isCustom = exercise.data()["isCustom"] as? Bool
                    retrievedExercises.category = exercise.data()["category"] as? String
                    retrievedExercises.instructions = exercise.data()["instructioins"] as? String
                    retrievedExercises.difficulty = exercise.data()["difficulty"] as? String
                    retrievedExercises.id = exercise.documentID
                    allExercises.append(retrievedExercises)
                }
                
                listeners.invoke{(listener) in
                    if listener.listenerType == ListenerType.exercise || listener.listenerType == ListenerType.all{
                        listener.onExerciseChange(change: .update, userExercises: allExercises)
                    }
                }
                setUpRoutineListener(user: currentUser!)
            }
            
            func setUpRoutineListener(user: FirebaseAuth.User){
                routinesRef?.whereField("userID", isEqualTo: currentUser!.uid).getDocuments{(querySnapshot, error) in
                    if let error = error{
                        print("Error Retrieving Teams with Error \(error)")
                    } else{
                        if querySnapshot!.documents.count > 0{
                            self.parseRoutineSnapshot(snapshot: (querySnapshot?.documents)!)
                            return
                        } else{
                            print("No Documents Found")
                            return
                        }
                    }
                }
            }
            
            func parseRoutineSnapshot(snapshot: [QueryDocumentSnapshot]){
                var localRoutine =  [Routine]()
                for routine in snapshot{
                
                    let retrievedRoutine = Routine()
                    retrievedRoutine.name = routine.data()["name"] as? String
                    retrievedRoutine.userID = routine.data()["userID"] as? String
                    retrievedRoutine.id = routine.documentID
                    retrievedRoutine.exercises = []
                    if let exerciseDetailRef = routine.data()["exercises"] as? [[String: Any]]{
                        for exercise in exerciseDetailRef{
                            
                            if let ref = exercise["ref"] as? DocumentReference,
                               let sets = exercise["sets"] as? Int{
                               
                                if let exercise = getExerciseByID(ref.documentID){
                                    
                                    let newExerciseDetail = ExerciseDetails(exercise: exercise, sets: sets)
                                    retrievedRoutine.exercises.append(newExerciseDetail)
                                }
                            }
                            
                        }
                    }
                    
                    
                    localRoutine.append(retrievedRoutine)
                    //Idk ill parse it later
                   
                }
                allRoutines = localRoutine
                listeners.invoke{(listener) in
                    if listener.listenerType == ListenerType.routines || listener.listenerType == ListenerType.all{
                        listener.onRoutineChange(change: .update, routines: allRoutines)
                    }
                }
            }
            
            func addRoutineToFirebase(routine: Routine) -> Bool {
                if currentUser != nil{
                    routine.userID = currentUser?.uid
                }
                if let routineRef = routinesRef?.addDocument(data: [
                    "name": routine.name,
                    "userID" : routine.userID
                ]){
                    routine.id = routineRef.documentID
                    allRoutines.append(routine)
                    return true
                    
                }
                else{
                    print("Error Occured when adding Routine to Firebase")
                    return false
                }
            }
            func addExerciseToRoutine(exercise: Exercise) -> Bool {
                var chosenExercise = exercise
               
                if !exercise.isCustom!{
                    chosenExercise = AddExerciseToFirebase(exercise: exercise)
                }
         
                guard let exerciseID = chosenExercise.id, let routineID = selectedRoutine.id else{
                    return false
                }
                
                if let newExerciseRef = exercisesRef?.document(exerciseID){
                    let exerciseMap: [String:Any] = [
                        "ref": newExerciseRef,
                        "sets": 1
                    ]
            routinesRef?.document(routineID).updateData(["exercises":FieldValue.arrayUnion([exerciseMap])])
            selectedRoutine.exercises.append(ExerciseDetails(exercise: chosenExercise, sets: 1))
        }
        listeners.invoke{(listener) in
            if listener.listenerType == ListenerType.routine || listener.listenerType == ListenerType.all{
                listener.onRoutineExerciseChange(change: .update, routines: selectedRoutine)
            }
        }
        return true
              
    }
    
    
    func selectRoutine(routine: Routine) {
        
        selectedRoutine = routine
        print(selectedRoutine.id)
    }
    
    func removeRoutine(routine: Routine) -> Bool {
        if let routineID = routine.id{
            routinesRef?.document(routineID).delete()
            allRoutines = allRoutines.filter{$0.id != routineID}
            return true
        }
        return false
    }
    func removeExerciseFromRoutine(exercise: Exercise, routine:Routine) -> Bool {
        return true
    }
    
    
    
    
    
    
}
