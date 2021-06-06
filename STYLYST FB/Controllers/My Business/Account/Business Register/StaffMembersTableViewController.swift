//
//  StaffMembersTableViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-07-31.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class StaffMembersTableViewController: UITableViewController {
	
	var businessRegisterVC: BusinessRegisterViewController?
	
	var staffMembers: [User]?
	
	var selectedCellIndex: Int?
	
	var noDataLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.backgroundView = UIImageView(image: K.Images.backgroundNoLogo)
		noDataLabel = addNoDataLabel(withText: "No staff members added yet. Tap the + icon in the top right corner to add a staff member")
		tableView.register(UINib(nibName: K.Nibs.staffMembersCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.staffMembersCellIdentifier)
		tableView.tableFooterView = UIView()
		
		updateStaff()
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.tintColor = .black
		UIView.animate(withDuration: 0.5) {
			self.navigationItem.leftBarButtonItem?.tintColor = .black
			self.navigationItem.rightBarButtonItem?.tintColor = .black
			self.navigationController?.returnToOriginalState()
			let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
			self.navigationController?.navigationBar.titleTextAttributes = textAttributes
			self.navigationController?.navigationBar.layoutIfNeeded()
		}
	}
	
	@IBAction func addStaffMemberButtonPressed(_ sender: UIBarButtonItem) {
		if let plan = businessRegisterVC?.subscriptionPlans?[businessRegisterVC?.planTypeSegmentedControl.selectedSegmentIndex ?? 0] {
			if staffMembers?.count ?? 0 >= plan.numStaff && plan.numStaff != -1 {
				Alerts.showNoOptionAlert(title: "Staff Member Limit Reached", message: "You have selected the \(plan.name) plan which includes \(plan.numStaffDisplay) staff member(s). If you need more staff members, please choose a bigger plan", sender: self)
			} else {
				selectedCellIndex = nil
				performSegue(withIdentifier: K.Segues.staffMembersToAddStaffMember, sender: self)
			}
		} else {
			Alerts.showNoOptionAlert(title: "Error", message: "An error occurred. Please restart the app and try again", sender: self)
		}
	}
	
	func updateStaff() {
		staffMembers?.sort()
		if let staffMembers = staffMembers {
			businessRegisterVC?.staffMembers = staffMembers
			tableView.reloadData()
		}
	}

	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
		showHideNoDataLabel(noDataLabel: noDataLabel!, show: staffMembers?.count ?? 0 == 0)
		return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return staffMembers?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.staffMembersCellIdentifier, for: indexPath) as! StaffMembersTableViewCell
		if let staffMember = staffMembers?[indexPath.row] {
			cell.nameLabel.text = "\(staffMember.firstName) \(staffMember.lastName)"
			cell.emailLabel.text = staffMember.email
			cell.phoneNumber.text = Helpers.format(phoneNumber: staffMember.phoneNumber)
		} else {
			cell.nameLabel.text = "Unknown Name"
			cell.emailLabel.text = "Unknown Email"
			cell.phoneNumber.text = "Unknown Phone Number"
		}
        return cell
    }
	
	//MARK: - Table view delegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		selectedCellIndex = indexPath.row
		performSegue(withIdentifier: K.Segues.staffMembersToAddStaffMember, sender: self)
	}

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is AddStaffMemberViewController {
			let addStaffVC = segue.destination as! AddStaffMemberViewController
			addStaffVC.staffMembersVC = self
			if let selectedCellIndex = selectedCellIndex {
				addStaffVC.isEditStaffMember = true
				addStaffVC.selectedIndex = selectedCellIndex
			}
		}
    }

}
