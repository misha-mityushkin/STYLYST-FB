//
//  AssignServicesViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-08-04.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class AssignServicesViewController: UIViewController {

	@IBOutlet weak var navigationBar: UINavigationBar!
	@IBOutlet weak var tableView: UITableView!
	
	var addStaffMemberVC: AddStaffMemberViewController?
	
	var noDataLabel: UILabel?
	
	var enabled: [Bool] = []
	
	var selectedIndex = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let staffMember = addStaffMemberVC?.staffMember
		for service in addStaffMemberVC?.services ?? [] {
			enabled.append(staffMemberIsCapableOfService(staffMember: staffMember, service: service))
		}
		
		noDataLabel = tableView.addNoDataLabel(withText: "")
		tableView.register(UINib(nibName: K.Nibs.assignServicesCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.assignServicesCellIdentifier)
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
		noDataLabel = tableView.addNoDataLabel(withText: "No services found. No worries, you can always add and assign services after adding staff members.")
		tableView.reloadData()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		var hasPreviouslyAssigned = false
		for service in addStaffMemberVC?.services ?? [] {
			if staffMemberIsCapableOfService(staffMember: addStaffMemberVC?.staffMember, service: service) {
				hasPreviouslyAssigned = true
			}
		}
		if !hasPreviouslyAssigned && !(addStaffMemberVC?.staffMembersVC?.staffMembers?.isEmpty ?? true) {
			Alerts.showNoOptionAlert(title: "Assign Services to Staff Member", message: "Tap each service to assign/unassign \(addStaffMemberVC?.staffMember?.firstName ?? "this staff member") from it", sender: self)
		}
	}
	
	@IBAction func closePressed(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}
	
	func updateAssignedServices() {
		if var services = self.addStaffMemberVC?.services, let staffMember = self.addStaffMemberVC?.staffMember {
			
			for i in 0..<services.count {
				
				var service = services[i]
				var staffMembersCapableOfService = service.assignedStaff
				var specificTimes = service.specificTimes
				var specificPrices = service.specificPrices
				let defaultTime = service.defaultTime
				let defaultPrice = service.defaultPrice
				
				if self.enabled[i] { //if this service should be enabled for staff member
					
					if !self.staffMemberIsCapableOfService(staffMember: staffMember, service: service) { //if its not enabled
						staffMembersCapableOfService.append(staffMember.userID)
					}
					specificTimes[staffMember.userID] = defaultTime
					specificPrices[staffMember.userID] = defaultPrice
					
				} else { //if this service should not be enabled for staff member
					
					if self.staffMemberIsCapableOfService(staffMember: staffMember, service: service) { //if it is enabled
						if let indexToRemove = staffMembersCapableOfService.firstIndex(of: staffMember.userID) {
							staffMembersCapableOfService.remove(at: indexToRemove)
						}
					}
					specificTimes[staffMember.userID] = nil
					specificPrices[staffMember.userID] = nil
					
				}
				
				service.specificTimes = specificTimes
				service.specificPrices = specificPrices
				service.assignedStaff = staffMembersCapableOfService
				services[i] = service
				
			}
			self.addStaffMemberVC?.services = services
			self.addStaffMemberVC?.assignedServices = true
			
		} else {
			Alerts.showNoOptionAlert(title: "Error", message: "We were unable to update this information", sender: self) { (_) in
				self.dismiss(animated: true, completion: nil)
			}
		}
	}
	
	
	func staffMemberIsCapableOfService(staffMember: User?, service: Service?) -> Bool {
		let staffMembersCapableOfService = service?.assignedStaff ?? []
		return staffMembersCapableOfService.contains(staffMember?.userID ?? "")
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is SpecificServiceDetailsViewController {
			let specificDetailsVC = segue.destination as! SpecificServiceDetailsViewController
			specificDetailsVC.assignServicesVC = self
		}
	}
	
}


extension AssignServicesViewController: UITableViewDataSource, UITableViewDelegate {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		tableView.showHideNoDataLabel(noDataLabel: noDataLabel!, show: addStaffMemberVC?.services.count ?? 0 == 0)
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return addStaffMemberVC?.services.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.assignServicesCellIdentifier, for: indexPath) as! AssignServicesTableViewCell
		let service = addStaffMemberVC?.services[indexPath.row]
		cell.checkmark.isHidden = !enabled[indexPath.row]
		cell.moreDetailsButton.isHidden = !enabled[indexPath.row]
		cell.tapToEnableLabel.isHidden = enabled[indexPath.row]
		cell.assignServicesVC = self
		cell.cellIndex = indexPath.row
		cell.serviceNameLabel.text = service?.name ?? "Unknown Name"
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		let cell = tableView.cellForRow(at: indexPath) as! AssignServicesTableViewCell
		if !enabled[indexPath.row] {
			enabled[indexPath.row] = !enabled[indexPath.row]
			cell.checkmark.isHidden = !cell.checkmark.isHidden
			cell.moreDetailsButton.isHidden = !cell.moreDetailsButton.isHidden
			cell.tapToEnableLabel.isHidden = !cell.tapToEnableLabel.isHidden
			updateAssignedServices()
		} else {
			let staffMemberName = addStaffMemberVC?.staffMember?.firstName ?? "this staff member"
			let serviceName = addStaffMemberVC?.services[indexPath.row].name ?? "this service"
			Alerts.showTwoOptionAlertDestructive(title: "Unassign \(staffMemberName) from \(serviceName)?", message: "This will reset any staff specific details you may have set for when \(staffMemberName) performs \(serviceName)", sender: self, option1: "Unassign", option2: "Cancel", is1Destructive: true, is2Destructive: false, handler1: { (_) in
				
				self.enabled[indexPath.row] = !self.enabled[indexPath.row]
				cell.checkmark.isHidden = !cell.checkmark.isHidden
				cell.moreDetailsButton.isHidden = !cell.moreDetailsButton.isHidden
				cell.tapToEnableLabel.isHidden = !cell.tapToEnableLabel.isHidden
				self.updateAssignedServices()
				
			}, handler2: nil)
		}
		
	}
	
}
