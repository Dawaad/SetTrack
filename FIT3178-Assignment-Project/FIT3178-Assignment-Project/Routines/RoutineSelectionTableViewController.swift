//
//  RoutineSelectionTableViewController.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 8/5/2023.
//

import UIKit

class RoutineSelectionTableViewController: UITableViewController, DatabaseListener {
  
    
    
    
    
    var listenerType: ListenerType = .routines
    let CELL_ROUTINE = "routineCell"
    var userRoutines = [Routine]()
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    
    func displayMessage(_ title:String, _ message:String){
        let alertControlller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertControlller.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        self.present(alertControlller, animated: true, completion: nil
        )
    }
    
    @IBAction func newRoutine(_ sender: Any) {
        //Set up an alert controller to allow users to name their routine
        let alertController = UIAlertController(title: "Routine Name", message: "Please Enter a name for this routine", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            //Insert a text field
            textField.placeholder = "Routine Name"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){(action) in
            return
        }
        //If the user presses submit
        let submitAction = UIAlertAction(title: "OK", style: .default){[weak self] (action) in
            guard let textField = alertController.textFields?.first else {return}
            textField.resignFirstResponder()
            //Check if the name is not empty
            let routineName = textField.text ?? ""
            if (routineName.isEmpty){
                return
            }
            else{
                //Create a new routine object and assign its name
                let newRoutine = Routine()
                newRoutine.name = routineName
                
                //Add the routine to Firebase, and update the current selected routine in the controller
                if ((self?.databaseController?.addRoutineToFirebase(routine: newRoutine)) != nil){
                    self?.databaseController?.selectRoutine(routine: newRoutine)
                    self?.performSegue(withIdentifier: "routineDetailSegue", sender: newRoutine)
                }
                else{
                    self?.displayMessage("Error Creating Routine", "An Error occured attempting to create a new routine")
                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(submitAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func onExerciseChange(change: DatabaseChange, userExercises: [Exercise]) {
        
    }
    
    func onRoutineChange(change: DatabaseChange, routines: [Routine]) {
        userRoutines = routines
        
        tableView.reloadData()
    }
    
    func onRoutineExerciseChange(change: DatabaseChange, routines: Routine) {
        
    }
    func onSessionSubmision(change: DatabaseChange, sessions: [Session]) {
        
    }
    
    

    // MARK: - Table view data source
    override func viewWillAppear(_ animated: Bool) {
        databaseController?.addListener(listener: self)
       
    }
    override func viewWillDisappear(_ animated: Bool) {
        databaseController?.removeListener(listener: self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userRoutines.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let routine = userRoutines[indexPath.row]
        databaseController?.selectRoutine(routine: routine)
        performSegue(withIdentifier: "routineDetailSegue", sender: (routine))
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ROUTINE, for: indexPath)
        let routine = userRoutines[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = routine.name
        cell.contentConfiguration = content
        // Configure the cell...

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //Delete from Database 
            databaseController?.removeRoutine(routine: userRoutines[indexPath.row])
            // Delete the row from the data source
            userRoutines.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "routineDetailSegue"{
            if let (routine) = sender as? (Routine),
               let segueDestination = segue.destination as? RoutineExerciseViewController{
                segueDestination.selectedRoutine = routine
            }
        }
    }
    

}
