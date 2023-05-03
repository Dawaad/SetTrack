//
//  LogTableViewController.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 20/4/2023.
//

import UIKit

class LogTableViewCell: UITableViewCell{
    
    @IBOutlet weak var sessionDateLabel: UILabel!
    @IBOutlet weak var sessionNameLabel: UILabel!
   
    @IBOutlet weak var sessionExerciseLabel: UILabel!
    
    var sessionExerciseArr: [String]?
    var sessionName: String?
    var sessionDate: Date?
    
    
    
}

class LogTableViewController: UITableViewController {
    
    let SESSIONCELL = "sessionLogCell";
    let dateFormatter = DateFormatter();
    


    var allSessions: [Session] = [Session(name: "Push", exercises: ["DB Press","Cable Flies", "Incline Smith Press","DB Curls", "DB Lateral Raises"], date: Date())]
    
    
//    var currentSessions:[//Ill get to it later i cbf] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Session Log"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allSessions.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SESSIONCELL, for: indexPath) as! LogTableViewCell
        cell.sessionExerciseArr = allSessions[indexPath.row].exercises;
        cell.sessionNameLabel.text = allSessions[indexPath.row].name
        dateFormatter.dateFormat = "dd/MM/yyyy"
        cell.sessionDateLabel.text = dateFormatter.string(from: allSessions[indexPath.row].date)
            
        
        return cell
    }
    
    func arrToString(arr:[String]) -> String{
        return "yes"
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
