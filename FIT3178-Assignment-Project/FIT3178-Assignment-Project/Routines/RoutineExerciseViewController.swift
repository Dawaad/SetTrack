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
       
        
        //Set Text Field to be routine
        //Also research debouncing
        
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
        content.text = selectedRoutine?.exercises[indexPath.row].exercise.name
        content.secondaryText = "\(selectedRoutine!.exercises[indexPath.row].sets) Set"
        cell.contentConfiguration = content
        return cell
        
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
