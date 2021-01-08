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
		print(enabled)
		noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
		noDataLabel?.numberOfLines = 0
		noDataLabel!.text = "No services found. You can add and assign services after adding all your staff members."
		noDataLabel!.textColor = K.Colors.goldenThemeColorDefault
		noDataLabel!.textAlignment = .center
		noDataLabel!.isHidden = true
		tableView.delegate = self
		tableView.dataSource = self
		tableView.backgroundView = nil
		tableView.register(UINib(nibName: K.Nibs.assignServicesCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.assignServicesCellIdentifier)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationBar.tintColor = .black
		navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
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
				var staffMembersCapableOfService = service[K.Firebase.PlacesFieldNames.Services.staff] as? [String] ?? []
				var specificTimes = service[K.Firebase.PlacesFieldNames.Services.specificTimes] as? [String : String]
				var specificPrices = service[K.Firebase.PlacesFieldNames.Services.specificPrices] as? [String : Double]
				let defaultTime = service[K.Firebase.PlacesFieldNames.Services.defaultTime] as? String ?? "0h 0min"
				let defaultPrice = service[K.Firebase.PlacesFieldNames.Services.defaultPrice] as? Double ?? 0
				
				if self.enabled[i] { //if this service should be enabled for staff member
					
					if !self.staffMemberIsCapableOfService(staffMember: staffMember, service: service) { //if its not enabled
						staffMembersCapableOfService.append(staffMember.userID)
					}
					if specificTimes == nil {
						specificTimes = [staffMember.userID : defaultTime]
					} else {
						specificTimes![staffMember.userID] = defaultTime
					}
					if specificPrices == nil {
						specificPrices = [staffMember.userID : defaultPrice]
					} else {
						specificPrices![staffMember.userID] = defaultPrice
					}
					
				} else { //if this service should not be enabled for staff member
					
					if self.staffMemberIsCapableOfService(staffMember: staffMember, service: service) { //if it is enabled
						if let indexToRemove = staffMembersCapableOfService.firstIndex(of: staffMember.userID) {
							staffMembersCapableOfService.remove(at: indexToRemove)
						}
					}
					specificTimes?[staffMember.userID] = nil
					specificPrices?[staffMember.userID] = nil
					
				}
				
				service[K.Firebase.PlacesFieldNames.Services.specificTimes] = specificTimes
				service[K.Firebase.PlacesFieldNames.Services.specificPrices] = specificPrices
				service[K.Firebase.PlacesFieldNames.Services.staff] = staffMembersCapableOfService
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
	
	
	func staffMemberIsCapableOfService(staffMember: User?, service: [String : Any]?) -> Bool {
		let staffMembersCapableOfService = service?[K.Firebase.PlacesFieldNames.Services.staff] as? [String] ?? []
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
		if addStaffMemberVC?.services.count == 0 {
			if let noDataLabel = noDataLabel {
				noDataLabel.isHidden = false
				tableView.backgroundView = noDataLabel
			}
			tableView.separatorStyle = .none
		} else {
			tableView.separatorStyle = .singleLine
			tableView.backgroundView = nil
		}
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
		cell.serviceNameLabel.text = service?[K.Firebase.PlacesFieldNames.Services.name] as? String ?? "Unknown Name"
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
			Alerts.showTwoOptionAlertDestructive(title: "Edit Confirmation", message: "Are you sure you want to unassign \(addStaffMemberVC?.staffMember?.firstName ?? "this staff member") from \(addStaffMemberVC?.services[indexPath.row][K.Firebase.PlacesFieldNames.Services.name] ?? "this service")?", sender: self, option1: "Unassign", option2: "Cancel", is1Destructive: true, is2Destructive: false, handler1: { (_) in
				
				self.enabled[indexPath.row] = !self.enabled[indexPath.row]
				cell.checkmark.isHidden = !cell.checkmark.isHidden
				cell.moreDetailsButton.isHidden = !cell.moreDetailsButton.isHidden
				cell.tapToEnableLabel.isHidden = !cell.tapToEnableLabel.isHidden
				self.updateAssignedServices()
				
			}, handler2: nil)
		}
		
	}
	
}
