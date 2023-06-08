//
//  ExerciseSelectionTableViewController.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 25/4/2023.
//

import UIKit

class ExerciseSelectionTableViewController: UITableViewController, DatabaseListener{
    
    
    var listenerType: ListenerType = .exercise
    
    
    

    
    var selectedCategory: String?
    var apiCategoryFormat: String?
    let SECTION_CUSTOM = 0
    let CELL_CUSTOM = "customExerciseCell"
    let SECTION_API = 1
    let CELL_API = "apiExerciseCell"
    weak var databaseController: DatabaseProtocol?
    var customExercises = [Exercise]()
    var apiExercises =  [Exercise]()
    var indicator = UIActivityIndicatorView()
    
    func onExerciseChange(change: DatabaseChange, userExercises: [Exercise]) {
        customExercises = userExercises.filter{$0.category == apiCategoryFormat && $0.isCustom == true}
        print("cringe")
        tableView.reloadData()
    }
    
    func onRoutineChange(change: DatabaseChange, routines: [Routine]) {
        
    }
    
    func onRoutineExerciseChange(change: DatabaseChange, routines: Routine) {
        
    }
    func onSessionSubmision(change: DatabaseChange, sessions: [Session]) {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        guard let category = selectedCategory else{
            return
        }
        
        navigationItem.title = category
        apiCategoryFormat = category.replacingOccurrences(of: " ", with: "_").lowercased()
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
      
       
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if apiExercises.isEmpty{
            Task{
                await retrieveExercises(offset:0)
            }
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    
    let MAX_ITEMS_PER_REQUEST = 10
    let MAX_REQUESTS = 10 
    
    func retrieveExercises(offset:Int) async {
        
        let muscle = apiCategoryFormat?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: "https://api.api-ninjas.com/v1/exercises?muscle=\(muscle!)&offset=\(offset*10)")!
        var request = URLRequest(url: url)
        request.setValue("CvDeegsYeUPwFe5/w0EKxQ==lteJMNQQKB0SQnNW", forHTTPHeaderField: "X-Api-Key")
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            let exerciseData = try decoder.decode([Exercise].self, from: data)
            
            let startIndex = apiExercises.count
            let endIndex = startIndex + exerciseData.count - 1
            let indexPath = (startIndex...endIndex).map{IndexPath(row: $0, section: 1)}
            
            for exercise in exerciseData{
                exercise.category = apiCategoryFormat
                exercise.isCustom = false
                apiExercises.append(exercise)
            }
            
            
            tableView.beginUpdates()
            tableView.insertRows(at: indexPath, with: .automatic)
            tableView.endUpdates()
            
            if exerciseData.count == MAX_ITEMS_PER_REQUEST, offset + 1 < MAX_REQUESTS{
                await retrieveExercises(offset: offset + 1)
            }
        } catch let error{
            print(error)
        }
            
            
            
            
        
        
        
      
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == SECTION_CUSTOM{
            return customExercises.count
        }
        else if section == SECTION_API{
            return apiExercises.count
        }
        else{
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SECTION_CUSTOM{
            return "Custom Exercises"
        }
        if section == SECTION_API{
            return "Curated Exercises"
        }
        else{
            return " "
        }
    }
    
    func dequeCell(indexPath: IndexPath) -> UITableViewCell?{
        var cell: UITableViewCell?
        switch indexPath.section{
        case SECTION_API:
            cell = tableView.dequeueReusableCell(withIdentifier: CELL_API, for: indexPath)
        case SECTION_CUSTOM:
            cell = tableView.dequeueReusableCell(withIdentifier: CELL_CUSTOM, for: indexPath)
        default:
            break
        }
        return cell
        }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var exercise: Exercise?
        if indexPath.section == SECTION_CUSTOM {
            exercise = customExercises[indexPath.row]
        }
        else{
            exercise = apiExercises[indexPath.row]
        }
        let cell = dequeCell(indexPath: indexPath)
        
        var content = cell!.defaultContentConfiguration()

        content.text = exercise?.name
        content.secondaryText = exercise?.difficulty?.capitalized
        cell!.contentConfiguration = content
        return cell!
       
      
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var exercise: Exercise?
        if indexPath.section == SECTION_CUSTOM{
            exercise = customExercises[indexPath.row]
           
        }
        else{
            exercise = apiExercises[indexPath.row]
        }
        
        if !(self.databaseController!.addExerciseToRoutine(exercise: exercise!, set: 1)){
            displayMessage("Exercise already in routine", "Cannot add this exercise to the routine, as it already exists within the current routine")
        }
        
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    func displayMessage(_ title:String, _ message:String){
        let alertControlller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertControlller.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        self.present(alertControlller, animated: true, completion: nil
        )
    }
    
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_CUSTOM{
            // Delete the row from the data source
            tableView.performBatchUpdates({
                databaseController?.deleteExercise(exercise: customExercises[indexPath.row])
                customExercises.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadSections([SECTION_CUSTOM], with: .automatic)
            })
           
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
