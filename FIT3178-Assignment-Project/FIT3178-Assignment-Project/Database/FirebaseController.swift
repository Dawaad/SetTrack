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
import CoreData
class FirebaseController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate{
    
    
   
    
    
    
       
    var selectedRoutine: Routine
    var database: Firestore
    var authController: Auth
    var usersRef: CollectionReference?
    var exercisesRef: CollectionReference?
    var routinesRef: CollectionReference?
    var sessionRef: CollectionReference?
    var listeners = MulticastDelegate<DatabaseListener>()
    var currentUser: FirebaseAuth.User?
//    var authListenerHandler: AuthStateDidChangeListenerHandle?
    var activeSession: Session?
    var allExercises: [Exercise] = [Exercise]()
    var allRoutines: [Routine] = [Routine]()
    var allSessions: [Session] = [Session]()
    var persistantContainer: NSPersistentContainer
    var activeSesssionContainer: NSFetchedResultsController<CoreSession>?
    
    override init() {
        
        FirebaseApp.configure()
        selectedRoutine = Routine()
        authController = Auth.auth()
        database = Firestore.firestore()
        usersRef = database.collection("users")
        exercisesRef = database.collection("exercises")
        routinesRef = database.collection("routines")
        sessionRef = database.collection("sessions")
        
        persistantContainer = NSPersistentContainer(name: "contents")
        persistantContainer.loadPersistentStores(){(description, error) in
            if let error = error{
                fatalError("Failed to load Core Data Stack with error: \(error)")
            }
            
            
        }
        super.init()
        
        let authListenerHandler = authController.addStateDidChangeListener{
            (_,user) in
            if user != nil{
                self.currentUser = user!
                
                self.setUpExercisesListen(user: user!)
                
                
                
            }
            
        }
       
    }
    
    func cleanup() {
        if persistantContainer.viewContext.hasChanges{
            do {
                try persistantContainer.viewContext.save()
                
            } catch {
                fatalError("Failed to save changes to Core Data with error \(error)")
            }
        }
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
        if listener.listenerType == .sessions || listener.listenerType == .all{
            listener.onSessionSubmision(change: .update, sessions: allSessions)
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
                setUpSessionListener(user: currentUser!)
            }
            
            func setUpRoutineListener(user: FirebaseAuth.User){
                routinesRef?.whereField("userID", isEqualTo: currentUser!.uid).getDocuments{(querySnapshot, error) in
                    if let error = error{
                        print("Error Retrieving Routines with Error \(error)")
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
    
   
    
    func routineToSession(routine: Routine) -> Session{
        var newSession = Session()
        newSession.name = routine.name
        newSession.routineID = routine.id
        newSession.userID = routine.userID
        newSession.startDateTime = Date()
        
        
        
        newSession.exercises = routine.exercises.map { SessionExercise(exercise: $0.exercise, sets: $0.sets, performance: (0..<$0.sets).map { _ in
                return SetRepWeight( rep: 0, weight: 0, restTime: 0)}  )}
            
        return newSession
    }
    
    func setActiveSession(){
        let coreSession = fetchStoredSessionFromCoreData()
        activeSession = transformFromCoreData(coreSession: coreSession!)
    }
    


    func saveSessionToCoreData(session: Session) {
        
        let managedObjectContext = persistantContainer.viewContext
        
        // Check if there is an existing session stored in Core Data
        if let existingSession = fetchStoredSessionFromCoreData() {
            deleteSessionFromCoreData(session: existingSession)
        }
        
        let coreSession = transformToCoreData(session: session, managedObjectContext: managedObjectContext)
        
        do {
            try managedObjectContext.save()
           
            print("Session saved to Core Data successfully")
        } catch {
            print("Failed to save session to Core Data: \(error)")
        }
        setActiveSession()
    }

    func fetchStoredSessionFromCoreData() -> CoreSession? {
        
        let managedObjectContext = persistantContainer.viewContext
        
        let fetchRequest: NSFetchRequest<CoreSession> = CoreSession.fetchRequest()
        
        do {
            let sessions = try managedObjectContext.fetch(fetchRequest)
            return sessions.first
        } catch {
            print("Failed to fetch stored session from Core Data: \(error)")
            return nil
        }
    }

    func deleteSessionFromCoreData(session: CoreSession) {
        
        let managedObjectContext = persistantContainer.viewContext
        
        managedObjectContext.delete(session)
        
        do {
            try managedObjectContext.save()
            print("Existing session deleted from Core Data successfully")
        } catch {
            print("Failed to delete existing session from Core Data: \(error)")
        }
    }


    
 

    func transformToCoreData(session: Session, managedObjectContext: NSManagedObjectContext) -> CoreSession {
        let coreSession = CoreSession(context: managedObjectContext)
        // Set the properties of coreSession using values from session
        coreSession.id = session.id
        coreSession.routineID = session.routineID
        coreSession.name = session.name
        coreSession.userID = session.userID
        coreSession.startDateTime = session.startDateTime
        coreSession.endDateTime = session.endDateTime

        // Transform session exercises into coreSessionExercises
        if let sessionExercises = session.exercises {
            var coreSessionExercises = [CoreSessionExercise]()
            for sessionExercise in sessionExercises {
                let coreExercise = transformToCoreExercise(exercise: sessionExercise.exercise, managedObjectContext: managedObjectContext)
                let coreSessionExercise = CoreSessionExercise(context: managedObjectContext)
                coreSessionExercise.exercise = coreExercise
                coreSessionExercise.sets = Int16(sessionExercise.sets)
                coreSessionExercise.performance = transformToCoreSetRepWeights(setRepWeights: sessionExercise.performance, managedObjectContext: managedObjectContext)

                coreSessionExercises.append(coreSessionExercise)
            }
            coreSession.exercises = NSSet(array: coreSessionExercises)
        }

        return coreSession
    }
    
    func transformToCoreExercise(exercise: Exercise, managedObjectContext: NSManagedObjectContext) -> CoreExercise {
        let coreExercise = CoreExercise(context: managedObjectContext)
        // Set the properties of coreExercise using values from exercise
        coreExercise.id = exercise.id
        coreExercise.name = exercise.name
        coreExercise.isCustom = exercise.isCustom ?? false
        coreExercise.userID = exercise.userID
        coreExercise.instructions = exercise.instructions
        coreExercise.difficulty = exercise.difficulty
        coreExercise.category = exercise.category

        return coreExercise
    }
    
    func transformToCoreSetRepWeights(setRepWeights: [SetRepWeight], managedObjectContext: NSManagedObjectContext) -> NSSet {
        let coreSetRepWeights = setRepWeights.map { setRepWeight in
            let coreSetRepWeight = CoreSetRepWeight(context: managedObjectContext)
            coreSetRepWeight.rep = Int16(setRepWeight.rep)
            coreSetRepWeight.weight = Int16(setRepWeight.weight)
            return coreSetRepWeight
        }
        return NSSet(array: coreSetRepWeights)
    }
    
 

    func transformFromCoreData(coreSession: CoreSession) -> Session {
        var session = Session()
        session.id = coreSession.id
        session.name = coreSession.name
        session.routineID = coreSession.routineID
        session.userID = coreSession.userID
        session.startDateTime = coreSession.startDateTime
        session.endDateTime = coreSession.endDateTime
        
        if let coreExercises = coreSession.exercises as? Set<CoreSessionExercise> {
            var sessionExercises: [SessionExercise] = []
            
            for coreExercise in coreExercises {
                let exercise = Exercise()
                exercise.id = coreExercise.exercise?.id
                exercise.name = coreExercise.exercise?.name
                exercise.isCustom = coreExercise.exercise?.isCustom
                exercise.userID = coreExercise.exercise?.userID
                exercise.instructions = coreExercise.exercise?.instructions
                exercise.difficulty = coreExercise.exercise?.difficulty
                exercise.category = coreExercise.exercise?.category
                
                let sessionExercise = SessionExercise(
                    exercise: exercise,
                    sets: Int(coreExercise.sets),
                    performance: transformPerformanceFromCoreData(corePerformance: coreExercise.performance)
                )
                
                sessionExercises.append(sessionExercise)
            }
            
            session.exercises = sessionExercises
        }
        
        return session
    }
    
    func setUpSessionListener(user: FirebaseAuth.User) {
        
        sessionRef?.whereField("userID", isEqualTo: currentUser!.uid).getDocuments{(querySnapshot, error) in
            if let error = error{
                print("Error parsing sessions with error \(error)")
                
            } else{
                if querySnapshot!.documents.count > 0{
                   
                    self.parseSessionSnapshot(snapshot: querySnapshot!.documents)
                    return
                } else{
                    print("No documents found")
                    return
                }
            }
        }
        
    }

    
    func parseSessionSnapshot(snapshot: [QueryDocumentSnapshot]){
        
        var localSession = [Session]()
        
        for session in snapshot{
            let retrievedSession = Session()
            retrievedSession.name = session.data()["name"] as? String
            retrievedSession.routineID = session.data()["routineID"] as? String
            retrievedSession.userID = session.data()["userID"] as? String
            retrievedSession.startDateTime = session.data()["startDateTime"] as? Date
            retrievedSession.endDateTime = session.data()["endDateTime"] as? Date
            
            
            
            retrievedSession.exercises = []
            if let sessionExerciseData = session.data()["exercises"] as? [[String: Any]]{
                for sessionExercise in sessionExerciseData{
                    var sets = sessionExercise["sets"] as! Int
                    var exerciseObject = sessionExercise["exercise"] as? AnyObject
                    var id = exerciseObject?.value(forKey: "id") as! String
                    var exercise = getExerciseByID(id)
                    var performanceArr: [SetRepWeight] = []
                    var performanceData = sessionExercise["performance"] as! [AnyObject]
                    for performance in performanceData{
                        var rep = performance.value(forKey: "rep") as! Int
                        var weight = performance.value(forKey: "weight") as! Int
                        var restTime = performance.value(forKey: "restTime") as! Int
                        var data = SetRepWeight(rep: rep, weight: weight, restTime: restTime)
                        performanceArr.append(data)
                    }
                  
                    retrievedSession.exercises?.append(SessionExercise(exercise: exercise!, sets: sets, performance: performanceArr))
                }
                
            }
         
            localSession.append(retrievedSession)
            
        }
        allSessions = localSession
        print(allSessions)
        listeners.invoke{(listener) in
            if listener.listenerType == .sessions || listener.listenerType == ListenerType.all{
                listener.onSessionSubmision(change: .update, sessions: allSessions)
            }
        }
        
        
        
        
    }



    func transformPerformanceFromCoreData(corePerformance: NSSet?) -> [SetRepWeight] {
        guard let corePerformance = corePerformance else {
            return []
        }
        
        var performance: [SetRepWeight] = []
        
        for case let coreSetRepWeight as CoreSetRepWeight in corePerformance {
            let setRepWeight = SetRepWeight(rep: Int(coreSetRepWeight.rep), weight: Int(coreSetRepWeight.weight), restTime: Int(coreSetRepWeight.restTime))
            performance.append(setRepWeight)
        }
        
        return performance
    }
    
    func updateSetReps(reps: Int, exerciseID: String, setNum: Int) {
        guard let session = fetchStoredSessionFromCoreData() else {
               print("Session not found.")
               return
           }
           
           // Locate the specific SessionExercise within the session
           guard let exercise = session.exercises?.first(where: { ($0 as? CoreSessionExercise)?.exercise?.id == exerciseID }) as? CoreSessionExercise else {
               print("Exercise not found in the session.")
               return
           }
           
        // Convert performance from NSSet to Array
           guard let performance = exercise.performance?.allObjects as? [CoreSetRepWeight] else {
               print("Failed to access performance.")
               return
           }
           
           // Update the SetRepWeight for the desired set
           guard setNum < performance.count else {
               print("Invalid set index.")
               return
           }
           
           let setRepWeight = performance[setNum]
           setRepWeight.rep = Int16(reps)
           
           // Save the changes to Core Data
           do {
               try persistantContainer.viewContext.save()
               print("Rep count updated successfully.")
           } catch {
               print("Failed to save changes: \(error.localizedDescription)")
           }
        
        
    }
    func updateSetRest(rest: Int, exerciseID: String, setNum: Int) {
        guard let session = fetchStoredSessionFromCoreData() else {
               print("Session not found.")
               return
           }
           
           // Locate the specific SessionExercise within the session
           guard let exercise = session.exercises?.first(where: { ($0 as? CoreSessionExercise)?.exercise?.id == exerciseID }) as? CoreSessionExercise else {
               print("Exercise not found in the session.")
               return
           }
           
        // Convert performance from NSSet to Array
           guard let performance = exercise.performance?.allObjects as? [CoreSetRepWeight] else {
               print("Failed to access performance.")
               return
           }
           
           // Update the SetRepWeight for the desired set
           guard setNum < performance.count else {
               print("Invalid set index.")
               return
           }
           
           let setRepWeight = performance[setNum]
           setRepWeight.restTime = Int16(rest)
           
           // Save the changes to Core Data
           do {
               try persistantContainer.viewContext.save()
               print("Rest time updated successfully.")
           } catch {
               print("Failed to save changes: \(error.localizedDescription)")
           }
    }
    func updateSetWeight(weight: Int, exerciseID: String, setNum: Int) {
        guard let session = fetchStoredSessionFromCoreData() else {
               print("Session not found.")
               return
           }
           
           // Locate the specific SessionExercise within the session
           guard let exercise = session.exercises?.first(where: { ($0 as? CoreSessionExercise)?.exercise?.id == exerciseID }) as? CoreSessionExercise else {
               print("Exercise not found in the session.")
               return
           }
           
        // Convert performance from NSSet to Array
           guard let performance = exercise.performance?.allObjects as? [CoreSetRepWeight] else {
               print("Failed to access performance.")
               return
           }
           
           // Update the SetRepWeight for the desired set
           guard setNum < performance.count else {
               print("Invalid set index.")
               return
           }
           
           let setRepWeight = performance[setNum]
           setRepWeight.weight = Int16(weight)
           
           // Save the changes to Core Data
           do {
               try persistantContainer.viewContext.save()
               print("Weight updated successfully.")
           } catch {
               print("Failed to save changes: \(error.localizedDescription)")
           }
    }
    
    func addSesssionToFirebase() {
        let coreSession = fetchStoredSessionFromCoreData()!
        let session = transformFromCoreData(coreSession: coreSession)
        session.endDateTime = Date()
        deleteSessionFromCoreData(session: coreSession)
        do {
            let documentData = try Firestore.Encoder().encode(session)
            sessionRef?.addDocument(data: documentData) {error in
                if let error = error{
                    print("Unable to store session with error \(error)")
                }
            } 
        }catch {
            print("Error encoding session: \(error.localizedDescription)")
        }
        
    }
    





    
    
    
    
    
    
}
