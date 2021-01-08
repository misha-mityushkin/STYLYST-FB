//
//  AddSpecificDateViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-08-24.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class AddSpecificDateViewController: UIViewController {
	
	@IBOutlet weak var navigationBar: UINavigationBar!
	@IBOutlet weak var deleteButton: UIBarButtonItem!
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var dateTextField: UITextField!
	@IBOutlet weak var openSwitch: UISwitch!
	@IBOutlet weak var openClosedLabel: UILabel!
	
	@IBOutlet weak var hoursStackView: UIStackView!
	@IBOutlet weak var openTimeTextField: UITextField!
	@IBOutlet weak var closeTimeTextField: UITextField!
	
	var specificDatesVC: SpecificDatesTableViewController?
	var isEditSpecificDate = false
	var selectedIndex = 0
	
	var datePicker: UIDatePicker?
	var openTimePicker: UIDatePicker?
	var closeTimePicker: UIDatePicker?
	
	var textFields: [UITextField] = []
	var textFieldsHoldAlert = [false, false, false]
	
	var originalDateString = ""
		
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if #available(iOS 13.0, *) {
			isModalInPresentation = true
		}
		
		textFields = [dateTextField, openTimeTextField, closeTimeTextField]
		for textField in textFields {
			textField.delegate = self
			textField.addDoneButtonOnKeyboard()
		}
		UITextField.format(textFields: textFields, height: 40, padding: 10)
		
		openSwitch.layer.cornerRadius = openSwitch.frame.height / 2
		
		datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3))
		openTimePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3))
		closeTimePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3))
		
		datePicker?.datePickerMode = .date
		openTimePicker?.datePickerMode = .time
		closeTimePicker?.datePickerMode = .time
		
		openTimePicker?.minuteInterval = 5
		closeTimePicker?.minuteInterval = 5
		
		if #available(iOS 13.4, *) {
			datePicker?.preferredDatePickerStyle = .wheels
			openTimePicker?.preferredDatePickerStyle = .wheels
			closeTimePicker?.preferredDatePickerStyle = .wheels
		}
		
		datePicker?.addTarget(self, action: #selector(dateOrTimeUpdated(_:)), for: .valueChanged)
		openTimePicker?.addTarget(self, action: #selector(dateOrTimeUpdated(_:)), for: .valueChanged)
		closeTimePicker?.addTarget(self, action: #selector(dateOrTimeUpdated(_:)), for: .valueChanged)
		
		dateTextField.inputView = datePicker
		openTimeTextField.inputView = openTimePicker
		closeTimeTextField.inputView = closeTimePicker
		
		
		if isEditSpecificDate {
			titleLabel.text = "Edit Specific\nDate"
			deleteButton.isEnabled = true
			deleteButton.tintColor = .red
			
			if let specificSchedule = specificDatesVC?.specificDatesSortedArray?[selectedIndex] {
				
				let date = specificSchedule.key
				let hours = specificSchedule.value
				
				originalDateString = date
				
				if hours == "closed" {
					setUpAsClosed()
					datePicker?.setDate(from: date, format: K.Strings.dateFormatString, animated: false)
					dateOrTimeUpdated(datePicker!)
				} else {
					openSwitch.isOn = true
					openClosedLabel.text = "Open"
					hoursStackView.alpha = 1
					let openAndCloseTimes = Helpers.getOpenAndCloseTime(from: hours)
					let openTime = openAndCloseTimes[0]
					let closeTime = openAndCloseTimes[1]
					
					datePicker?.setDate(from: date, format: K.Strings.dateFormatString, animated: false)
					openTimePicker?.setDate(from: "2000-1-1 \(openTime)", format: K.Strings.dateAndTimeFormatString, animated: false)
					closeTimePicker?.setDate(from: "2000-1-1 \(closeTime)", format: K.Strings.dateAndTimeFormatString, animated: false)
					dateOrTimeUpdated(datePicker!)
					dateOrTimeUpdated(openTimePicker!)
					dateOrTimeUpdated(closeTimePicker!)
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
			hoursStackView.alpha = 0
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
		openClosedLabel.text = "Closed"
		datePicker?.setDate(Date(), animated: false)
		openTimePicker?.setDate(from: "2000-1-1 9:00", format: K.Strings.dateAndTimeFormatString, animated: false)
		closeTimePicker?.setDate(from: "2000-1-1 17:00", format: K.Strings.dateAndTimeFormatString, animated: false)
		dateOrTimeUpdated(datePicker!)
		dateOrTimeUpdated(openTimePicker!)
		dateOrTimeUpdated(closeTimePicker!)
		openSwitch.isOn = false
		hoursStackView.alpha = 0
	}
	
	
	@IBAction func switchFlipped(_ sender: UISwitch) {
		hideKeyboard()
		openSwitch.isUserInteractionEnabled = false
		if openSwitch.isOn {
			UIView.animate(withDuration: 0.2) {
				self.openClosedLabel.alpha = 0
			} completion: { (_) in
				self.openClosedLabel.text = "Open"
				UIView.animate(withDuration: 0.2) {
					self.openClosedLabel.alpha = 1
				}
			}
			UIView.animate(withDuration: 0.6) {
				self.hoursStackView.alpha = 1
			} completion: { (_) in
				self.openSwitch.isUserInteractionEnabled = true
			}
		} else {
			UIView.animate(withDuration: 0.2) {
				self.openClosedLabel.alpha = 0
			} completion: { (_) in
				self.openClosedLabel.text = "Closed"
				UIView.animate(withDuration: 0.2) {
					self.openClosedLabel.alpha = 1
				}
			}
			UIView.animate(withDuration: 0.6) {
				self.hoursStackView.alpha = 0
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
		} else if datePicker == openTimePicker {
			openTimeTextField.text = formatter.string(from: datePicker.date)
		} else if datePicker == closeTimePicker {
			closeTimeTextField.text = formatter.string(from: datePicker.date)
		}
	}
	
	
	
	@IBAction func savePressed(_ sender: UIButton) {
		dateOrTimeUpdated(datePicker!)
		dateOrTimeUpdated(openTimePicker!)
		dateOrTimeUpdated(closeTimePicker!)
		
		if datePicker?.date ?? Date() < Date() {
			Alerts.showNoOptionAlert(title: "Invalid Date", message: "Specific dates must be in the future", sender: self)
			return
		}

		var newScheduleString = "closed"
		
		let dateString = dateTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

		if openSwitch.isOn {
			let openTimeArray = openTimePicker!.getTime()
			let closeTimeArray = closeTimePicker!.getTime()

			let openHour = openTimeArray[0]
			let openMinute = openTimeArray[1]

			let closeHour = closeTimeArray[0]
			let closeMinute = closeTimeArray[1]

			if closeHour > openHour {
				newScheduleString = "\(openHour):\(String(format: "%02d", openMinute))-\(closeHour):\(String(format: "%02d", closeMinute))"
			} else if closeHour == openHour {
				if closeMinute > openMinute {
					newScheduleString = "\(openHour):\(String(format: "%02d", openMinute))-\(closeHour):\(String(format: "%02d", closeMinute))"
				} else {
					Alerts.showNoOptionAlert(title: "Invalid Time", message: "Your closing time must be after your opening time", sender: self)
					return
				}
			} else {
				Alerts.showNoOptionAlert(title: "Invalid Time", message: "Your closing time must be after your opening time", sender: self)
				return
			}
		}
		
		if isEditSpecificDate {
			if dateString == originalDateString {
				specificDatesVC?.specificDates?[dateString] = newScheduleString
			} else {
				if specificDatesVC?.specificDates?[dateString] == nil {
					specificDatesVC?.specificDates?[dateString] = newScheduleString
					specificDatesVC?.specificDates?[originalDateString] = nil
				} else {
					Alerts.showNoOptionAlert(title: "Duplicate Date", message: "You already have specific hours set for \(dateString.formattedDate())", sender: self)
					return
				}
			}
		} else {
			if specificDatesVC?.specificDates == nil {
				specificDatesVC?.specificDates = [dateString: newScheduleString]
			} else {
				if specificDatesVC?.specificDates?[dateString] == nil {
					specificDatesVC?.specificDates?[dateString] = newScheduleString
				} else {
					Alerts.showNoOptionAlert(title: "Duplicate Date", message: "You already have specific hours set for \(dateString.formattedDate())", sender: self)
					return
				}
			}
		}

		var messageString = ""
		if newScheduleString == "closed" {
			messageString = "Your business is now closed on \(dateString.formattedDate())"
		} else {
			if let openTime = openTimeTextField.text, let closeTime = closeTimeTextField.text {
				messageString = "Your hours of operation on \(dateString.formattedDate()) are now \(openTime) - \(closeTime)"
			} else {
				messageString = "Your hours of operation on \(dateString.formattedDate()) have been saved"
			}
		}
		
		var titleString = ""
		if isEditSpecificDate {
			titleString = "Changes Saved"
		} else {
			titleString = "Specific Date Added"
		}

		Alerts.showNoOptionAlert(title: titleString, message: messageString, sender: self) { (_) in
			self.dismiss(animated: true, completion: self.specificDatesVC?.updateSpecificDates)
		}
	}
	
	
	@IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		Alerts.showTwoOptionAlertDestructive(title: "Are you sure you want to exit?", message: "Your changes will not be saved", sender: self, option1: "Exit", option2: "Stay", is1Destructive: true, is2Destructive: false, handler1: { (_) in
			self.dismiss(animated: true, completion: nil)
		}, handler2: nil)
	}
	
	
	
	@IBAction func deletePressed(_ sender: UIBarButtonItem) {
		Alerts.showTwoOptionAlertDestructive(title: "Delete Confirmation", message: "Are you sure you want to delete this specific date?", sender: self, option1: "Delete", option2: "Cancel", is1Destructive: true, is2Destructive: false, handler1: { (_) in
			
			self.specificDatesVC?.specificDates?[self.originalDateString] = nil
			self.dismiss(animated: true, completion: self.specificDatesVC?.updateSpecificDates)
			
		}, handler2: nil)
	}
	
	
	
}




extension AddSpecificDateViewController: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		if textField == dateTextField {
			textField.changePlaceholderText(to: "eg 1971-06-28")
		} else if textField == openTimeTextField {
			textField.changePlaceholderText(to: "Open time")
		} else if textField == closeTimeTextField {
			textField.changePlaceholderText(to: "Close time")
		}
	}
}
