//
//  SessionViewController.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 22/5/2023.
//

import UIKit


class PreviousSessionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var startDateLabel: UILabel!
    
    @IBOutlet weak var endDateLabel: UILabel!
    
    
    
    let cellReuseIdentifier = "sessionExerciseCell"
    var selectedSession: Session?
   
    @IBOutlet weak var tableView: UITableView!
    
    weak var databaseController : DatabaseProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

        guard let session = selectedSession else{
            return
        }

            tableView.delegate = self
            tableView.dataSource = self
    
        tableView.reloadData()
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.allowsSelection = false
        tableView.reloadData()
       
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy HH:mm"
        
        startDateLabel.text = "Start Date: " +  dateFormatter.string(from: (selectedSession?.startDateTime)!)
        endDateLabel.text = "End Date: " + dateFormatter.string(from: (selectedSession?.endDateTime)!)
        navigationItem.title = selectedSession?.name
        
        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedSession!.exercises!.count
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
    

//
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! PreviousSessionExerciseCell
        let exercise = selectedSession!.exercises![indexPath.row]
        cell.configure(with: exercise)
        
        cell.layer.cornerRadius = 8
        
        
//        cell.exerciseName.text = (selectedSession?.exercises[indexPath.row].exercise.name)!
        
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let verticalPadding: CGFloat = 15

            let maskLayer = CALayer()
            maskLayer.cornerRadius = 10    //if you want round edges
            maskLayer.backgroundColor = UIColor.black.cgColor
            maskLayer.frame = CGRect(x: cell.bounds.origin.x, y: cell.bounds.origin.y, width: cell.bounds.width, height: cell.bounds.height).insetBy(dx: 0, dy: verticalPadding/2)
            cell.layer.mask = maskLayer
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

class PreviousSessionExerciseCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate{
    
    
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
        let cell: PreviousSessionRepCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! PreviousSessionRepCell
        
        cell.configure(with: exercise!.performance[indexPath.row], with: exercise!.exercise.id!, with: indexPath.row)
        return cell
    }
    
}

class PreviousSessionRepCell: UITableViewCell{
    

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
    
    
    
    override  func awakeFromNib() {
        super.awakeFromNib()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        
    }
    
    
}


