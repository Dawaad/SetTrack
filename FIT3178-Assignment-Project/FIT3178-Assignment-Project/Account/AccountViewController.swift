//
//  AccountViewController.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 25/4/2023.
//

import UIKit
import FirebaseAuth
class AccountViewController: UIViewController {
    var authListenerHandler: AuthStateDidChangeListenerHandle?
    let auth = Auth.auth()
    weak var databaseController: DatabaseProtocol?
    @IBOutlet weak var EmailLabel: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setting up the database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Setting up the Firebase Authentication Listener
        authListenerHandler = auth.addStateDidChangeListener{
            (auth,user) in
            if user != nil{
                self.EmailLabel.setTitle(user?.email, for: .normal)
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        auth.removeStateDidChangeListener(authListenerHandler!)
    }
    
    @IBAction func accountSignOut(_ sender: Any) {
        do{
            //Calling the signout method from the database controller
            try databaseController?.signOut()
            performSegue(withIdentifier: "signOutSegue", sender: nil)
          
        } catch let error as NSError{
            print("Error signing out: %@", error.localizedDescription)
            displayMessage("Error signing out", "There was an error when attempting to sign out")
        }
    }
    
    
    
    
    func displayMessage(_ title:String, _ message:String){
        let alertControlller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertControlller.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        self.present(alertControlller, animated: true, completion: nil
        )
    }
     // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "signOutSegue"{
            if let destination = segue.destination as? LoginViewController{
                destination.navigationItem.hidesBackButton = true
                
                
            }
        }
    }
    

}
