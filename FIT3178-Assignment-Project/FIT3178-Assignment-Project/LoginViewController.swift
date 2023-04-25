//
//  LoginViewController.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 24/4/2023.
//

import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn
class LoginViewController: UIViewController{
    var authListenerHandler: AuthStateDidChangeListenerHandle?
    let auth = Auth.auth()
    weak var databaseController: DatabaseProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func facebookSignInButton(_ sender: Any) {
    }
    @IBAction func googleSignInButton(_ sender: Any) {
        Task{
            await signInGoogle()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authListenerHandler = auth.addStateDidChangeListener{(auth, user) in
            if user != nil{
                print(user?.email)
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
                
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        auth.removeStateDidChangeListener(authListenerHandler!)
        
    }
    
    
        func signInGoogle() async {
        guard let clientID = FirebaseApp.app()?.options.clientID else{
            fatalError("No Client ID found in Firebase Configuration")
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else{
            print("There is no root view controller")
            return
        }
        do{
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = userAuthentication.user
            guard let idToken = user.idToken else{
                print("ID Token Missing")
                return
            }
            let accessToken = user.accessToken
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            databaseController?.googleSignIn(credential: credential)
            return
            
           
        } catch{
            print(error.localizedDescription)
            return
        }
       
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
