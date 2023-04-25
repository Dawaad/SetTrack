//
//  FirebaseController.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 24/4/2023.
//

import Foundation

import FirebaseFirestoreSwift
import Firebase

class FirebaseController: NSObject, DatabaseProtocol{
   
    
    var database: Firestore
    var authController: Auth
    var usersRef: CollectionReference?
    var listeners = MulticastDelegate<DatabaseListener>()
    
    
    override init() {
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        usersRef = database.collection("users")
        super.init()
    }
    
    func cleanup() {
        
    }
    
    func addListener(listener: DatabaseListener) {
        
    }
    
    func removeListener(listener: DatabaseListener) {
        
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
}
