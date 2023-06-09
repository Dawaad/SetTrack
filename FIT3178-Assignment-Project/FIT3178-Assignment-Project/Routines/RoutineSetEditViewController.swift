//
//  RoutineSetEditViewController.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 7/6/2023.
//

import UIKit

class RoutineSetEditViewController: UIViewController, UITextFieldDelegate {
    
    
    
    weak var databaseController: DatabaseProtocol?
   
    
    @IBOutlet weak var exerciseSetNum: UITextField!
    
    var selectedExerciseDetails: ExerciseDetails?
    override func viewDidLoad() {
        super.viewDidLoad()
     
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        guard let exercise = selectedExerciseDetails else{
            return
        }
        exerciseSetNum.text = exercise.sets.formatted()
        exerciseSetNum.delegate = self
        
        
        navigationItem.title = exercise.exercise.name
        /* Set up a gestuer recgoniser to ensure that when the user taps off the keyboard
         it will close automatically, and any changes made will be saved and updated
         in the controller and the database
         */
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
           view.addGestureRecognizer(tapGesture)
        
        
        // Do any additional setup after loading the view.
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        exerciseSetNum.resignFirstResponder()
        return true
    }
    
    
    @IBAction func updateExerciseSetNum(_ sender: Any) {
        let prev = Int(exerciseSetNum.text!)
        //Check if the number of sets is >=1
        guard let num = Int(exerciseSetNum.text!), num>=1 else{
            exerciseSetNum.text = selectedExerciseDetails?.sets.formatted()
            return
        }
        
        //Call the controller functions to update the number of sets for a particular session
        databaseController?.updateExerciseSetCountInRoutine(exercise: selectedExerciseDetails!, set: num ,routine: databaseController!.selectedRoutine!)
        selectedExerciseDetails?.sets = num
        
    }
    
    
    @IBAction func removeExerciseFromRoutine(_ sender: Any) {
        //Call the controller function to remove an exercise
        databaseController?.removeExerciseFromRoutine(exercise: selectedExerciseDetails!, routine: databaseController!.selectedRoutine!)
        navigationController?.popViewController(animated: true)
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
