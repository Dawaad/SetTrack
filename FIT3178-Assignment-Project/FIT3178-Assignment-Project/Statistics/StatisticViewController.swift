//
//  StatisticViewController.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 8/6/2023.
//

import UIKit
import Charts
import SwiftUI

class StatisticViewController: UIViewController  {
    
    
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        setupView()
        navigationItem.title = databaseController?.statExercise?.name
    
       
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        /* Tutorial used to connected Swift UI Chart to UIKit
         Link: https://www.youtube.com/watch?v=qOdZuBIBQWA&pp=ygU2aG93IHRvIGNyZWF0ZSBhIGNoYXJ0IGluIHN3aWZ0IHVpIGFuZCB1c2UgaXQgaW4gdWlraXRd
         */
        
        let controller = UIHostingController(rootView: lineBarView())
        guard let lineView = controller.view else{
            return
        }
        
        view.addSubview(lineView)
        //Move the view into the centre of the view, taking up all space on the x axis
        lineView.translatesAutoresizingMaskIntoConstraints = false
               NSLayoutConstraint.activate([
                   lineView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//                   lineView.widthAnchor.constraint(equalToConstant: 300),
                   lineView.heightAnchor.constraint(equalToConstant: 400),
                   lineView.leftAnchor.constraint(equalTo: view.leftAnchor),
                   lineView.rightAnchor.constraint(equalTo: view.rightAnchor)
               ])
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


