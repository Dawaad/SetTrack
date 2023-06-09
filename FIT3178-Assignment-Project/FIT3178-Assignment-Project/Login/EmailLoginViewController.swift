//
//  EmailLoginViewController.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 24/4/2023.
//

import UIKit
import FirebaseAuth
class EmailLoginViewController: UIViewController {
    
    
    weak var databaseController: DatabaseProtocol?

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    var authListenerHandler: AuthStateDidChangeListenerHandle?
    let auth = Auth.auth()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logIn(_ sender: Any) {
        if !validateUserInfo(){
            return
        }
        //Call the controller to sign into FireAuth
        databaseController?.emailLogin(email: emailTextField.text!, password: passwordTextField.text!)

    }
    
    @IBAction func createAccount(_ sender: Any) {
        if !validateUserInfo(){
            return
        }
        //Call the controller to create account and to sign into FireAuth
        databaseController?.emailCreateAccount(email: emailTextField.text!, password: passwordTextField.text!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authListenerHandler = auth.addStateDidChangeListener{(auth, user) in
            if user != nil{
                self.navigationController?.popViewController(animated: animated)
                
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        auth.removeStateDidChangeListener(authListenerHandler!)
        
    }
    
    func validateUserInfo() -> Bool{
        guard let email = emailTextField.text, let password = passwordTextField.text else{
            return false
        }
        if password.isEmpty{
            displayMessage("Invalid Password", "Password must not be empty")
            return false
            
        }
        //Setting up email regex to ensure that a valid email contains xxxx@xxxx.xxx
        let emailRegex = /(.+)@(.+)[.](.*)/
        if email.isEmpty || email.firstMatch(of: emailRegex) == nil{
            displayMessage("Invalid Email", "Please input a valid email")
            return false
         
            
        }
        
        return true
        
    }
    
    func displayMessage(_ title:String, _ message:String){
        let alertControlller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertControlller.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        self.present(alertControlller, animated: true, completion: nil
        )
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
