//
//  AppointmentsViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-06-20.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class AppointmentsViewController: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let launchedBefore = UserDefaults.standard.bool(forKey: K.UserDefaultKeys.launchedBefore)
        if launchedBefore {
            print("launched before")
        } else {
            print("first launch")
            performSegue(withIdentifier: K.Segues.firstLaunchSegue, sender: self)
            UserDefaults.standard.set(true, forKey: K.UserDefaultKeys.launchedBefore)
        }
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
