//
//  AssignStaffMembersViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-08-04.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class AssignStaffMembersViewController: UIViewController {

	@IBOutlet weak var navigationBar: UINavigationBar!
	@IBOutlet weak var tableView: UITableView!
	
	var addServiceVC: AddServiceViewController?
	
	var defaultTime: String?
	var defaultPrice: Double?
	
	var noDataLabel: UILabel?
	
	var enabled: [Bool] = []
	
	var selectedIndex = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		addServiceVC?.servicesVC?.businessRegisterVC?.staffMembers.sort()
		
		for staffMember in addServiceVC?.servicesVC?.businessRegisterVC?.staffMembers ?? [] {
			enabled.append(addServiceVC?.assignedStaff.contains(staffMember.userID) ?? false)
		}
		
		noDataLabel = tableView.addNoDataLabel(withText: "")
		tableView.register(UINib(nibName: K.Nibs.assignStaffCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.assignStaffCellIdentifier)
		tableView.tableFooterView = UIView()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationBar.tintColor = .black
		navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		// Have to set noDataLabel here for it to get the proper tableview bounds
		noDataLabel?.removeFromSuperview() // Remove blank label
		noDataLabel = tableView.addNoDataLabel(withText: "No staff members found. No worries, you can always assign to staff members after adding your services.")
		tableView.reloadData()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if addServiceVC?.assignedStaff.isEmpty ?? true && !(addServiceVC?.servicesVC?.businessRegisterVC?.staffMembers.isEmpty ?? true) {
			Alerts.showNoOptionAlert(title: "Assign Staff Member to Service", message: "Tap each staff member to assign/unassign them from \(addServiceVC?.name ?? "this service")", sender: self)
		}
	}
	
	
	@IBAction func closePressed(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}
	
	func updateAssignedStaff() {
		if var assignedStaff = self.addServiceVC?.assignedStaff, let staffMembers = self.addServiceVC?.servicesVC?.businessRegisterVC?.staffMembers {
			for i in 0..<staffMembers.count {
				if self.enabled[i] {
					
					if !assignedStaff.contains(staffMembers[i].userID) {
						assignedStaff.append(staffMembers[i].userID)
					}
					if addServiceVC?.specificTimes == nil {
						addServiceVC?.specificTimes = [staffMembers[i].userID : defaultTime!]
					} else {
						addServiceVC?.specificTimes![staffMembers[i].userID] = defaultTime!
					}
					if addServiceVC?.specificPrices == nil {
						addServiceVC?.specificPrices = [staffMembers[i].userID : defaultPrice!]
					} else {
						addServiceVC?.specificPrices![staffMembers[i].userID] = defaultPrice!
					}
					
				} else {
					
					if assignedStaff.contains(staffMembers[i].userID) {
						if let indexToRemove = assignedStaff.firstIndex(of: staffMembers[i].userID) {
							assignedStaff.remove(at: indexToRemove)
						}
					}
					addServiceVC?.specificTimes?[staffMembers[i].userID] = nil
					addServiceVC?.specificPrices?[staffMembers[i].userID] = nil
					
				}
			}
			self.addServiceVC?.assignedStaff = assignedStaff
			self.addServiceVC?.didAssignStaff = true
		} else {
			Alerts.showNoOptionAlert(title: "Error", message: "We were unable to update this information", sender: self) { (_) in
				self.dismiss(animated: true, completion: nil)
			}
		}
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is SpecificServiceDetailsViewController {
			let specificDetailsVC = segue.destination as! SpecificServiceDetailsViewController
			specificDetailsVC.assignStaffVC = self
		}
	}
	
	
}


extension AssignStaffMembersViewController: UITableViewDataSource, UITableViewDelegate {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		tableView.showHideNoDataLabel(noDataLabel: noDataLabel!, show: addServiceVC?.servicesVC?.businessRegisterVC?.staffMembers.count ?? 0 == 0)
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return addServiceVC?.servicesVC?.businessRegisterVC?.staffMembers.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.assignStaffCellIdentifier, for: indexPath) as! AssignStaffTableViewCell
		cell.checkmark.isHidden = !enabled[indexPath.row]
		cell.moreDetailsButton.isHidden = !enabled[indexPath.row]
		cell.tapToEnableLabel.isHidden = enabled[indexPath.row]
		cell.assignStaffVC = self
		cell.cellIndex = indexPath.row
		if let staffMember = addServiceVC?.servicesVC?.businessRegisterVC?.staffMembers[indexPath.row] {
			cell.staffMemberNameLabel.text = staffMember.firstName
			if let lastInitial = staffMember.lastName.first {
				cell.staffMemberNameLabel.text?.append(" \(String(lastInitial))")
			}
		} else {
			cell.staffMemberNameLabel.text = "Unknown Name"
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let cell = tableView.cellForRow(at: indexPath) as! AssignStaffTableViewCell
		if !enabled[indexPath.row] {
			enabled[indexPath.row] = !enabled[indexPath.row]
			cell.checkmark.isHidden = !cell.checkmark.isHidden
			cell.moreDetailsButton.isHidden = !cell.moreDetailsButton.isHidden
			cell.tapToEnableLabel.isHidden = !cell.tapToEnableLabel.isHidden
			updateAssignedStaff()
		} else {
			let staffMemberName = addServiceVC?.servicesVC?.businessRegisterVC?.staffMembers[indexPath.row].firstName ?? "this staff member"
			let serviceName = addServiceVC?.name ?? "this service"
			Alerts.showTwoOptionAlertDestructive(title: "Unassign \(staffMemberName) from \(serviceName)?", message: "This will reset any staff specific details you may have set for when \(staffMemberName) performs \(serviceName)", sender: self, option1: "Unassign", option2: "Cancel", is1Destructive: true, is2Destructive: false, handler1: { (_) in
				
				self.enabled[indexPath.row] = !self.enabled[indexPath.row]
				cell.checkmark.isHidden = !cell.checkmark.isHidden
				cell.moreDetailsButton.isHidden = !cell.moreDetailsButton.isHidden
				cell.tapToEnableLabel.isHidden = !cell.tapToEnableLabel.isHidden
				self.updateAssignedStaff()
				
			}, handler2: nil)
		}
	}
	
}
