//
//  RoutineExerciseViewController.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 9/5/2023.
//

import UIKit

class RoutineExerciseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DatabaseListener {
    
    
    
    
    
    var listenerType: ListenerType = .routine

    @IBOutlet weak var routineTableView: UITableView!
    weak var databaseController: DatabaseProtocol?
    let cellReuseIdentifier = "routineExerciseCell"
    var selectedRoutine: Routine?
    
    func onExerciseChange(change: DatabaseChange, userExercises: [Exercise]) {
        
    }
    
    func onRoutineChange(change: DatabaseChange, routines: [Routine]) {
       
    }
    func onRoutineExerciseChange(change: DatabaseChange, routines: Routine) {
        selectedRoutine = routines
        routineTableView.reloadData()
    }
    func onSessionSubmision(change: DatabaseChange, sessions: [Session]) {
        
    }
    
    @IBAction func startSession(_ sender: Any) {
        //Convert the current routine to a session
        let session = databaseController?.routineToSession(routine: selectedRoutine!)
        //When user start the sesssion, save the session to Core Data
        databaseController?.saveSessionToCoreData(session: session!)
        performSegue(withIdentifier: "showSessionSegue", sender: nil)
    }
        
    override func viewWillAppear(_ animated: Bool) {
        databaseController?.addListener(listener: self)
       
    }
    override func viewWillDisappear(_ animated: Bool) {
        databaseController?.removeListener(listener: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        guard let routine = selectedRoutine else{
            return
            
        }
       
        
        
        //Register a new cell to the table view
        self.routineTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        routineTableView.delegate = self
        routineTableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let selectedRoutine{
            return selectedRoutine.exercises.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.routineTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)! as UITableViewCell
        var content = cell.defaultContentConfiguration()
        //Set up the visuals of the cell
        content.text = selectedRoutine?.exercises[indexPath.row].exercise.name
        content.secondaryText = "\(selectedRoutine!.exercises[indexPath.row].sets) Set"
        cell.contentConfiguration = content
        //Alter the background colour to that defined in the Colour Pallette
        cell.backgroundColor = UIColor(named: "Cells")
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var exercise = selectedRoutine!.exercises[indexPath.row]
        
        performSegue(withIdentifier: "repSetEditSegue", sender: (exercise))
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            tableView.performBatchUpdates({
                //Remove the exercise from the routine array
                databaseController?.removeExerciseFromRoutine(exercise: (selectedRoutine?.exercises[indexPath.row])!, routine: databaseController!.selectedRoutine!)
           
            
            //Delete row from the table view
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
            })
        }
    }
    
    
    
    
    
    
    
    
    
    
   
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "repSetEditSegue" {
            if let (exercise) = sender as? (ExerciseDetails),
               let segueDestination = segue.destination as? RoutineSetEditViewController{
                segueDestination.selectedExerciseDetails = exercise
            }
        }
    }
    

}
