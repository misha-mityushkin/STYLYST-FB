//
//  ProfileViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-06-20.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let sectionNames: [String] = ["My Schedule", "Sales", "Staff", "Clients", "Manage Businesses", "Payment Info", "Settings", "Log out"]
    let sectionIconNames: [String] = ["calendar", "dollarsign.circle", "person.3", "rectangle.stack.badge.person.crop", "tray.2", "creditcard", "gear", "escape"]
    var sectionIcons: [UIImage?] = []
    
    var spinnerView = LoadingView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        navigationController?.viewControllers = [self]
        tableView.dataSource = self
        tableView.delegate = self
        
        
        loadSectionIcons()
        
		tableView.register(UINib(nibName: K.Nibs.profileHeaderCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.profileHeaderCellIdentifier)
        tableView.register(UINib(nibName: K.Nibs.profileSectionCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.profileSectionCellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    func loadSectionIcons() {
        if #available(iOS 13.0, *) {
            for iconName in sectionIconNames {
                sectionIcons.append(UIImage(systemName: iconName))
            }
        } else {
            for iconName in sectionIconNames {
                print("gold.\(iconName)")
                sectionIcons.append(UIImage(named: "gold.\(iconName)"))
            }
        }
    }
    
    func generateGreeting() -> String {
        let calendar = Calendar.current
        
        let now = Date()
        let morning = calendar.date(bySettingHour: 3, minute: 0, second: 0, of: now)!
        let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: now)!
        let evening = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now)!

        if now >= morning && now < noon {
            return "Good Morning"
        } else if now >= noon && now < evening {
            return "Good Afternoon"
        } else if now >= evening || now < morning {
            return "Good Evening"
        } else {
            return "Greetings"
        }
    }

}


extension ProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionNames.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == 0 {
			let headerCell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.profileHeaderCellIdentifier, for: indexPath) as! ProfileHeaderTableViewCell
			headerCell.titleLabel.text = generateGreeting()
			if let name = UserDefaults.standard.string(forKey: K.UserDefaultKeys.User.firstName) {
				headerCell.titleLabel.text?.append(", \(name)")
			}
			return headerCell
		} else {
			let sectionCell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.profileSectionCellIdentifier, for: indexPath) as! ProfileSectionTableViewCell
			sectionCell.sectionName.text = sectionNames[indexPath.row - 1]
			sectionCell.sectionIcon.image = sectionIcons[indexPath.row - 1]
			
			return sectionCell
		}
    }
    
}

extension ProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
            case 1:
                break
            case 2:
                break
            case 3:
                break
            case 4:
                break
            case 5:
                performSegue(withIdentifier: K.Segues.profileToManageBusinesses, sender: self)
                break
            case 6:
                
                
                
                break
                
            case 7:
                break
                
            case 8:
                
                if let numVCsInStack = navigationController?.viewControllers.count {
                    if numVCsInStack > 1 {
                        Alerts.showNoOptionAlert(title: "Error signing out", message: "Please quit the app and relaunch it", sender: self)
                    } else {
                        Alerts.showTwoOptionAlertDestructive(title: "Log out Confirmation", message: "Are you sure you want to log out?", sender: self, option1: "Logout", option2: "Cancel", is1Destructive: true, is2Destructive: false, handler1: { (_) in
                            
                            self.spinnerView.create(parentVC: self)
                            if let signInVC = self.storyboard?.instantiateViewController(withIdentifier: K.Storyboard.signInVC) {
                                do {
                                    try Auth.auth().signOut()
                                } catch let error {
                                    self.spinnerView.remove()
                                    Alerts.showNoOptionAlert(title: "Error signing out", message: "Please quit the app and relaunch it. Error description: \(error.localizedDescription)", sender: self)
                                }
                                UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.User.password)
								UserDefaults.standard.set(false, forKey: K.UserDefaultKeys.User.sentVerificationCode)
								UserDefaults.standard.set(false, forKey: K.UserDefaultKeys.User.verifiedPhoneNumber)
								UserDefaults.standard.set(false, forKey: K.UserDefaultKeys.User.setUpBusinessAccount)
                                UserDefaults.standard.set(false, forKey: K.UserDefaultKeys.User.isSignedIn)
                                self.spinnerView.remove()
                                self.navigationController?.viewControllers = [signInVC, self]
                                self.navigationController?.popToRootViewController(animated: true)
                            } else {
                                self.spinnerView.remove()
                                Alerts.showNoOptionAlert(title: "Error signing out", message: "Please quit the app and relaunch it", sender: self)
                            }
                            
                        }, handler2: nil)
                    }
                }
                
                
                break
                
            default:
                break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
