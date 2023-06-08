//
//  StatisticRoutineSelectionTableViewController.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 8/6/2023.
//

import UIKit

class StatisticRoutineSelectionTableViewController: UITableViewController, DatabaseListener {
   
    
    
    var listenerType: ListenerType = .routines
    var userRoutines = [Routine]()
    weak var databaseController: DatabaseProtocol?
    let CELL_ROUTINE = "routineCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userRoutines.count
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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let routine = userRoutines[indexPath.row]
        databaseController?.setStatRoutine(routine: routine)
        performSegue(withIdentifier: "statsRoutineSelectedSegue", sender: routine)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
        if segue.identifier == "statsRoutineSelectedSegue"{
            if let (routine) = sender as? (Routine),
               let segueDestination = segue.destination as? StatisticExerciseSelectionTableViewController {
                segueDestination.selectedRoutine = routine
            }
        }
    }
    

}
