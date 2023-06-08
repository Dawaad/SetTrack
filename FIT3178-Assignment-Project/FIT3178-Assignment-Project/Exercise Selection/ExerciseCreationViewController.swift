//
//  ExerciseCreationViewController.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 25/4/2023.
//

import UIKit
import FirebaseAuth
class ExerciseCreationViewController: UIViewController, DifficultyChangeDelegate, CategoryChangeDelegate {
   
    var category: String?
    var authListenerHandler: AuthStateDidChangeListenerHandle?
    let auth = Auth.auth()
    weak var databaseController: DatabaseProtocol?
    var difficulty: String?
    var currentUserID: String?
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var difficultyLabel: UILabel!
    

    
    @IBOutlet weak var instructionsTextView: UITextView!
    func selectDifficulty(_ selectedDifficulty: String) {
        difficulty = selectedDifficulty
        difficultyLabel.text = difficulty!.capitalized
    }
    
    func selectCategory(_ selectedCategory: String) {
        category = selectedCategory.replacingOccurrences(of: " ", with: "_").lowercased()
        categoryLabel.text = selectedCategory
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        authListenerHandler = auth.addStateDidChangeListener{(auth, user) in
            if user != nil{
                self.currentUserID = user?.uid
                
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func addExercise(_ sender: Any) {
       
        
        
        
        guard let name = nameTextField.text, let instructions = instructionsTextView.text, let difficulty = difficulty, let category = category else{
            displayMessage("Empty Fields", "Please ensure all fields are filled out")
            return
        }
        if !validateExerciseInformation(name: name, instructions: instructions){
            return
        }
        
        let newExercise = Exercise()
        newExercise.name = name
        newExercise.category = category
        newExercise.instructions = instructions
        newExercise.isCustom = true
        newExercise.difficulty = difficulty
        newExercise.userID = currentUserID ?? " "
        
        databaseController?.AddExerciseToFirebase(exercise: newExercise)
        
        navigationController?.popViewController(animated: true)
        
    }
    func validateExerciseInformation(name: String, instructions: String) -> Bool{
        
        if name.isEmpty || instructions.isEmpty {

            displayMessage("Empty Fields", "Please ensure all fields are filled out")
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
    
    
    @IBAction func chooseCategory(_ sender: Any) {
        performSegue(withIdentifier: "pickCategorySegue", sender: sender)
    }
    
    @IBAction func chooseDifficulty(_ sender: Any) {
        performSegue(withIdentifier: "pickDifficultySegue", sender: sender)
    }
    
    override func viewDidLoad() {
        
//        nameTextField.clipsToBounds = true
//        nameTextField.layer.cornerRadius = 20
//        nameTextField.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        let appDelegate = UIApplication.shared.delegate as?
            AppDelegate
        databaseController = appDelegate?.databaseController

        

        
        
        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
           view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "pickCategorySegue"{
            let destination = segue.destination as! ChooseCategoryTableViewController
            destination.delegate = self
        }
        else if segue.identifier == "pickDifficultySegue"{
            let destination = segue.destination as! ChooseDifficultyTableViewController
            destination.delegate = self
        }
    }
    




}
