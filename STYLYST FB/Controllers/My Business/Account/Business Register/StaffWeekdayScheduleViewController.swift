//
//  StaffWeekdayScheduleViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-09-04.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class StaffWeekdayScheduleViewController: UIViewController {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var openSwitch: UISwitch!
	
	@IBOutlet weak var hoursStackView1: UIStackView!
	@IBOutlet weak var openTimeTextField1: UITextField!
	@IBOutlet weak var closeTimeTextField1: UITextField!
	
	@IBOutlet weak var addRemoveShiftButton: UIButton!
	
	@IBOutlet weak var hoursStackView2: UIStackView!
	@IBOutlet weak var openTimeTextField2: UITextField!
	@IBOutlet weak var closeTimeTextField2: UITextField!
	
	@IBOutlet weak var instructionsLabel: UILabel!
		
	var staffWorkingHoursVC: StaffWorkingHoursViewController?
	
	var openTimePicker1: UIDatePicker?
	var closeTimePicker1: UIDatePicker?
	
	var openTimePicker2: UIDatePicker?
	var closeTimePicker2: UIDatePicker?
	
	var textFields: [UITextField] = []
	var textFieldsHoldAlert = [false, false, false, false]
	
	var scheduleStrings = ["closed"]
	var dayOfTheWeekIdentifier = "monday"
	
	var staffMember: User?
	
	var secondShiftExists = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if #available(iOS 13.0, *) {
			isModalInPresentation = true
		}
		
		staffMember = staffWorkingHoursVC?.addStaffMemberVC?.staffMember
		
		dayOfTheWeekIdentifier = K.Collections.daysOfTheWeekIdentifiers[staffWorkingHoursVC?.selectedDayIndex ?? 0]
		
		titleLabel.text = "\(staffMember?.firstName ?? "")'s  \(K.Collections.daysOfTheWeek[staffWorkingHoursVC?.selectedDayIndex ?? 0]) Schedule"
		
		instructionsLabel.text = "Tap 'Save' once you're done setting \(staffMember?.firstName ?? "the staff member")'s working hours"
		
		textFields = [openTimeTextField1, closeTimeTextField1, openTimeTextField2, closeTimeTextField2]
		for textField in textFields {
			textField.delegate = self
			textField.addDoneButtonOnKeyboard()
		}
		UITextField.format(textFields: textFields, height: 40, padding: 10)
		
		openSwitch.layer.cornerRadius = openSwitch.frame.height / 2
		
		openTimePicker1 = UIDatePicker(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3))
		closeTimePicker1 = UIDatePicker(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3))
		openTimePicker2 = UIDatePicker(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3))
		closeTimePicker2 = UIDatePicker(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3))
		openTimePicker1?.datePickerMode = .time
		closeTimePicker1?.datePickerMode = .time
		openTimePicker1?.minuteInterval = 5
		closeTimePicker1?.minuteInterval = 5
		openTimePicker2?.datePickerMode = .time
		closeTimePicker2?.datePickerMode = .time
		openTimePicker2?.minuteInterval = 5
		closeTimePicker2?.minuteInterval = 5
		if #available(iOS 13.4, *) {
			openTimePicker1?.preferredDatePickerStyle = .wheels
			closeTimePicker1?.preferredDatePickerStyle = .wheels
			openTimePicker2?.preferredDatePickerStyle = .wheels
			closeTimePicker2?.preferredDatePickerStyle = .wheels
		}
		openTimePicker1?.addTarget(self, action: #selector(timeUpdated(_:)), for: .valueChanged)
		closeTimePicker1?.addTarget(self, action: #selector(timeUpdated(_:)), for: .valueChanged)
		openTimeTextField1.inputView = openTimePicker1
		closeTimeTextField1.inputView = closeTimePicker1
		openTimePicker2?.addTarget(self, action: #selector(timeUpdated(_:)), for: .valueChanged)
		closeTimePicker2?.addTarget(self, action: #selector(timeUpdated(_:)), for: .valueChanged)
		openTimeTextField2.inputView = openTimePicker2
		closeTimeTextField2.inputView = closeTimePicker2
		
		if let weeklyHours = staffWorkingHoursVC?.addStaffMemberVC?.weeklyHours {
			
			if weeklyHours[dayOfTheWeekIdentifier] == nil {
				staffWorkingHoursVC?.addStaffMemberVC?.weeklyHours?[dayOfTheWeekIdentifier] = ["closed"]
			}
			
			scheduleStrings = weeklyHours[dayOfTheWeekIdentifier] ?? ["closed"]
			if scheduleStrings == ["closed"] {
				setUpAsClosed()
			} else {
				openSwitch.isOn = true
				
				hoursStackView1.alpha = 1
				let openAndCloseTimes1 = Helpers.getOpenAndCloseTime(from: scheduleStrings[0])
				let openTime1 = openAndCloseTimes1[0]
				let closeTime1 = openAndCloseTimes1[1]
				openTimePicker1?.setDate(from: "2000-1-1 \(openTime1)", format: K.Strings.dateAndTimeFormatString, animated: false)
				closeTimePicker1?.setDate(from: "2000-1-1 \(closeTime1)", format: K.Strings.dateAndTimeFormatString, animated: false)
				timeUpdated(openTimePicker1!)
				timeUpdated(closeTimePicker1!)
				
				if scheduleStrings.count > 1 {
					secondShiftExists = true
					addRemoveShiftButton.setTitle("Remove Second Shift", for: .normal)
					addRemoveShiftButton.setTitleColor(.systemRed, for: .normal)
					hoursStackView2.alpha = 1
					let openAndCloseTimes2 = Helpers.getOpenAndCloseTime(from: scheduleStrings[1])
					let openTime2 = openAndCloseTimes2[0]
					let closeTime2 = openAndCloseTimes2[1]
					openTimePicker2?.setDate(from: "2000-1-1 \(openTime2)", format: K.Strings.dateAndTimeFormatString, animated: false)
					closeTimePicker2?.setDate(from: "2000-1-1 \(closeTime2)", format: K.Strings.dateAndTimeFormatString, animated: false)
					timeUpdated(openTimePicker2!)
					timeUpdated(closeTimePicker2!)
				} else {
					secondShiftExists = false
					addRemoveShiftButton.setTitle("Add Second Shift", for: .normal)
					addRemoveShiftButton.setTitleColor(.black, for: .normal)
					hoursStackView2.alpha = 0
					openTimePicker2?.setDate(from: "2000-1-1 9:00", format: K.Strings.dateAndTimeFormatString, animated: false)
					closeTimePicker2?.setDate(from: "2000-1-1 17:00", format: K.Strings.dateAndTimeFormatString, animated: false)
					timeUpdated(openTimePicker2!)
					timeUpdated(closeTimePicker2!)
				}
			}
			
		} else {
			staffWorkingHoursVC?.addStaffMemberVC?.weeklyHours = [dayOfTheWeekIdentifier : ["closed"]]
			setUpAsClosed()
		}
		
		
		hideKeyboardWhenTappedAround()
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
		scheduleStrings = ["closed"]
		
		openTimePicker1?.setDate(from: "2000-1-1 9:00", format: K.Strings.dateAndTimeFormatString, animated: false)
		closeTimePicker1?.setDate(from: "2000-1-1 17:00", format: K.Strings.dateAndTimeFormatString, animated: false)
		
		openTimePicker2?.setDate(from: "2000-1-1 9:00", format: K.Strings.dateAndTimeFormatString, animated: false)
		closeTimePicker2?.setDate(from: "2000-1-1 17:00", format: K.Strings.dateAndTimeFormatString, animated: false)
		
		timeUpdated(openTimePicker1!)
		timeUpdated(closeTimePicker1!)
		
		timeUpdated(openTimePicker2!)
		timeUpdated(closeTimePicker2!)
		
		openSwitch.isOn = false
		hoursStackView1.alpha = 0
		hoursStackView2.alpha = 0
		addRemoveShiftButton.alpha = 0
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
			scheduleStrings = ["closed"]
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
	
	
	@objc func timeUpdated(_ datePicker: UIDatePicker) {
		let formatter = DateFormatter()
		formatter.timeStyle = .short
		if datePicker == openTimePicker1 {
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
		timeUpdated(openTimePicker1!)
		timeUpdated(closeTimePicker1!)
		timeUpdated(openTimePicker2!)
		timeUpdated(closeTimePicker2!)
		
		var newScheduleStrings = ["closed"]
		
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
			
//			if closeHour1 > openHour1 {
//				newScheduleStrings = ["\(openHour1):\(String(format: "%02d", openMinute1))-\(closeHour1):\(String(format: "%02d", closeMinute1))"]
//			} else if closeHour1 == openHour1 {
//				if closeMinute1 > openMinute1 {
//					newScheduleStrings = ["\(openHour1):\(String(format: "%02d", openMinute1))-\(closeHour1):\(String(format: "%02d", closeMinute1))"]
//				} else {
//					Alerts.showNoOptionAlert(title: "Invalid Time", message: "Your first shift's start time must be after the end time", sender: self)
//					return
//				}
//			} else {
//				Alerts.showNoOptionAlert(title: "Invalid Time", message: "Your first shift's start time must be after the end time", sender: self)
//				return
//			}
			
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
				
//				if closeHour2 > openHour2 {
//					newScheduleStrings.append("\(openHour2):\(String(format: "%02d", openMinute2))-\(closeHour2):\(String(format: "%02d", closeMinute2))")
//				} else if closeHour2 == openHour2 {
//					if closeMinute2 > openMinute2 {
//						newScheduleStrings.append("\(openHour2):\(String(format: "%02d", openMinute2))-\(closeHour2):\(String(format: "%02d", closeMinute2))")
//					} else {
//						Alerts.showNoOptionAlert(title: "Invalid Time", message: "Your second shift's start time must be after the end time", sender: self)
//						return
//					}
//				} else {
//					Alerts.showNoOptionAlert(title: "Invalid Time", message: "Your second shift's start time must be after the end time", sender: self)
//					return
//				}
				
				if openHour2 < closeHour1 || (openHour2 == closeHour1 && openMinute2 <= closeMinute1) { // Shifts 1 and 2 are overlapping
					Alerts.showNoOptionAlert(title: "Overlapping Shifts", message: "Your first and second shifts cannot overlap", sender: self)
					return
				}
			}
		}
		
		scheduleStrings = newScheduleStrings
		staffWorkingHoursVC?.addStaffMemberVC?.weeklyHours?[dayOfTheWeekIdentifier] = scheduleStrings
		
		var messageString = ""
		if scheduleStrings == ["closed"] {
			messageString = "\(staffMember?.firstName ?? "This staff member") is now not scheduled to work on \(K.Collections.daysOfTheWeek[staffWorkingHoursVC?.selectedDayIndex ?? 0])s"
		} else {
			if let openTime1 = openTimeTextField1.text, let closeTime1 = closeTimeTextField1.text {
				messageString = "\(staffMember?.firstName ?? "This staff member")'s working hours on \(K.Collections.daysOfTheWeek[staffWorkingHoursVC?.selectedDayIndex ?? 0])s are now \(openTime1) - \(closeTime1)"
				if let openTime2 = openTimeTextField2.text, let closeTime2 = closeTimeTextField2.text, secondShiftExists {
					messageString.append(" and \(openTime2) - \(closeTime2)")
				}
			} else {
				messageString = "\(staffMember?.firstName ?? "This staff member")'s working hours on \(K.Collections.daysOfTheWeek[staffWorkingHoursVC?.selectedDayIndex ?? 0])s have been saved"
			}
		}
		
		Alerts.showNoOptionAlert(title: "Changes Saved", message: messageString, sender: self) { (_) in
			self.navigationController?.popViewController(animated: true)
		}
	}

}



extension StaffWeekdayScheduleViewController: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		if textField == openTimeTextField1 || textField == openTimeTextField2 {
			textField.changePlaceholderText(to: "Shift start time")
		} else if textField == closeTimeTextField1 || textField == closeTimeTextField2 {
			textField.changePlaceholderText(to: "Shift end time")
		}
	}
}



extension StaffWeekdayScheduleViewController: UIScrollViewDelegate {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		if scrollView.contentOffset.y >= titleLabel.frame.maxY {
			if navigationItem.title != titleLabel.text {
				navigationItem.title = titleLabel.text
			}
		} else {
			if navigationItem.title == titleLabel.text {
				navigationItem.title = nil
			}
		}
		
	}
	
}
