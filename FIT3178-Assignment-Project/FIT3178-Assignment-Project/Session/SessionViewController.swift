//
//  SessionViewController.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 22/5/2023.
//

import UIKit


class SessionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBAction func submitSession(_ sender: Any) {
        let alertController = UIAlertController(title: "Confirm Completion", message: "Are you sure you want to finish", preferredStyle: .alert)
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel){(action) in
            return
        }
        let submitAction = UIAlertAction(title: "OK", style: .default){[weak self] (action) in
            self?.databaseController?.addSesssionToFirebase()
            self?.navigationController?.popViewController(animated: true)
            return
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(submitAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    let cellReuseIdentifier = "sessionExerciseCell"
    var selectedSession: Session?
   
    @IBOutlet weak var tableView: UITableView!
    
    weak var databaseController : DatabaseProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        selectedSession = databaseController?.activeSession

            tableView.delegate = self
            tableView.dataSource = self
        tableView.estimatedRowHeight = 200
       
        tableView.reloadData()
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.allowsSelection = false
        tableView.reloadData()
        tableView.rowHeight = 240
           
            
       

        navigationItem.title = selectedSession?.name
        
        // Do any additional setup after loading the view.
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedSession!.exercises!.count
        
    }
    

//
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! sessionExerciseCell
        let exercise = selectedSession!.exercises![indexPath.row]
        cell.configure(with: exercise)
//        cell.exerciseName.text = (selectedSession?.exercises[indexPath.row].exercise.name)!
        
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

class sessionExerciseCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate{
    
    
    var exercise: SessionExercise?
    let cellReuseIdentifier = "sessionRepCell"
    
    
    @IBOutlet weak var exerciseName: UILabel!

  
    
    @IBOutlet weak var repExerciseTable: UITableView!
       
    
    func configure(with rowExercise: SessionExercise){
        self.exercise = rowExercise
        self.exerciseName.text = exercise?.exercise.name
        self.repExerciseTable.dataSource = self
        self.repExerciseTable.delegate = self
        self.repExerciseTable.rowHeight = UITableView.automaticDimension
//        self.repExerciseTable.allowsSelection = false
        self.repExerciseTable.reloadData()
        self.repExerciseTable.setNeedsLayout()
        self.repExerciseTable.layoutIfNeeded()
        self.repExerciseTable.reloadData()

    }
  

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercise!.sets
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: sessionRepCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! sessionRepCell
        
        cell.configure(with: exercise!.performance[indexPath.row], with: exercise!.exercise.id!, with: indexPath.row)
        return cell
    }
    
}

class sessionRepCell: UITableViewCell{
    

    @IBOutlet weak var setNumber: UILabel!
    
    var numSet: Int?
    var setExerciseID: String?
    
    @IBOutlet weak var setRest: UITextField!
    @IBOutlet weak var setReps: UITextField!
    @IBOutlet weak var setWeight: UITextField!
    var repWeight: SetRepWeight?
    weak var databaseController: DatabaseProtocol?
    func configure(with repWeight: SetRepWeight, with exerciseID: String, with setNum: Int){
        setReps.text = repWeight.rep.formatted()
        setWeight.text = repWeight.weight.formatted()
        setRest.text = repWeight.restTime.formatted()
        
        setNumber.text = "Set \(setNum+1)"
        numSet = setNum
        setExerciseID = exerciseID
        
    }
    
    
    @IBAction func updateSetRep(_ sender: Any) {
        
        guard let numRep = Int(setReps.text!) else{
            setReps.text = repWeight?.rep.formatted()
            return
        }
        
        databaseController?.updateSetReps(reps: Int(setReps.text!)!, exerciseID: setExerciseID!, setNum: numSet!)
    }
    
    
    @IBAction func updateSetWeight(_ sender: Any) {
        guard let numWeight = Int(setWeight.text!) else{
            setWeight.text = repWeight?.weight.formatted()
            return
        }
        databaseController?.updateSetWeight(weight: Int(setWeight.text!)!, exerciseID: setExerciseID!, setNum: numSet!)
    }
    
    
    
    @IBAction func updateSetRest(_ sender: Any) {
        guard let numRest = Int(setRest.text!) else{
            setRest.text = repWeight?.restTime.formatted()
            return
        }
        databaseController?.updateSetRest(rest: Int(setRest.text!)!, exerciseID: setExerciseID!, setNum: numSet!)
    }
    
    
    override  func awakeFromNib() {
        super.awakeFromNib()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        
    }
    
    
}


