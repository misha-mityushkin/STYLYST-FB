//
//  AddStaffSpecificDateViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-09-05.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class AddStaffSpecificDateViewController: UIViewController {

	@IBOutlet weak var navigationBar: UINavigationBar!
	@IBOutlet weak var deleteButton: UIBarButtonItem!
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var dateTextField: UITextField!
	@IBOutlet weak var openSwitch: UISwitch!
	
	@IBOutlet weak var hoursStackView1: UIStackView!
	@IBOutlet weak var openTimeTextField1: UITextField!
	@IBOutlet weak var closeTimeTextField1: UITextField!
	
	@IBOutlet weak var addRemoveShiftButton: UIButton!
	
	@IBOutlet weak var hoursStackView2: UIStackView!
	@IBOutlet weak var openTimeTextField2: UITextField!
	@IBOutlet weak var closeTimeTextField2: UITextField!
	
	@IBOutlet weak var instructionsLabel: UILabel!
	
	
	var staffSpecificDatesVC: StaffSpecificDatesTableViewController?
	var isEditSpecificDate = false
	var selectedIndex = 0
	
	var datePicker: UIDatePicker?
	
	var openTimePicker1: UIDatePicker?
	var closeTimePicker1: UIDatePicker?
	
	var openTimePicker2: UIDatePicker?
	var closeTimePicker2: UIDatePicker?
	
	var textFields: [UITextField] = []
	var textFieldsHoldAlert = [false, false, false, false, false]
	
	var originalDateString = ""
		
	var staffMember: User?
	
	var secondShiftExists = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if #available(iOS 13.0, *) {
			isModalInPresentation = true
		}
		
		textFields = [dateTextField, openTimeTextField1, closeTimeTextField1, openTimeTextField2, closeTimeTextField2]
		for textField in textFields {
			textField.delegate = self
			textField.addDoneButtonOnKeyboard()
		}
		UITextField.format(textFields: textFields, height: 40, padding: 10)
		
		openSwitch.layer.cornerRadius = openSwitch.frame.height / 2
		
		datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3))
		openTimePicker1 = UIDatePicker(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3))
		closeTimePicker1 = UIDatePicker(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3))
		openTimePicker2 = UIDatePicker(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3))
		closeTimePicker2 = UIDatePicker(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3))
		
		datePicker?.datePickerMode = .date
		
		openTimePicker1?.datePickerMode = .time
		closeTimePicker1?.datePickerMode = .time
		openTimePicker2?.datePickerMode = .time
		closeTimePicker2?.datePickerMode = .time
		
		openTimePicker1?.minuteInterval = 5
		closeTimePicker1?.minuteInterval = 5
		openTimePicker2?.minuteInterval = 5
		closeTimePicker2?.minuteInterval = 5
		
		if #available(iOS 13.4, *) {
			datePicker?.preferredDatePickerStyle = .wheels
			openTimePicker1?.preferredDatePickerStyle = .wheels
			closeTimePicker1?.preferredDatePickerStyle = .wheels
			openTimePicker2?.preferredDatePickerStyle = .wheels
			closeTimePicker2?.preferredDatePickerStyle = .wheels
		}
		
		datePicker?.addTarget(self, action: #selector(dateOrTimeUpdated(_:)), for: .valueChanged)
		openTimePicker1?.addTarget(self, action: #selector(dateOrTimeUpdated(_:)), for: .valueChanged)
		closeTimePicker1?.addTarget(self, action: #selector(dateOrTimeUpdated(_:)), for: .valueChanged)
		openTimePicker2?.addTarget(self, action: #selector(dateOrTimeUpdated(_:)), for: .valueChanged)
		closeTimePicker2?.addTarget(self, action: #selector(dateOrTimeUpdated(_:)), for: .valueChanged)
		
		dateTextField.inputView = datePicker
		openTimeTextField1.inputView = openTimePicker1
		closeTimeTextField1.inputView = closeTimePicker1
		openTimeTextField2.inputView = openTimePicker2
		closeTimeTextField2.inputView = closeTimePicker2
		
		staffMember = staffSpecificDatesVC?.staffMember
		
		if isEditSpecificDate {
			titleLabel.text = "Edit Specific\nDate"
			deleteButton.isEnabled = true
			deleteButton.tintColor = .red
			
			if let specificSchedule = staffSpecificDatesVC?.specificDatesSortedArray?[selectedIndex] {
				
				let date = specificSchedule.key
				let hoursArray = specificSchedule.value
				
				originalDateString = date
				
				if hoursArray == ["closed"] {
					setUpAsClosed()
					datePicker?.setDate(from: date, format: K.Strings.dateFormatString, animated: false)
					dateOrTimeUpdated(datePicker!)
				} else {
					openSwitch.isOn = true
					hoursStackView1.alpha = 1
					let openAndCloseTimes1 = Helpers.getOpenAndCloseTime(from: hoursArray[0])
					let openTime1 = openAndCloseTimes1[0]
					let closeTime1 = openAndCloseTimes1[1]
					
					datePicker?.setDate(from: date, format: K.Strings.dateFormatString, animated: false)
					
					openTimePicker1?.setDate(from: "2000-1-1 \(openTime1)", format: K.Strings.dateAndTimeFormatString, animated: false)
					closeTimePicker1?.setDate(from: "2000-1-1 \(closeTime1)", format: K.Strings.dateAndTimeFormatString, animated: false)
					
					dateOrTimeUpdated(datePicker!)
					dateOrTimeUpdated(openTimePicker1!)
					dateOrTimeUpdated(closeTimePicker1!)
					
					if hoursArray.count > 1 {
						secondShiftExists = true
						addRemoveShiftButton.setTitle("Remove Second Shift", for: .normal)
						addRemoveShiftButton.setTitleColor(.systemRed, for: .normal)
						hoursStackView2.alpha = 1
						let openAndCloseTimes2 = Helpers.getOpenAndCloseTime(from: hoursArray[1])
						let openTime2 = openAndCloseTimes2[0]
						let closeTime2 = openAndCloseTimes2[1]
						openTimePicker2?.setDate(from: "2000-1-1 \(openTime2)", format: K.Strings.dateAndTimeFormatString, animated: false)
						closeTimePicker2?.setDate(from: "2000-1-1 \(closeTime2)", format: K.Strings.dateAndTimeFormatString, animated: false)
						dateOrTimeUpdated(openTimePicker2!)
						dateOrTimeUpdated(closeTimePicker2!)
					} else {
						secondShiftExists = false
						addRemoveShiftButton.setTitle("Add Second Shift", for: .normal)
						addRemoveShiftButton.setTitleColor(.black, for: .normal)
						hoursStackView2.alpha = 0
						openTimePicker2?.setDate(from: "2000-1-1 9:00", format: K.Strings.dateAndTimeFormatString, animated: false)
						closeTimePicker2?.setDate(from: "2000-1-1 17:00", format: K.Strings.dateAndTimeFormatString, animated: false)
						dateOrTimeUpdated(openTimePicker2!)
						dateOrTimeUpdated(closeTimePicker2!)
					}
					
				}
				
			} else {
				Alerts.showNoOptionAlert(title: "An error occurred", message: "Please try again later", sender: self) { (_) in
					self.dismiss(animated: true, completion: nil)
				}
			}
			
		} else {
			titleLabel.text = "Add Specific Date"
			deleteButton.isEnabled = false
			deleteButton.tintColor = .clear
			openSwitch.isOn = false
			hoursStackView1.alpha = 0
			addRemoveShiftButton.alpha = 0
			hoursStackView2.alpha = 0
			setUpAsClosed()
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
	
	
	func setUpAsClosed() {
		datePicker?.setDate(Date(), animated: false)
		openTimePicker1?.setDate(from: "2000-1-1 9:00", format: K.Strings.dateAndTimeFormatString, animated: false)
		closeTimePicker1?.setDate(from: "2000-1-1 17:00", format: K.Strings.dateAndTimeFormatString, animated: false)
		openTimePicker2?.setDate(from: "2000-1-1 9:00", format: K.Strings.dateAndTimeFormatString, animated: false)
		closeTimePicker2?.setDate(from: "2000-1-1 17:00", format: K.Strings.dateAndTimeFormatString, animated: false)
		dateOrTimeUpdated(datePicker!)
		dateOrTimeUpdated(openTimePicker1!)
		dateOrTimeUpdated(closeTimePicker1!)
		dateOrTimeUpdated(openTimePicker2!)
		dateOrTimeUpdated(closeTimePicker2!)
		openSwitch.isOn = false
		hoursStackView1.alpha = 0
		addRemoveShiftButton.alpha = 0
		hoursStackView2.alpha = 0
	}
	
	
	@IBAction func switchFlipped(_ sender: UISwitch) {
		hideKeyboard()
		openSwitch.isUserInteractionEnabled = false
		if openSwitch.isOn {
			UIView.animate(withDuration: 0.6) {
				self.hoursStackView1.alpha = 1
				self.addRemoveShiftButton.alpha = 1
			} completion: { (_) in
				self.openSwitch.isUserInteractionEnabled = true
			}
		} else {
			secondShiftExists = false
			addRemoveShiftButton.setTitle("Add Second Shift", for: .normal)
			addRemoveShiftButton.setTitleColor(.black, for: .normal)
			UIView.animate(withDuration: 0.6) {
				self.hoursStackView1.alpha = 0
				self.hoursStackView2.alpha = 0
				self.addRemoveShiftButton.alpha = 0
			} completion: { (_) in
				self.openSwitch.isUserInteractionEnabled = true
			}
		}
	}
	
	
	@objc func dateOrTimeUpdated(_ datePicker: UIDatePicker) {
		let formatter = DateFormatter()
		formatter.timeStyle = .short
		if datePicker == self.datePicker {
			formatter.timeStyle = .none
			formatter.dateStyle = .short
			dateTextField.text = formatter.string(from: datePicker.date)
		} else if datePicker == openTimePicker1 {
			openTimeTextField1.text = formatter.string(from: datePicker.date)
		} else if datePicker == closeTimePicker1 {
			closeTimeTextField1.text = formatter.string(from: datePicker.date)
		} else if datePicker == openTimePicker2 {
			openTimeTextField2.text = formatter.string(from: datePicker.date)
		} else if datePicker == closeTimePicker2 {
			closeTimeTextField2.text = formatter.string(from: datePicker.date)
		}
	}
	
	
	@IBAction func addRemoveShiftPressed(_ sender: UIButton) {
		hideKeyboard()
		if secondShiftExists {
			addRemoveShiftButton.isUserInteractionEnabled = false
			secondShiftExists = false
			addRemoveShiftButton.setTitle("Add Second Shift", for: .normal)
			addRemoveShiftButton.setTitleColor(.black, for: .normal)
			UIView.animate(withDuration: 0.6) {
				self.hoursStackView2.alpha = 0
			} completion: { (_) in
				self.addRemoveShiftButton.isUserInteractionEnabled = true
			}
		} else {
			addRemoveShiftButton.isUserInteractionEnabled = false
			secondShiftExists = true
			addRemoveShiftButton.setTitle("Remove Second Shift", for: .normal)
			addRemoveShiftButton.setTitleColor(.systemRed, for: .normal)
			UIView.animate(withDuration: 0.6) {
				self.hoursStackView2.alpha = 1
			} completion: { (_) in
				self.addRemoveShiftButton.isUserInteractionEnabled = true
			}
		}
	}
	
	
	
	
	@IBAction func savePressed(_ sender: UIButton) {
		dateOrTimeUpdated(datePicker!)
		dateOrTimeUpdated(openTimePicker1!)
		dateOrTimeUpdated(closeTimePicker1!)
		dateOrTimeUpdated(openTimePicker2!)
		dateOrTimeUpdated(closeTimePicker2!)
		
		if datePicker?.date ?? Date() < Date() {
			Alerts.showNoOptionAlert(title: "Invalid Date", message: "Specific dates must be in the future", sender: self)
			return
		}
		
		var newScheduleStrings = ["closed"]
		
		let dateString = dateTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
		
		if openSwitch.isOn {
			
			let openTimeArray1 = openTimePicker1!.getTime()
			let closeTimeArray1 = closeTimePicker1!.getTime()
			
			if openTimeArray1.count != 2 {
				openTimeTextField1.changePlaceholderText(to: "Invalid shift start time", withColor: .systemRed)
				textFieldsHoldAlert[0] = true
				return
			}
			if closeTimeArray1.count != 2 {
				closeTimeTextField1.changePlaceholderText(to: "Invalid shift end time", withColor: .systemRed)
				textFieldsHoldAlert[1] = true
				return
			}
			
			let openHour1 = openTimeArray1[0]
			let openMinute1 = openTimeArray1[1]
			
			let closeHour1 = closeTimeArray1[0]
			let closeMinute1 = closeTimeArray1[1]
			
			
			if closeHour1 < openHour1 || (closeHour1 == openHour1 && closeMinute1 <= openMinute1) { // Shift 1's start and end times are invalid
				Alerts.showNoOptionAlert(title: "Invalid Time", message: "Your first shift's start time must be after the end time", sender: self)
				return
			} else {
				newScheduleStrings = ["\(openHour1):\(String(format: "%02d", openMinute1))-\(closeHour1):\(String(format: "%02d", closeMinute1))"]
			}
			
			
			if secondShiftExists {
				let openTimeArray2 = openTimePicker2!.getTime()
				let closeTimeArray2 = closeTimePicker2!.getTime()
				
				if openTimeArray2.count != 2 {
					openTimeTextField2.changePlaceholderText(to: "Invalid shift start time", withColor: .systemRed)
					textFieldsHoldAlert[2] = true
					return
				}
				if closeTimeArray2.count != 2 {
					closeTimeTextField2.changePlaceholderText(to: "Invalid shift end time", withColor: .systemRed)
					textFieldsHoldAlert[3] = true
					return
				}
				
				let openHour2 = openTimeArray2[0]
				let openMinute2 = openTimeArray2[1]
				
				let closeHour2 = closeTimeArray2[0]
				let closeMinute2 = closeTimeArray2[1]
				
				
				if closeHour2 < openHour2 || (closeHour2 == openHour2 && closeMinute2 <= openMinute2) { // Shift 2's start and end times are invalid
					Alerts.showNoOptionAlert(title: "Invalid Time", message: "Your second shift's start time must be after the end time", sender: self)
					return
				} else {
					newScheduleStrings.append("\(openHour2):\(String(format: "%02d", openMinute2))-\(closeHour2):\(String(format: "%02d", closeMinute2))")
				}
				
				if openHour2 < closeHour1 || (openHour2 == closeHour1 && openMinute2 <= closeMinute1) { // Shifts 1 and 2 are overlapping
					Alerts.showNoOptionAlert(title: "Overlapping Shifts", message: "Your first and second shifts cannot overlap", sender: self)
					return
				}
			}
			
		}
		
		
		if isEditSpecificDate {
			if dateString == originalDateString {
				staffSpecificDatesVC?.specificDates?[dateString] = newScheduleStrings
			} else {
				if staffSpecificDatesVC?.specificDates?[dateString] == nil {
					staffSpecificDatesVC?.specificDates?[dateString] = newScheduleStrings
					staffSpecificDatesVC?.specificDates?[originalDateString] = nil
				} else {
					Alerts.showNoOptionAlert(title: "Duplicate Date", message: "You already have specific hours set for \(dateString.formattedDate())", sender: self)
					return
				}
			}
		} else {
			if staffSpecificDatesVC?.specificDates == nil {
				staffSpecificDatesVC?.specificDates = [dateString: newScheduleStrings]
			} else {
				if staffSpecificDatesVC?.specificDates?[dateString] == nil {
					staffSpecificDatesVC?.specificDates?[dateString] = newScheduleStrings
				} else {
					Alerts.showNoOptionAlert(title: "Duplicate Date", message: "You already have specific hours set for \(dateString.formattedDate())", sender: self)
					return
				}
			}
		}
		
		
		
		var messageString = ""
		if newScheduleStrings == ["closed"] {
			messageString = "\(staffMember?.firstName ?? "This staff member") is now not scheduled to work on \(dateString.formattedDate())"
		} else {
			if let openTime1 = openTimeTextField1.text, let closeTime1 = closeTimeTextField1.text {
				messageString = "\(staffMember?.firstName ?? "This staff member")'s working hours on \(dateString.formattedDate()) are now \(openTime1) - \(closeTime1)"
				if let openTime2 = openTimeTextField2.text, let closeTime2 = closeTimeTextField2.text, secondShiftExists {
					messageString.append(" and \(openTime2) - \(closeTime2)")
				}
			} else {
				messageString = "\(staffMember?.firstName ?? "This staff member")'s working hours on \(dateString.formattedDate()) have been saved"
			}
		}
		
		var titleString = ""
		if isEditSpecificDate {
			titleString = "Changes Saved"
		} else {
			titleString = "Specific Date Added"
		}
		
		
		Alerts.showNoOptionAlert(title: titleString, message: messageString, sender: self) { (_) in
			self.dismiss(animated: true, completion: self.staffSpecificDatesVC?.updateSpecificDates)
		}
	}
	
	
	@IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		Alerts.showTwoOptionAlertDestructive(title: "Are you sure you want to exit?", message: "Your changes will not be saved", sender: self, option1: "Exit", option2: "Stay", is1Destructive: true, is2Destructive: false, handler1: { (_) in
			self.dismiss(animated: true, completion: nil)
		}, handler2: nil)
	}
	
	
	
	@IBAction func deletePressed(_ sender: UIBarButtonItem) {
		Alerts.showTwoOptionAlertDestructive(title: "Delete Confirmation", message: "Are you sure you want to delete this specific date?", sender: self, option1: "Delete", option2: "Cancel", is1Destructive: true, is2Destructive: false, handler1: { (_) in
			
			self.staffSpecificDatesVC?.specificDates?[self.originalDateString] = nil
			self.dismiss(animated: true, completion: self.staffSpecificDatesVC?.updateSpecificDates)
			
		}, handler2: nil)
	}
	
	
	
}




extension AddStaffSpecificDateViewController: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		if textField == dateTextField {
			textField.changePlaceholderText(to: "eg 1971-06-28")
		} else if textField == openTimeTextField1 || textField == openTimeTextField2 {
			textField.changePlaceholderText(to: "Open time")
		} else if textField == closeTimeTextField1 || textField == closeTimeTextField2 {
			textField.changePlaceholderText(to: "Close time")
		}
	}

}



extension AddStaffSpecificDateViewController: UIScrollViewDelegate {
	
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
