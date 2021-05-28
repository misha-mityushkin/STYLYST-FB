//
//  AddStaffMemberViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-07-31.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import FirebaseFirestore

class AddStaffMemberViewController: UIViewController {
	
	@IBOutlet weak var navigationBar: UINavigationBar!
	@IBOutlet weak var deleteButton: UIBarButtonItem!
	
	@IBOutlet weak var titleLabel: UILabel!
	
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var personalCodeTextField: UITextField!
	
	@IBOutlet weak var separator1: UIView!
	@IBOutlet weak var separator2: UIView!
	@IBOutlet weak var userInfoStackview: UIStackView!
	@IBOutlet weak var infoLabel: UILabel!
	@IBOutlet weak var saveButton: UIButton!
	
	@IBOutlet weak var firstNameLabel: UILabel!
	@IBOutlet weak var lastNameLabel: UILabel!
	@IBOutlet weak var emailLabel: UILabel!
	@IBOutlet weak var phoneNumberLabel: UILabel!
	
	let spinnerView = LoadingView()
	
	var textFields: [UITextField] = []
	var textFieldsHoldAlert = [false, false]
	
	var staffMembersVC: StaffMembersTableViewController?
	var isEditStaffMember = false
	var selectedIndex = 0
	
	var staffMember: User?
	
	var services: [Service] = []
	var weeklyHours: [String : [String]]?
	var specificHours: [String : [String]]?
	
	var assignedServices = false

    override func viewDidLoad() {
        super.viewDidLoad()
		
		if #available(iOS 13.0, *) {
			isModalInPresentation = true
		}
		
		showHideUserInfo(show: false)
		
		textFields = [emailTextField, personalCodeTextField]
		for textField in textFields {
			textField.delegate = self
		}
		UITextField.format(textFields: textFields, height: 40, padding: 10)
		
		services = (staffMembersVC?.businessRegisterVC?.services ?? []).sorted(by: { service1, service2 in
			return service1.name < service2.name
		})
		
		if isEditStaffMember {
			titleLabel.text = "Edit Staff Member"
			
			deleteButton.isEnabled = true
			deleteButton.tintColor = .red
			
			showHideUserInfo(show: true)
			
			staffMember = staffMembersVC?.staffMembers?[selectedIndex]
			emailTextField.text = staffMember?.email
			personalCodeTextField.text = staffMember?.personalCode
			firstNameLabel.text = "First Name: \(staffMember?.firstName ?? "Unknown Name")"
			lastNameLabel.text = "Last Name: \(staffMember?.lastName ?? "")"
			emailLabel.text = "Email: \(staffMember?.email ?? "Unknown Email")"
			phoneNumberLabel.text = "Phone Number: \(Helpers.format(phoneNumber: staffMember?.phoneNumber ?? "0000000000"))"
			
			weeklyHours = staffMembersVC?.businessRegisterVC?.staffWeeklyHours?[staffMember?.userID ?? ""]
			specificHours = staffMembersVC?.businessRegisterVC?.staffSpecificHours?[staffMember?.userID ?? ""]
			assignedServices = true
		} else {
			titleLabel.text = "Add Staff Member"
			deleteButton.isEnabled = false
		}
		hideKeyboardWhenTappedAround()
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationBar.makeTransparent()
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		var nonAlteredTextFields: [UITextField] = []
		for i in 0..<textFieldsHoldAlert.count {
			if !textFieldsHoldAlert[i] {
				nonAlteredTextFields.append(textFields[i])
			}
		}
		UITextField.formatBackground(textFields: textFields, height: 40, padding: 10)
		UITextField.formatPlaceholder(textFields: nonAlteredTextFields, height: 40, padding: 10)
	}
	
	func showHideUserInfo(show: Bool) {
		var alpha: CGFloat = 0
		if show {
			alpha = 1
		}
		separator1.alpha = alpha
		separator2.alpha = alpha
		userInfoStackview.alpha = alpha
		infoLabel.alpha = alpha
		saveButton.alpha = alpha
	}
	
	@IBAction func infoPressed(_ sender: UIButton) {
		Alerts.showNoOptionAlert(title: "Add Staff Member Info", message: "Your staff members must already have a STYLYST account. Ask them for the email address they used to create their account as well as their personal identifier code so we can look them up. You can add yourself as a staff member using the same process.", sender: self)
	}
	
	
	@IBAction func lookUpUserPressed(_ sender: UIButton) {
		hideKeyboard()
		var isValid = true
		
		if let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty {
			if !email.isValidEmail() {
				isValid = false
				emailTextField.text = ""
				emailTextField.changePlaceholderText(to: "Invalid email", withColor: .systemRed)
				textFieldsHoldAlert[0] = true
			}
		} else {
			isValid = false
			emailTextField.text = ""
			emailTextField.changePlaceholderText(to: "Enter the staff member's email", withColor: .systemRed)
			textFieldsHoldAlert[0] = true
		}
		if let personalCode = personalCodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !personalCode.isEmpty {
			if !personalCode.isValidPersonalCode() {
				personalCodeTextField.text = ""
				personalCodeTextField.changePlaceholderText(to: "Personal codes are 4 digit numbers", withColor: .systemRed)
				isValid = false
				textFieldsHoldAlert[1] = true
			}
		} else {
			isValid = false
			personalCodeTextField.text = ""
			personalCodeTextField.changePlaceholderText(to: "Enter the staff member's personal code", withColor: .systemRed)
			textFieldsHoldAlert[1] = true
		}
		
		
		if isValid {
			spinnerView.create(parentVC: self)
			spinnerView.label.text = "Looking up..."
			guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty else {
				spinnerView.remove()
				Alerts.showNoOptionAlert(title: "Error", message: "Please try re-entering the information and try again", sender: self)
				return
			}
			guard let code = personalCodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !code.isEmpty, code.isValidPersonalCode() else {
				spinnerView.remove()
				Alerts.showNoOptionAlert(title: "Error", message: "Please try re-entering the information and try again", sender: self)
				return
			}
			
			Firestore.firestore().collection(K.Firebase.CollectionNames.users).whereField(K.Firebase.UserFieldNames.email, isEqualTo: email).getDocuments { (snapshot, error) in
				if let error = error {
					self.spinnerView.remove()
					Alerts.showNoOptionAlert(title: "Error", message: "We were unable to search up the user with email \"\(email)\". Error description: \(error.localizedDescription)", sender: self)
				} else {
					self.spinnerView.remove()
					if let documents = snapshot?.documents, !documents.isEmpty {
						let document = documents.first!
						let firstName = document.get(K.Firebase.UserFieldNames.firstName) as? String ?? "Unknown First Name"
						let lastName = document.get(K.Firebase.UserFieldNames.lastName) as? String ?? "Unknown Last Name"
						let phoneNumber = document.get(K.Firebase.UserFieldNames.phoneNumber) as? String ?? "Unknown Phone Number"
						let personalCode = document.get(K.Firebase.UserFieldNames.personalCode) as? String
						
						if code == personalCode {
							
							var staffMemberExists = false
							for existingStaffMember in self.staffMembersVC?.staffMembers ?? [] {
								if existingStaffMember.userID == document.documentID {
									staffMemberExists = true
								}
							}
							if staffMemberExists {
								Alerts.showNoOptionAlert(title: "Duplicate Staff Member", message: "You have already added \(firstName) \(lastName)", sender: self)
								return
							}
							
							for i in 0..<self.services.count {
								var staffIDs = self.services[i].assignedStaff
								if let indexToRemove =  staffIDs.firstIndex(of: self.staffMember?.userID ?? "") { //does the current staff member appear in any services?
									staffIDs.remove(at: indexToRemove)
									self.services[i].assignedStaff = staffIDs
								}
							}
							
							self.assignedServices = false
							self.staffMember = User(userID: document.documentID, data: document.data())
							
							if self.userInfoStackview.alpha < 1 {
								self.firstNameLabel.text = "First Name: \(firstName)"
								self.lastNameLabel.text = "Last Name: \(lastName)"
								self.emailLabel.text = "Email: \(email)"
								self.phoneNumberLabel.text = "Phone Number: \(Helpers.format(phoneNumber: phoneNumber))"
								UIView.animate(withDuration: 0.7) {
									self.showHideUserInfo(show: true)
								}
							} else {
								UIView.animate(withDuration: 0.7) {
									self.showHideUserInfo(show: false)
								} completion: { (_) in
									self.firstNameLabel.text = "First Name: \(firstName)"
									self.lastNameLabel.text = "Last Name: \(lastName)"
									self.emailLabel.text = "Email: \(email)"
									self.phoneNumberLabel.text = "Phone Number: \(Helpers.format(phoneNumber: phoneNumber))"
									UIView.animate(withDuration: 0.7) {
										self.showHideUserInfo(show: true)
									}
								}
								
							}
							
						} else {
							Alerts.showNoOptionAlert(title: "Invalid Personal Code", message: "Please confirm their personal code with them and try again", sender: self)
						}
						
					} else {
						Alerts.showNoOptionAlert(title: "User not found", message: "We were unable to find a user with email \"\(email)\"", sender: self)
					}
				}
			}
		}
	}
	
	func saveStaffMember() {
		if let staffMember = staffMember {
			
			staffMembersVC?.businessRegisterVC?.services = services
			if staffMembersVC?.businessRegisterVC?.staffWeeklyHours == nil {
				staffMembersVC?.businessRegisterVC?.staffWeeklyHours = [staffMember.userID : weeklyHours!]
			} else {
				staffMembersVC?.businessRegisterVC?.staffWeeklyHours?[staffMember.userID] = weeklyHours!
			}
			
			if let specificHours = specificHours {
				if staffMembersVC?.businessRegisterVC?.staffSpecificHours == nil {
					staffMembersVC?.businessRegisterVC?.staffSpecificHours = [staffMember.userID : specificHours]
				} else {
					staffMembersVC?.businessRegisterVC?.staffSpecificHours?[staffMember.userID] = specificHours
				}
			}
			
			if isEditStaffMember {
				staffMembersVC?.staffMembers?[selectedIndex] = staffMember
				Alerts.showNoOptionAlert(title: "Staff Member Updated", message: "\"\(staffMember.firstName)\" has been updated", sender: self) { (_) in
					self.dismiss(animated: true, completion: self.staffMembersVC?.updateStaff)
				}
			} else {
				staffMembersVC?.staffMembers?.append(staffMember)
				Alerts.showNoOptionAlert(title: "Staff Member Added", message: "\"\(staffMember.firstName)\" has been added", sender: self) { (_) in
					self.dismiss(animated: true, completion: self.staffMembersVC?.updateStaff)
				}
			}
			
		}
	}
	
	@IBAction func savePressed(_ sender: UIButton) {
		if let staffMember = staffMember {
			
			if let weeklyHours = weeklyHours {
				var allDaysSpecified = true
				var unspecifiedDays: [String] = []
				for i in 0..<K.Collections.daysOfTheWeekIdentifiers.count {
					let dayOfTheWeekIdentifier = K.Collections.daysOfTheWeekIdentifiers[i]
					if weeklyHours[dayOfTheWeekIdentifier] == nil || weeklyHours[dayOfTheWeekIdentifier]?.isEmpty ?? true {
						allDaysSpecified = false
						unspecifiedDays.append(K.Collections.daysOfTheWeek[i])
					}
				}
				
				if allDaysSpecified {
					if assignedServices || services.isEmpty {
						saveStaffMember()
					} else {
						Alerts.showTwoOptionAlert(title: "Services Not Assigned", message: "You have not assigned any services to \(staffMember.firstName). Are you sure you wish to continue?", option1: "Continue", option2: "Go Back", sender: self, handler1: { (_) in
							self.saveStaffMember()
						}, handler2: nil)
					}
				} else {
					var missingDaysString = ""
					for i in 0..<unspecifiedDays.count - 1 {
						missingDaysString.append("\(unspecifiedDays[i]), ")
					}
					missingDaysString.append("and \(unspecifiedDays[unspecifiedDays.count - 1])")
					Alerts.showNoOptionAlert(title: "Missing Working Hours", message: "You must specify \(staffMember.firstName)'s working hours for each day of the week. You are missing working hours for \(missingDaysString)", sender: self)
				}
				
			} else {
				Alerts.showNoOptionAlert(title: "Missing Working Hours", message: "You must specify \(staffMember.firstName)'s working hours.", sender: self)
			}
			
		} else {
			Alerts.showNoOptionAlert(title: "No User Selected", message: "You must find a user to add as a staff member", sender: self)
		}
	}
	
	@IBAction func assignServicesPressed(_ sender: UIButton) {
		if staffMember != nil {
			performSegue(withIdentifier: K.Segues.addStaffMemberToAssignServices, sender: self)
		} else {
			Alerts.showNoOptionAlert(title: "No User Selected", message: "You must find a user to add as a staff member", sender: self)
		}
	}
	
	@IBAction func setWorkingHoursPressed(_ sender: UIButton) {
		if staffMember != nil {
			performSegue(withIdentifier: K.Segues.addStaffMemberToStaffWorkingHours, sender: self)
		} else {
			Alerts.showNoOptionAlert(title: "No User Selected", message: "You must find a user to add as a staff member", sender: self)
		}
	}
	
	
	
	
	@IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		Alerts.showTwoOptionAlertDestructive(title: "Are you sure you want to exit?", message: "Your changes will not be saved", sender: self, option1: "Exit", option2: "Stay", is1Destructive: true, is2Destructive: false, handler1: { (_) in
			self.dismiss(animated: true, completion: nil)
		}, handler2: nil)
	}
	
	
	@IBAction func deletePressed(_ sender: UIBarButtonItem) {
		Alerts.showTwoOptionAlertDestructive(title: "Delete Confirmation", message: "Are you sure you want to delete this staff member?", sender: self, option1: "Delete", option2: "Cancel", is1Destructive: true, is2Destructive: false, handler1: { (_) in
			
			for i in 0..<self.services.count {
				
				var staffIDs = self.services[i].assignedStaff
				
				if let indexToRemove =  staffIDs.firstIndex(of: self.staffMember?.userID ?? "") { //does the current staff member appear in any services?
					var specifitTimes = self.services[i].specificTimes
					var specifitPrices = self.services[i].specificPrices
					specifitTimes[self.staffMember?.userID ?? ""] = nil
					specifitPrices[self.staffMember?.userID ?? ""] = nil
					
					staffIDs.remove(at: indexToRemove) //remove reference to staff member
					self.services[i].assignedStaff = staffIDs // update the staff array
					self.services[i].specificTimes = specifitTimes // update specific times
					self.services[i].specificPrices = specifitPrices // update specific prices
				}
				
			}
			self.staffMembersVC?.staffMembers?.remove(at: self.selectedIndex)
			self.staffMembersVC?.businessRegisterVC?.services = self.services
			self.dismiss(animated: true, completion: self.staffMembersVC?.updateStaff)
		}, handler2: nil)
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is AssignServicesViewController {
			(segue.destination as! AssignServicesViewController).addStaffMemberVC = self
		} else if (segue.destination as? UINavigationController)?.viewControllers.first is StaffWorkingHoursViewController {
			((segue.destination as! UINavigationController).viewControllers.first as! StaffWorkingHoursViewController).addStaffMemberVC = self
		}
	}

}


extension AddStaffMemberViewController: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		if textField == emailTextField {
			textField.changePlaceholderText(to: "Staff member email")
		} else if textField == personalCodeTextField {
			textField.changePlaceholderText(to: "Staff member personal code")
		}
	}
}



extension AddStaffMemberViewController: UIScrollViewDelegate {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		if scrollView.contentOffset.y >= titleLabel.frame.maxY {
			if navigationBar.topItem?.title != titleLabel.text {
				navigationBar.topItem?.title = titleLabel.text
			}
		} else {
			if navigationBar.topItem?.title == titleLabel.text {
				navigationBar.topItem?.title = nil
			}
		}
		
	}
	
}
