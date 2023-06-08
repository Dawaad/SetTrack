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

    
    
    
    
    
    
    
    
    
    
    var selectedRoutine: Routine?
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
    var statRoutine: Routine?
    var statExercise: Exercise?
    
    override init() {
        //Setting up all base variables used within the controller
        FirebaseApp.configure()
        selectedRoutine = Routine()
        authController = Auth.auth()
        database = Firestore.firestore()
        usersRef = database.collection("users")
        exercisesRef = database.collection("exercises")
        routinesRef = database.collection("routines")
        sessionRef = database.collection("sessions")
        
        
        //Setting up the Core Data Session Storage using the predefined Datamodel
        persistantContainer = NSPersistentContainer(name: "contents")
        persistantContainer.loadPersistentStores(){(description, error) in
            if let error = error{
                fatalError("Failed to load Core Data Stack with error: \(error)")
            }
            
            
        }
        super.init()
        //Calling the Firebase Authentication Listener to set up the current user
        let authListenerHandler = authController.addStateDidChangeListener{
            (_,user) in
            if user != nil{
                self.currentUser = user!
                
                self.setUpExercisesListen(user: user!)
                
                
                
            }
            
        }
        
    }
    
    func cleanup() {
        //Perform clean up methods to the Core Storage Session
        if persistantContainer.viewContext.hasChanges{
            do {
                try persistantContainer.viewContext.save()
                
            } catch {
                fatalError("Failed to save changes to Core Data with error \(error)")
            }
        }
    }
    
    func addListener(listener: DatabaseListener) {
        //Adding the correct method to each of the Database listeners
        listeners.addDelegate(listener)
        if listener.listenerType == .exercise || listener.listenerType == .all{
            listener.onExerciseChange(change: .update, userExercises: allExercises)
        }
        if listener.listenerType == .routines || listener.listenerType == .all{
            listener.onRoutineChange(change: .update, routines: allRoutines)
        }
        if listener.listenerType == .routine || listener.listenerType == .all{
            listener.onRoutineExerciseChange(change: .update, routines: selectedRoutine!)
        }
        if listener.listenerType == .sessions || listener.listenerType == .all{
            listener.onSessionSubmision(change: .update, sessions: allSessions)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    
    
    func emailLogin(email: String, password: String) {
        //Using the FireAuth signin method to provide authentication
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
        //Providing Fireauth with credentials to create a new user account
        authController.createUser(withEmail: email, password: password){
            (authResult, error) in
            if let error = error{
                print("Error creating user: \(error)")
                
                return
            }
            guard let user = authResult?.user else{
                
                return
            }
            //Add the email data to the user collection and its associated user id
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
            //Creating a document from the exercise object and storing it in firebase
            if let exerciseRef = try exercisesRef?.addDocument(from: exercise){
                //Assigning the generated firebase id to the exercise object
                exercise.id = exerciseRef.documentID
                //Adding it to the listener array
                allExercises.append(exercise)
                
            }
        } catch {
            print("Failed to add exercise to firestore")
            
            
            
        }
        
        return exercise
        
        
    }
    func deleteExercise(exercise: Exercise) -> Bool {
        if let exerciseID = exercise.id{
            //Deleting exercise ID from firebase
            exercisesRef?.document(exerciseID).delete()
            //Removing the exercise from the listener array
            allExercises = allExercises.filter{$0.id != exerciseID}
            return true
          
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
        //Retrieving all exercises from the collection where the UserID is equal to the current user
        exercisesRef?.whereField("userID",isEqualTo: user.uid).getDocuments{(querySnapshot, error) in
            if let error = error{
                print("Error Retrieving Exercises \(error)")
            }
            
            else{
                //If there are any found exercises  from the collection
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
            /*
             Parse the data collected from each document into the correct
             format to generate a new exercise object, matching that from Firebase
             */
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
        //Invoke the listeners to access the array of exercises
        listeners.invoke{(listener) in
            if listener.listenerType == ListenerType.exercise || listener.listenerType == ListenerType.all{
                listener.onExerciseChange(change: .update, userExercises: allExercises)
            }
        }
        /*
         Once all exercises have been parsed, continue to parse all routines and sessions
         */
        setUpRoutineListener(user: currentUser!)
        setUpSessionListener(user: currentUser!)
    }
    
    func setUpRoutineListener(user: FirebaseAuth.User){
        //Find all routines in the collection in which the userID field matches that of the current user
        routinesRef?.whereField("userID", isEqualTo: currentUser!.uid).getDocuments{(querySnapshot, error) in
            if let error = error{
                print("Error Retrieving Routines with Error \(error)")
            } else{
                //Parse the routines found that were generated by the current user
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
        //Generate a new Routine Array
        var localRoutine =  [Routine]()
        for routine in snapshot{
            //Parse the data collected from firebase into a Routine object
            let retrievedRoutine = Routine()
            retrievedRoutine.name = routine.data()["name"] as? String
            retrievedRoutine.userID = routine.data()["userID"] as? String
            retrievedRoutine.id = routine.documentID
            /* Parse through each element within the map and insert it into the
             routine exercise array */
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
        //Add a new document to the Routine Collection and set it up with name and UID
        if let routineRef = routinesRef?.addDocument(data: [
            "name": routine.name,
            "userID" : routine.userID
        ]){
            //Assign the generated id from firebase to the routine object
            routine.id = routineRef.documentID
            allRoutines.append(routine)
            return true
            
        }
        else{
            print("Error Occured when adding Routine to Firebase")
            return false
        }
    }
    func addExerciseToRoutine(exercise: Exercise, set:Int) -> Bool {
        var chosenExercise = exercise
        //Check to see if the same exercise, and its ID already exist within the array
        var chkDupe = selectedRoutine?.exercises.filter{$0.exercise.id == exercise.id}
        
        
        //If there are no dupes, continue
        if chkDupe?.count == 0{
            
        /* If the exercise was retrieved from the API, we must add it to firebase
         so it can be reparsed in the future */
        if !exercise.isCustom!{
            chosenExercise = AddExerciseToFirebase(exercise: exercise)
        }
        
        guard let exerciseID = chosenExercise.id, let routineID = selectedRoutine!.id else{
            return false
        }
        
        //Create a new reference to the exercise from within the exercise collection
        if let newExerciseRef = exercisesRef?.document(exerciseID){
            let exerciseMap: [String:Any] = [
                "ref": newExerciseRef,
                "sets": 1
            ]
            //Create a new map containing a default number of sets, and insert it into the exercise array
            routinesRef?.document(routineID).updateData(["exercises":FieldValue.arrayUnion([exerciseMap])])
            //Append it to the routines exercise array
            selectedRoutine!.exercises.append(ExerciseDetails(exercise: chosenExercise, sets: set))
        }
        listeners.invoke{(listener) in
            if listener.listenerType == ListenerType.routine || listener.listenerType == ListenerType.all{
                listener.onRoutineExerciseChange(change: .update, routines: selectedRoutine!)
            }
        }
        return true
        }
        return false
        
    }
    func removeExerciseFromRoutine(exercise: ExerciseDetails, routine:Routine) -> Bool {
        //Create a map that contains the current data of the exercise, including current sets
        if let deletedExerciseRef = exercisesRef?.document(exercise.exercise.id!){
            let deletedExerciseMap: [String:Any] = [
                "ref": deletedExerciseRef,
                "sets": exercise.sets
            ]
            //Remove the exact same map from within the exercise array within the routine document
            routinesRef?.document(selectedRoutine!.id!).updateData(["exercises": FieldValue.arrayRemove([deletedExerciseMap])])
            //Filter the exercise out of the routines exercise array
            selectedRoutine!.exercises =  selectedRoutine!.exercises.filter{ $0.exercise.id != exercise.exercise.id}
            
            //Invoke the listener, so that it is aware of the changes made to the routine
            listeners.invoke{(listener) in
                if listener.listenerType == ListenerType.routine || listener.listenerType == ListenerType.all{
                    listener.onRoutineExerciseChange(change: .update, routines: selectedRoutine!)
                }
            }
            return true
        }
        
        return false
    }
    
    func signOut() -> Bool {
        //Try Fireauth Signout function
        do{
            try authController.signOut()
        }
        catch let error as NSError{
            print("Unable to sign out with \(error)")
            return false
        }
        /* Clear all variables that were tied to the current user, just in case
         another user signs in as still holds information from the previous user
         */
        selectedRoutine = nil
        activeSession = nil
        allExercises = []
        allRoutines = []
        allSessions = []
        return true
        
    }
    
    func updateExerciseSetCountInRoutine(exercise: ExerciseDetails, set: Int, routine: Routine) -> Bool{
        //Delete the current map from the exercise array within firebase
        if let deletedExerciseRef = exercisesRef?.document(exercise.exercise.id!){
            let deletedExerciseMap: [String:Any] = [
                "ref": deletedExerciseRef,
                "sets": exercise.sets
            ]
            
            routinesRef?.document(selectedRoutine!.id!).updateData(["exercises": FieldValue.arrayRemove([deletedExerciseMap])])
        }
            
            //Insert a new map into the array, within the update number of sets
            if let newExerciseRef = exercisesRef?.document(exercise.exercise.id!){
                let exerciseMap: [String:Any] = [
                    "ref": newExerciseRef,
                    "sets": set
                ]
                routinesRef?.document(selectedRoutine!.id!).updateData(["exercises":FieldValue.arrayUnion([exerciseMap])])

            }
            //Ensure the current routine is up to date with the changes
            listeners.invoke{(listener) in
                if listener.listenerType == ListenerType.routine || listener.listenerType == ListenerType.all{
                    listener.onRoutineExerciseChange(change: .update, routines: selectedRoutine!)
                }
            }
        


        return true

    }
    
    
    func selectRoutine(routine: Routine) {
        //Change the selected routine to the new routine,
        selectedRoutine = routine
       
    }
    
    func removeRoutine(routine: Routine) -> Bool {
        
        if let routineID = routine.id{
            //Remove the routine from the Routine collection using its ID
            routinesRef?.document(routineID).delete()
            //Filter out the routine from the routine array
            allRoutines = allRoutines.filter{$0.id != routineID}
            return true
        }
        return false
    }
   
    
   
    
    func routineToSession(routine: Routine) -> Session{
        //Create a new session object
        var newSession = Session()
        //Parse base routine information into the session
        newSession.name = routine.name
        newSession.routineID = routine.id
        newSession.userID = routine.userID
        newSession.startDateTime = Date()
        
        
        //For each exercise, format it into a Session Exercise Object,
        newSession.exercises = routine.exercises.map { SessionExercise(exercise: $0.exercise, sets: $0.sets, performance: (0..<$0.sets).map { _ in
                //For each number of sets, append to the array a new SetWeight Object with default values
                return SetRepWeight( rep: 0, weight: 0, restTime: 0)}  )}
            
        return newSession
    }
    
    func setActiveSession(){
        //Retrieve the session from coredata
        let coreSession = fetchStoredSessionFromCoreData()
        //transform this into a regular session object and update within the controller
        activeSession = transformFromCoreData(coreSession: coreSession!)
    }
    


    func saveSessionToCoreData(session: Session) {
        //Retrieve the Core Data Session
        let managedObjectContext = persistantContainer.viewContext
        
        // Check if there is an existing session stored in Core Data
        if let existingSession = fetchStoredSessionFromCoreData() {
            deleteSessionFromCoreData(session: existingSession)
        }
        //Transform the session object into a core data supported session object
        let coreSession = transformToCoreData(session: session, managedObjectContext: managedObjectContext)
        
        do {
            //Save the session to core data
            try managedObjectContext.save()
           
            print("Session saved to Core Data successfully")
        } catch {
            print("Failed to save session to Core Data: \(error)")
        }
        setActiveSession()
    }

    func fetchStoredSessionFromCoreData() -> CoreSession? {
        //Retrieve the Core Data Session
        let managedObjectContext = persistantContainer.viewContext
        //Create a fetch request
        let fetchRequest: NSFetchRequest<CoreSession> = CoreSession.fetchRequest()
        
        do {
            let sessions = try managedObjectContext.fetch(fetchRequest)
            //Retrieve the first session, as only one session is stored at any time
            return sessions.first
        } catch {
            print("Failed to fetch stored session from Core Data: \(error)")
            return nil
        }
    }

    func deleteSessionFromCoreData(session: CoreSession) {
        //Retrieve the Core Data Session
        let managedObjectContext = persistantContainer.viewContext
        //Delete the session from core data
        managedObjectContext.delete(session)
        
        do {
            //Save the session to ensure that the session is fully removed
            try managedObjectContext.save()
            print("Existing session deleted from Core Data successfully")
        } catch {
            print("Failed to delete existing session from Core Data: \(error)")
        }
    }


    
 

    func transformToCoreData(session: Session, managedObjectContext: NSManagedObjectContext) -> CoreSession {
        //Create a new Core Data supported Session Object =
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
        //Create a new blank sesssion object
        var session = Session()
        session.id = coreSession.id
        session.name = coreSession.name
        session.routineID = coreSession.routineID
        session.userID = coreSession.userID
        session.startDateTime = coreSession.startDateTime
        session.endDateTime = coreSession.endDateTime
        //Parse through all core data arrays (ie. Sets) and transform back into SessionExercise Object
        if let coreExercises = coreSession.exercises as? Set<CoreSessionExercise> {
            var sessionExercises: [SessionExercise] = []
            
            for coreExercise in coreExercises {
                //Parse through all basic information
                let exercise = Exercise()
                exercise.id = coreExercise.exercise?.id
                exercise.name = coreExercise.exercise?.name
                exercise.isCustom = coreExercise.exercise?.isCustom
                exercise.userID = coreExercise.exercise?.userID
                exercise.instructions = coreExercise.exercise?.instructions
                exercise.difficulty = coreExercise.exercise?.difficulty
                exercise.category = coreExercise.exercise?.category
                
                let sessionExercise = SessionExercise(
                    //Transform back into Session Exercise
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
        //Find all sessions created by the current user, using their userID
        sessionRef?.whereField("userID", isEqualTo: currentUser!.uid).getDocuments{(querySnapshot, error) in
            if let error = error{
                print("Error parsing sessions with error \(error)")
                
            } else{
                //If any sessions are found, parse them from firebase
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
        //Create a blank array
        var localSession = [Session]()
        //Parse each session from the snapshot
        for session in snapshot{
            let retrievedSession = Session()
            retrievedSession.name = session.data()["name"] as? String
            retrievedSession.routineID = session.data()["routineID"] as? String
            retrievedSession.id = session.documentID
            retrievedSession.userID = session.data()["userID"] as? String
            var sd = session.data()["startDateTime"] as? Timestamp
            //Convert Timestamps back into usable dates
            retrievedSession.startDateTime = NSDate(timeIntervalSince1970: Double(sd!.seconds)) as! Date
            
            var ed = session.data()["endDateTime"] as? Timestamp
            retrievedSession.endDateTime = NSDate(timeIntervalSince1970: Double(ed!.seconds)) as! Date
            


            //Iterate through each retrieved exercise and convert it back into its original object
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
        
        listeners.invoke{(listener) in
            if listener.listenerType == .sessions || listener.listenerType == ListenerType.all{
                listener.onSessionSubmision(change: .update, sessions: allSessions)
            }
        }
        
        
        
        
    }


    //Transforming back from coredata
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
        //Retrieve session from Core Data
        let coreSession = fetchStoredSessionFromCoreData()!
        //Transform back into useable session object and add end date
        let session = transformFromCoreData(coreSession: coreSession)
        session.endDateTime = Date()
        
        deleteSessionFromCoreData(session: coreSession)
        do {
            //Encode the session and add it to Firebase
            let documentData = try Firestore.Encoder().encode(session)
            sessionRef?.addDocument(data: documentData) {error in
                if let error = error{
                    print("Unable to store session with error \(error)")
                }
            } 
        }catch {
            print("Error encoding session: \(error.localizedDescription)")
        }
        allSessions.append(session)
        
    }
    
    func setStatRoutine(routine: Routine) {
        statRoutine = routine
    }
    
    func setStatExercise(exercise: Exercise) {
        statExercise = exercise
    }
    
    func retrieveDataForGraph(routine: Routine, exercise: Exercise) -> [Int] {
        
        var routineSessions = [Session]()
        var sessionExercises = [SessionExercise]()
        var performanceINFO = [Int]()
        /* Filter out the sessions array to retrieve only the sessions with the specified Routine
         ID, and then sorted from earliest to latest in terms of end date*/
        routineSessions = allSessions.filter{$0.routineID == statRoutine!.id}.sorted{$0.endDateTime! < $1.endDateTime!}
        //Retrieve the selected exercise from within each session
        for session in routineSessions{
            var filterExercise = session.exercises!.filter{$0.exercise.id == statExercise!.id}
            if filterExercise.count>0{
                sessionExercises.append(filterExercise[0])
            }
          
            
        }
        /* For each exercise, calculate the average volume and append it to the performance array*/
        for exercise in sessionExercises {
            performanceINFO.append(calculateAveragePerformance(repWeight: exercise.performance))
        }
        
        return performanceINFO
        
    }
    
    func calculateAveragePerformance(repWeight: [SetRepWeight]) -> Int{
        var volume:Int = 0
        var count:Int = repWeight.count
        for set in repWeight{
            volume += (set.weight * set.rep)
        }
      
        return volume/count
    }
    





    
    
    
    
    
    
}
