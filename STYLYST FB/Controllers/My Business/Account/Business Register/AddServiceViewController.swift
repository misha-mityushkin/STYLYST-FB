//
//  AddServiceViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-07-23.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class AddServiceViewController: UIViewController {
	
	@IBOutlet weak var navigationBar: UINavigationBar!
	@IBOutlet weak var enabledSwitch: UISwitch!
	@IBOutlet weak var deleteButton: UIBarButtonItem!
	
	@IBOutlet weak var titleLabel: UILabel!
	
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var descriptionTextField: UITextField!
	@IBOutlet weak var priceTextField: UITextField!
	@IBOutlet weak var timeTextField: UITextField!
	
	@IBOutlet weak var timeAndPricesInfoLabel: UILabel!
	
	var timePicker: UIPickerView?
	
	var hours = ["Hours", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
	var minutes = ["Minutes", "00", "05", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]
	
	var selectedHour = "0"
	var selectedMinute = "00"
	
	var textFields: [UITextField] = []
	var textFieldsHoldAlert = [false, false, false, false]
	
	var name: String?
	var defaultTime: String?
	var defaultPrice: Double?
	
	var didAssignStaff = false
	var assignedStaff: [String] = []
	var specificTimes: [String : String]?
	var specificPrices: [String : Double]?
	
	var servicesVC: ServicesTableViewController?
	var isEditService = false
	var selectedIndex = 0
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		if #available(iOS 13.0, *) {
			isModalInPresentation = true
		}
		
		enabledSwitch.layer.cornerRadius = enabledSwitch.frame.height / 2
		
		timePicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3))
		timePicker?.dataSource = self
		timePicker?.delegate = self
		timeTextField.inputView = timePicker

		textFields = [nameTextField, descriptionTextField, priceTextField, timeTextField]
		for textField in textFields {
			textField.delegate = self
			textField.addDoneButtonOnKeyboard()
		}
		UITextField.format(textFields: textFields, height: 40, padding: 10)
		
		for recognizer in timeTextField.gestureRecognizers ?? [] {
			if recognizer is UILongPressGestureRecognizer {
				recognizer.isEnabled = false
			}
		}
		
		let imageAttachment = NSTextAttachment()
		if #available(iOS 13.0, *) {
			imageAttachment.image = UIImage(systemName: K.ImageNames.ellipsis)?.withRenderingMode(.alwaysTemplate).withTintColor(K.Colors.goldenThemeColorInverse ?? UIColor.black)
		} else {
			imageAttachment.image = UIImage(named: K.ImageNames.ellipsis)?.withRenderingMode(.alwaysTemplate)
		}
		let fullString = NSMutableAttributedString(string: "You can set specific times and prices for each staff member in Assign Staff, ")
		fullString.append(NSAttributedString(attachment: imageAttachment))
		timeAndPricesInfoLabel.attributedText = fullString
		
		if isEditService {
			titleLabel.text = "Edit Service"
			deleteButton.isEnabled = true
			deleteButton.tintColor = .red
			
			let service = servicesVC?.services?[selectedIndex]
			
			enabledSwitch.isOn = service?[K.Firebase.PlacesFieldNames.Services.enabled] as? Bool ?? true
			nameTextField.text = service?[K.Firebase.PlacesFieldNames.Services.name] as? String ?? "Unknown Name"
			descriptionTextField.text = service?[K.Firebase.PlacesFieldNames.Services.description] as? String
			
			let defaultPrice = service?[K.Firebase.PlacesFieldNames.Services.defaultPrice] as? Double ?? 0.0
			priceTextField.text = String(format: "$%.02f", defaultPrice)
			let defaultTime = service?[K.Firebase.PlacesFieldNames.Services.defaultTime] as? String ?? "0h 0min"
			timeTextField.text = defaultTime
			
			let time = Helpers.getTime(fromString: defaultTime)
			let h = time[0]
			let m = time[1]
			for i in 0..<hours.count {
				if Int(hours[i]) == h {
					timePicker?.selectRow(i, inComponent: 0, animated: false)
					selectedHour = hours[i]
					break
				}
			}
			for i in 0..<minutes.count {
				if Int(minutes[i]) == m {
					timePicker?.selectRow(i, inComponent: 1, animated: false)
					selectedMinute = minutes[i]
					break
				}
			}
			
			assignedStaff = service?[K.Firebase.PlacesFieldNames.Services.staff] as? [String] ?? []
			didAssignStaff = true
			
			specificTimes = service?[K.Firebase.PlacesFieldNames.Services.specificTimes] as? [String : String]
			specificPrices = service?[K.Firebase.PlacesFieldNames.Services.specificPrices] as? [String : Double]
			updateTimesAndPrices()
			
		} else {
			titleLabel.text = "Add Service"
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
	
	
	@IBAction func enabledSwitchFlipped(_ sender: UISwitch) {
		if enabledSwitch.isOn {
			Alerts.showNoOptionAlert(title: "Service Enabled", message: "\(name ?? "This service") is now enabled and will be available for appointment booking", sender: self)
		} else {
			Alerts.showNoOptionAlert(title: "Service Disabled", message: "\(name ?? "This service") is now disabled and will not be available for appointment booking", sender: self)
		}
	}
	
	
	@IBAction func assignStaffPressed(_ sender: UIButton) {
		print("assignStaffPressed")
		hideKeyboard()
		if isValidInformation() {
			updateTimesAndPrices()
			performSegue(withIdentifier: K.Segues.addServiceToAssignStaff, sender: self)
		}
	}
	
	
	func saveService() {
		guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else { return }
		guard let defaultPrice = Double((priceTextField.text ?? "0").replacingOccurrences(of: "$", with: "")), defaultPrice >= 0 else { return }
		guard let defaultTime = timeTextField.text, !defaultTime.isEmpty else { return }
		
		updateTimesAndPrices()
		
		for uid in assignedStaff {
			print("specific time for \(uid) : \(specificTimes?[uid] ?? "no specific time")")
			print("specific price for \(uid) : \(specificPrices?[uid] ?? 0)")
		}
		
		let service: [String : Any] = [
			K.Firebase.PlacesFieldNames.Services.enabled: enabledSwitch.isOn,
			K.Firebase.PlacesFieldNames.Services.name: name,
			K.Firebase.PlacesFieldNames.Services.defaultPrice: defaultPrice,
			K.Firebase.PlacesFieldNames.Services.specificPrices: specificPrices ?? [String : Double](),
			K.Firebase.PlacesFieldNames.Services.defaultTime: defaultTime,
			K.Firebase.PlacesFieldNames.Services.specificTimes: specificTimes ?? [String : String](),
			K.Firebase.PlacesFieldNames.Services.description: descriptionTextField.text ?? "",
			K.Firebase.PlacesFieldNames.Services.staff: assignedStaff
		]
		
		if isEditService {
			servicesVC?.services?[selectedIndex] = service
			Alerts.showNoOptionAlert(title: "Service Updated", message: "\"\(name)\" has been updated", sender: self) { (_) in
				self.dismiss(animated: true, completion: self.servicesVC?.updateServices)
			}
		} else {
			servicesVC?.services?.append(service)
			Alerts.showNoOptionAlert(title: "Service Added", message: "\"\(name)\" has been added", sender: self) { (_) in
				self.dismiss(animated: true, completion: self.servicesVC?.updateServices)
			}
		}
	}
	
	func updateTimesAndPrices() {
		guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else { return }
		guard let defaultPrice = Double((priceTextField.text ?? "0").replacingOccurrences(of: "$", with: "")), defaultPrice >= 0 else { return }
		guard let defaultTime = timeTextField.text, !defaultTime.isEmpty else { return }
		
		self.name = name
		self.defaultTime = defaultTime
		self.defaultPrice = defaultPrice
		
		if assignedStaff.count > 0 && specificTimes == nil {
			specificTimes = [assignedStaff.first! : defaultTime]
			for i in 1..<assignedStaff.count {
				specificTimes?[assignedStaff[i]] = defaultTime
			}
		}
		
		if assignedStaff.count > 0 && specificPrices == nil {
			specificPrices = [assignedStaff.first! : defaultPrice]
			for i in 1..<assignedStaff.count {
				specificPrices?[assignedStaff[i]] = defaultPrice
			}
		}
		
	}
	
	func updateDefaultTime() {
		print("update default time")
		guard let defaultTime = timeTextField.text, !defaultTime.isEmpty else { return }
		if defaultTime != self.defaultTime {
			if assignedStaff.count > 0 {
				Alerts.showNoOptionAlert(title: "Default Time Changed", message: "All staff-specific times have been reset to \(defaultTime)", sender: self)
				if specificTimes == nil {
					specificTimes = [assignedStaff.first! : defaultTime]
					for i in 1..<assignedStaff.count {
						specificTimes?[assignedStaff[i]] = defaultTime
					}
				} else {
					for i in 0..<assignedStaff.count {
						specificTimes?[assignedStaff[i]] = defaultTime
					}
				}
			}
		}
		updateTimesAndPrices()
	}
	func updateDefaultPrice() {
		print("update default price")
		guard let defaultPrice = Double((priceTextField.text ?? "0").replacingOccurrences(of: "$", with: "")), defaultPrice >= 0 else { return }
		if defaultPrice != self.defaultPrice {
			if assignedStaff.count > 0 {
				Alerts.showNoOptionAlert(title: "Default Price Changed", message: "All staff-specific prices have been reset to \(String(format: "$%.02f", defaultPrice))", sender: self)
				if specificPrices == nil {
					specificPrices = [assignedStaff.first! : defaultPrice]
					for i in 1..<assignedStaff.count {
						specificPrices?[assignedStaff[i]] = defaultPrice
					}
				} else {
					for i in 0..<assignedStaff.count {
						specificPrices?[assignedStaff[i]] = defaultPrice
					}
				}
			}
		}
		updateTimesAndPrices()
	}
	
	
	func isValidInformation() -> Bool {
		var isValid = true
		
		if nameTextField.text == nil || nameTextField.text!.isEmpty {
			isValid = false
			nameTextField.text = ""
			nameTextField.changePlaceholderText(to: "You must provide the name of the service", withColor: .systemRed)
			textFieldsHoldAlert[0] = true
		}
		
		if let priceString = priceTextField.text, !priceString.isEmpty {
			if let priceDouble = Double(priceString.replacingOccurrences(of: "$", with: "")), priceDouble >= 0 {
				
			} else {
				isValid = false
				priceTextField.text = ""
				priceTextField.changePlaceholderText(to: "Invalid price", withColor: .systemRed)
				textFieldsHoldAlert[2] = true
			}
		} else {
			isValid = false
			priceTextField.text = ""
			priceTextField.changePlaceholderText(to: "You must provide a price", withColor: .systemRed)
			textFieldsHoldAlert[2] = true
		}
		
		if let timeString = timeTextField.text, !timeString.isEmpty {
			let timeArr = Helpers.getTime(fromString: timeString)
			if timeArr[0] <= 0 && timeArr[1] <= 0 {
				isValid = false
				timeTextField.text = ""
				timeTextField.changePlaceholderText(to: "Elapsed time must be greater than 0 minutes", withColor: .systemRed)
				textFieldsHoldAlert[3] = true
			}
		} else {
			isValid = false
			timeTextField.text = ""
			timeTextField.changePlaceholderText(to: "You must provide the elapsed time", withColor: .systemRed)
			textFieldsHoldAlert[3] = true
		}
		return isValid
	}
	
	
	@IBAction func donePressed(_ sender: UIButton) {
		hideKeyboard()
		if isValidInformation() {
			updateTimesAndPrices()
			
			var serviceExists = false
			if !isEditService {
				for existingService in servicesVC?.services ?? [] {
					if (existingService[K.Firebase.PlacesFieldNames.Services.name] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) == nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
						serviceExists = true
					}
				}
			}
			
			if serviceExists {
				Alerts.showTwoOptionAlert(title: "Duplicate Service", message: "You have already added a service called \"\(nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")\". Are you sure you want to proceed?", option1: "Proceed", option2: "Cancel", sender: self, handler1: { (_) in
					
					if self.didAssignStaff || self.servicesVC?.businessRegisterVC?.staffMembers.isEmpty ?? true {
						self.saveService()
					} else {
						Alerts.showTwoOptionAlert(title: "Staff Members Not Assigned", message: "You have not assigned any staff members to  \(self.nameTextField.text ?? "this service"). Are you sure you wish to continue?", option1: "Continue", option2: "Cancel", sender: self, handler1: { (_) in
							self.saveService()
						}, handler2: nil)
					}
					
				}, handler2: nil)
			} else {
				if didAssignStaff || servicesVC?.businessRegisterVC?.staffMembers.isEmpty ?? true {
					saveService()
				} else {
					Alerts.showTwoOptionAlert(title: "Staff Members Not Assigned", message: "You have not assigned any staff members to \(nameTextField.text ?? "this service"). Are you sure you wish to continue?", option1: "Continue", option2: "Cancel", sender: self, handler1: { (_) in
						self.saveService()
					}, handler2: nil)
				}
			}
		}
	}
	
	@IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		Alerts.showTwoOptionAlertDestructive(title: "Are you sure you want to exit?", message: "Your changes will not be saved", sender: self, option1: "Exit", option2: "Stay", is1Destructive: true, is2Destructive: false, handler1: { (_) in
			self.dismiss(animated: true, completion: nil)
		}, handler2: nil)
	}
	
	@IBAction func deletePressed(_ sender: UIBarButtonItem) {
		Alerts.showTwoOptionAlertDestructive(title: "Delete Confirmation", message: "Are you sure you want to delete this service?", sender: self, option1: "Delete", option2: "Cancel", is1Destructive: true, is2Destructive: false, handler1: { (_) in
			self.servicesVC?.services?.remove(at: self.selectedIndex)
			self.dismiss(animated: true, completion: self.servicesVC?.updateServices)
		}, handler2: nil)
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		print("prepare for segue")
		if segue.destination is AssignStaffMembersViewController {
			let assignStaffVC = segue.destination as! AssignStaffMembersViewController
			assignStaffVC.addServiceVC = self
			assignStaffVC.defaultTime = defaultTime
			assignStaffVC.defaultPrice = defaultPrice
		}
	}
	
	
	@IBAction func priceDidChange(_ sender: UITextField) {
		//updateDefaultPrice()
	}
	
	
	
}




extension AddServiceViewController: UITextFieldDelegate {
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		print("didendediting")
		if textField == priceTextField {
			if let priceDouble = Double(priceTextField.text?.replacingOccurrences(of: "$", with: "") ?? "0") {
				priceTextField.text = String(format: "$%.02f", priceDouble)
				updateDefaultPrice()
			}
		} else if textField == timeTextField {
			
		}
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		if textField == nameTextField {
			textField.changePlaceholderText(to: "Service name")
		} else if textField == priceTextField {
			textField.changePlaceholderText(to: "Price")
		} else if textField == timeTextField {
			textField.changePlaceholderText(to: "Elapsed time")
		}
	}
}




extension AddServiceViewController: UIPickerViewDelegate, UIPickerViewDataSource {
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if component == 0 {
			selectedHour = hours[row]
		} else if component == 1 {
			selectedMinute = minutes[row]
		}
		if pickerView.selectedRow(inComponent: 0) != 0 && pickerView.selectedRow(inComponent: 1) != 0 {
			let numHours = Int(selectedHour)
			let numMinutes = Int(selectedMinute)
			timeTextField.text = "\(numHours ?? 0)h \(numMinutes ?? 00)min"
			updateDefaultTime()
		}
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 2
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if component == 0 {
			return hours.count
		} else if component == 1 {
			return minutes.count
		} else {
			return 0
		}
	}
	
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if component == 0 {
			return hours[row]
		} else if component == 1 {
			return minutes[row]
		} else {
			return ""
		}
	}
	
}
