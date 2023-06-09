//
//  ChooseCategoryTableViewController.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 1/5/2023.
//

import UIKit

protocol CategoryChangeDelegate: AnyObject{
    func selectCategory(_ selectedCategory: String)
}


class ChooseCategoryTableViewController: UITableViewController {
    weak var delegate: CategoryChangeDelegate?
    
    let CELL_CHEST = "chestCategoryCell"
    let SECTION_CHEST = 0
    let CELL_BACK = "backCategoryCell"
    let SECTION_BACK = 1
    let CELL_ARMS = "armsCategoryCell"
    let SECTION_ARMS = 2
    let CELL_LEGS = "legsCategoryCell"
    let SECTION_LEGS = 3
    
    //Defining all avaliable categories and dividing into sub-sections
    var chestCategory: [String] = [
        "Chest"
    ]
    var backCategory: [String] = [
        "Middle Back",
        "Lower Back",
        "Lats",
        "Traps"
    ]
    var legCategory : [String] = [
        "Quadriceps",
        "Hamstrings",
        "Glutes",
        "Adductors",
        "Abductors",
        "Calves"
    ]
    var armCategory: [String] = [
        "Biceps",
        "Triceps",
        "Forearms"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func getCategory(section:Int, row:Int) -> String? {
        var category: String?
        switch section {
            case SECTION_CHEST:
            category = chestCategory[row]
            case SECTION_ARMS:
            category = armCategory[row]
            case SECTION_BACK:
            category = backCategory[row]
            case SECTION_LEGS:
            category = legCategory[row]
            default: break
            
            
            
        }
        return category
    }
    
    func dequeCell(section: Int, indexPath: IndexPath) -> UITableViewCell? {
        var cell: UITableViewCell?
        switch section {
        case SECTION_CHEST:
            cell = tableView.dequeueReusableCell(withIdentifier: CELL_CHEST, for: indexPath)
        case SECTION_ARMS :
            cell = tableView.dequeueReusableCell(withIdentifier: CELL_ARMS, for: indexPath)
        case SECTION_BACK:
            cell = tableView.dequeueReusableCell(withIdentifier: CELL_BACK, for: indexPath)
        case SECTION_LEGS:
            cell = tableView.dequeueReusableCell(withIdentifier: CELL_LEGS, for: indexPath)
        default:
            break
        }
        
        
        return cell
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section{
        case SECTION_CHEST:
            return chestCategory.count
        case SECTION_BACK:
            return backCategory.count
        case SECTION_LEGS:
            return legCategory.count
        case SECTION_ARMS:
            return armCategory.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var category: String?
        category = getCategory(section: indexPath.section, row: indexPath.row)
        
        let cell = dequeCell(section: indexPath.section, indexPath: indexPath)
        var content = cell!.defaultContentConfiguration()
        
        content.text = category
        cell!.contentConfiguration = content
        
        // Configure the cell...

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case SECTION_CHEST:
            return "Chest"
        case SECTION_ARMS:
            return "Arms"
        case SECTION_BACK:
            return "Back"
        case SECTION_LEGS:
            return "Legs"
        default:
            return " "
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = getCategory(section: indexPath.section, row: indexPath.row)
        delegate?.selectCategory(category!)
        self.navigationController?.popViewController(animated: true)
    }

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
