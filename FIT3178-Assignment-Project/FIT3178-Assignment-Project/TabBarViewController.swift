//
//  TabBarViewController.swift
//  FIT3178-Assignment-Project
//
//  Created by Jared Tucker on 25/4/2023.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //Defining the title of all views present in the tab bar controller
        if let viewControllers = self.viewControllers{
           
            viewControllers[0].title = "Home"
            viewControllers[1].title = "Routines"
            viewControllers[2].title = "Statistics"
            viewControllers[3].title = "Account"
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
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
