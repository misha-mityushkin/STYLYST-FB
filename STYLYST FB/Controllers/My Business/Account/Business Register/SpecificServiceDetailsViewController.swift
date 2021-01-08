//
//  SpecificServiceDetailsViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-08-11.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class SpecificServiceDetailsViewController: UIViewController {
	
	@IBOutlet weak var navigationBar: UINavigationBar!
	@IBOutlet weak var instructionLabel: UILabel!
	@IBOutlet weak var priceTextField: UITextField!
	@IBOutlet weak var timeTextField: UITextField!
	
	var assignServicesVC: AssignServicesViewController?
	var assignStaffVC: AssignStaffMembersViewController?
	
	var timePicker: UIPickerView?
	
	var hours = ["Hours", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
	var minutes = ["Minutes", "00", "05", "10", "15", "20", "25", "30", "35", "40", "45", "50", "55"]
	
	var selectedHour = "0"
	var selectedMinute = "00"
	
	var textFields: [UITextField] = []
	var textFieldsHoldAlert = [false, false]
	
	var reset = false

    override func viewDidLoad() {
        super.viewDidLoad()
		
		if #available(iOS 13.0, *) {
			isModalInPresentation = true
		}
		
		timePicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3))
		timePicker?.dataSource = self
		timePicker?.delegate = self
		timeTextField.inputView = timePicker
		
		textFields = [priceTextField, timeTextField]
		for textField in textFields {
			textField.delegate = self
			textField.addDoneButtonOnKeyboard()
		}
		UITextField.format(textFields: textFields, height: 40, padding: 10)
		
		if let assignStaffVC = assignStaffVC {
			let staffMember = assignStaffVC.addServiceVC?.servicesVC?.businessRegisterVC?.staffMembers[assignStaffVC.selectedIndex]
			let specificTimes = assignStaffVC.addServiceVC?.specificTimes
			let specificPrices = assignStaffVC.addServiceVC?.specificPrices
			
			let time = specificTimes?[staffMember?.userID ?? ""] ?? assignStaffVC.defaultTime
			let price = specificPrices?[staffMember?.userID ?? ""] ?? assignStaffVC.defaultPrice
			
			timeTextField.text = time ?? "0h 0min"
			priceTextField.text = String(format: "$%.02f", price ?? 0)
			
			let timeArr = Helpers.getTime(fromString: time ?? "0h 0min")
			let h = timeArr[0]
			let m = timeArr[1]
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
			
			instructionLabel.text = "Add a custom price and elapsed time for \"\(assignStaffVC.addServiceVC?.name ?? "this service")\" specifically for \(staffMember?.firstName ?? "this staff member") \(staffMember?.lastName ?? "")"
			
		} else if let assignServicesVC = assignServicesVC {
			let staffMember = assignServicesVC.addStaffMemberVC?.staffMember
			let service = assignServicesVC.addStaffMemberVC?.services[assignServicesVC.selectedIndex]
			let specificTimes = service?[K.Firebase.PlacesFieldNames.Services.specificTimes] as? [String : String]
			let specificPrices = service?[K.Firebase.PlacesFieldNames.Services.specificPrices] as? [String : Double]
			
			let time = specificTimes?[staffMember?.userID ?? ""] ?? service?[K.Firebase.PlacesFieldNames.Services.defaultTime] as? String
			let price = specificPrices?[staffMember?.userID ?? ""] ?? service?[K.Firebase.PlacesFieldNames.Services.defaultPrice] as? Double
			
			timeTextField.text = time ?? "0h 0min"
			priceTextField.text = String(format: "$%.02f", price ?? 0)
			
			let timeArr = Helpers.getTime(fromString: time ?? "0h 0min")
			let h = timeArr[0]
			let m = timeArr[1]
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
			
			instructionLabel.text = "Add a custom price and elapsed time for \"\(service?[K.Firebase.PlacesFieldNames.Services.name] ?? "this service")\" specifically for \(staffMember?.firstName ?? "this staff member") \(staffMember?.lastName ?? "")"
			
		} else {
			Alerts.showNoOptionAlert(title: "An error occurred", message: "Please restart the app and try again", sender: self) { (_) in
				self.dismiss(animated: true, completion: nil)
			}
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
	
	@IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		Alerts.showTwoOptionAlertDestructive(title: "Are you sure you want to exit?", message: "Your changes will not be saved", sender: self, option1: "Exit", option2: "Stay", is1Destructive: true, is2Destructive: false, handler1: { (_) in
			self.dismiss(animated: true, completion: nil)
		}, handler2: nil)
	}
	
	
	@IBAction func resetPressed(_ sender: UIButton) {
		reset = true
		Alerts.showTwoOptionAlert(title: "Reset Specific Details?", message: "Are you sure you want to reset these specific details to their defaults?", option1: "Reset", option2: "Cancel", sender: self, handler1: { (_) in
			if let assignStaffVC = self.assignStaffVC {
				self.priceTextField.text = String(format: "$%.02f", assignStaffVC.addServiceVC?.defaultPrice ?? 0)
				self.timeTextField.text = "\(assignStaffVC.addServiceVC?.defaultTime ?? "0h 0min")"
				if self.isValidInformation() {
					self.saveDetails()
				}
			} else if let assignServicesVC = self.assignServicesVC {
				let service = assignServicesVC.addStaffMemberVC?.services[assignServicesVC.selectedIndex]
				self.priceTextField.text = String(format: "$%.02f", service?[K.Firebase.PlacesFieldNames.Services.defaultPrice] as? Double ?? 0)
				self.timeTextField.text = "\(service?[K.Firebase.PlacesFieldNames.Services.defaultTime] as? String ?? "0h 0min")"
				if self.isValidInformation() {
					self.saveDetails()
				}
			} else {
				Alerts.showNoOptionAlert(title: "Unknown Error Occurred", message: "Please restart the app and try again", sender: self) { (_) in
					self.dismiss(animated: true, completion: nil)
				}
			}
		}, handler2: nil)
	}
	
	
	
	func isValidInformation() -> Bool {
		var isValid = true
		
		if let priceString = priceTextField.text, !priceString.isEmpty {
			if let priceDouble = Double(priceString.replacingOccurrences(of: "$", with: "")), priceDouble >= 0 {
				
			} else {
				isValid = false
				priceTextField.text = ""
				priceTextField.changePlaceholderText(to: "Invalid price", withColor: .systemRed)
				textFieldsHoldAlert[0] = true
			}
		} else {
			isValid = false
			priceTextField.text = ""
			priceTextField.changePlaceholderText(to: "You must provide a price", withColor: .systemRed)
			textFieldsHoldAlert[0] = true
		}
		
		if let timeString = timeTextField.text, !timeString.isEmpty {
			let timeArr = Helpers.getTime(fromString: timeString)
			if timeArr[0] <= 0 && timeArr[1] <= 0 {
				isValid = false
				timeTextField.text = ""
				timeTextField.changePlaceholderText(to: "Elapsed time must be greater than 0 minutes", withColor: .systemRed)
				textFieldsHoldAlert[1] = true
			}
		} else {
			isValid = false
			timeTextField.text = ""
			timeTextField.changePlaceholderText(to: "You must provide the elapsed time", withColor: .systemRed)
			textFieldsHoldAlert[1] = true
		}
		return isValid
	}
	
	
	@IBAction func savePressed(_ sender: UIButton) {
		reset = false
		Alerts.showTwoOptionAlert(title: "Edit Confirmation", message: "Are you sure you want to apply these changes?", option1: "Confirm", option2: "Cancel", sender: self, handler1: { (_) in
			self.saveDetails()
		}, handler2: nil)
	}
	
	func saveDetails() {
		if isValidInformation() {
			
			guard let price = Double((priceTextField.text ?? "0").replacingOccurrences(of: "$", with: "")), price >= 0 else { return }
			guard let time = timeTextField.text, !time.isEmpty else { return }
			
			if let assignStaffVC = assignStaffVC {
				
				if let staffMember = assignStaffVC.addServiceVC?.servicesVC?.businessRegisterVC?.staffMembers[assignStaffVC.selectedIndex] {
					
					if assignStaffVC.addServiceVC?.specificTimes == nil {
						assignStaffVC.addServiceVC?.specificTimes = [staffMember.userID : time]
					} else {
						assignStaffVC.addServiceVC?.specificTimes![staffMember.userID] = time
					}
					
					if assignStaffVC.addServiceVC?.specificPrices == nil {
						assignStaffVC.addServiceVC?.specificPrices = [staffMember.userID : price]
					} else {
						assignStaffVC.addServiceVC?.specificPrices![staffMember.userID] = price
					}
					
					if reset {
						Alerts.showNoOptionAlert(title: "Details Reset to Defaults", message: "The specific details for \"\(assignStaffVC.addServiceVC?.name ?? "this service")\" have been reset for \(staffMember.firstName) \(staffMember.lastName). It now takes \(time) and costs \(String(format: "$%.02f", price))", sender: self) { (_) in
							self.dismiss(animated: true, completion: nil)
						}
					} else {
						Alerts.showNoOptionAlert(title: "Details Updated", message: "\"\(assignStaffVC.addServiceVC?.name ?? "This service")\" now takes \(time) and costs \(String(format: "$%.02f", price)) specifically for \(staffMember.firstName) \(staffMember.lastName)", sender: self) { (_) in
							self.dismiss(animated: true, completion: nil)
						}
					}
					
				} else {
					Alerts.showNoOptionAlert(title: "Unknown Error Occurred", message: "Please restart the app and try again", sender: self) { (_) in
						self.dismiss(animated: true, completion: nil)
					}
				}
				
			} else if let assignServicesVC = assignServicesVC {
				
				if var service = assignServicesVC.addStaffMemberVC?.services[assignServicesVC.selectedIndex], let staffMember = assignServicesVC.addStaffMemberVC?.staffMember {
					
					var specificTimes = service[K.Firebase.PlacesFieldNames.Services.specificTimes] as? [String : String]
					var specificPrices = service[K.Firebase.PlacesFieldNames.Services.specificPrices] as? [String : Double]
					
					if specificTimes == nil {
						specificTimes = [staffMember.userID : time]
					} else {
						specificTimes![staffMember.userID] = time
					}
					
					if specificPrices == nil {
						specificPrices = [staffMember.userID : price]
					} else {
						specificPrices![staffMember.userID] = price
					}
					
					service[K.Firebase.PlacesFieldNames.Services.specificTimes] = specificTimes
					service[K.Firebase.PlacesFieldNames.Services.specificPrices] = specificPrices
					assignServicesVC.addStaffMemberVC?.services[assignServicesVC.selectedIndex] = service
					
					if reset {
						Alerts.showNoOptionAlert(title: "Details Reset to Defaults", message: "The specific details for \"\(service[K.Firebase.PlacesFieldNames.Services.name] ?? "this service")\" have been reset for \(staffMember.firstName) \(staffMember.lastName). It now takes \(time) and costs \(String(format: "$%.02f", price))", sender: self) { (_) in
							self.dismiss(animated: true, completion: nil)
						}
					} else {
						Alerts.showNoOptionAlert(title: "Details Updated", message: "\"\(service[K.Firebase.PlacesFieldNames.Services.name] ?? "This service")\" now takes \(time) and costs \(String(format: "$%.02f", price)) specifically for \(staffMember.firstName) \(staffMember.lastName)", sender: self) { (_) in
							self.dismiss(animated: true, completion: nil)
						}
					}
					
				} else {
					Alerts.showNoOptionAlert(title: "Unknown Error Occurred", message: "Please restart the app and try again", sender: self) { (_) in
						self.dismiss(animated: true, completion: nil)
					}
				}
				
			} else {
				Alerts.showNoOptionAlert(title: "Unknown Error Occurred", message: "Please restart the app and try again", sender: self) { (_) in
					self.dismiss(animated: true, completion: nil)
				}
			}
			
		}
	}
	
	
}





extension SpecificServiceDetailsViewController: UITextFieldDelegate {
	func textFieldDidEndEditing(_ textField: UITextField) {
		if textField == priceTextField {
			if let priceDouble = Double(priceTextField.text?.replacingOccurrences(of: "$", with: "") ?? "0") {
				priceTextField.text = String(format: "$%.02f", priceDouble)
			}
		} else if textField == timeTextField {
			
		}
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		if textField == priceTextField {
			textField.changePlaceholderText(to: "Price")
		} else if textField == timeTextField {
			textField.changePlaceholderText(to: "Elapsed time")
		}
	}
}





extension SpecificServiceDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
	
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
