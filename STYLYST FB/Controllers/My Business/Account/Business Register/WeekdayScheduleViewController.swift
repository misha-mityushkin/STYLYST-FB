//
//  WeekdayScheduleViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-08-22.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class WeekdayScheduleViewController: UIViewController {
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var openSwitch: UISwitch!
	@IBOutlet weak var openClosedLabel: UILabel!
	
	@IBOutlet weak var hoursStackView: UIStackView!
	@IBOutlet weak var openTimeTextField: UITextField!
	@IBOutlet weak var closeTimeTextField: UITextField!
	
	var hoursOfOperationVC: HoursOfOperationViewController?
	
	var openTimePicker: UIDatePicker?
	var closeTimePicker: UIDatePicker?
	
	var textFields: [UITextField] = []
	var textFieldsHoldAlert = [false, false]
	
	var scheduleString = "closed"
	var dayOfTheWeekIdentifier = "monday"
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		dayOfTheWeekIdentifier = K.Collections.daysOfTheWeekIdentifiers[hoursOfOperationVC?.selectedDayIndex ?? 0]
		
		titleLabel.text = "\(K.Collections.daysOfTheWeek[hoursOfOperationVC?.selectedDayIndex ?? 0])'s\nSchedule"
		
		textFields = [openTimeTextField, closeTimeTextField]
		for textField in textFields {
			textField.delegate = self
		}
		UITextField.format(textFields: textFields, height: 40, padding: 10)
		
		openSwitch.layer.cornerRadius = openSwitch.frame.height / 2
		
		openTimePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3))
		closeTimePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3))
		openTimePicker?.datePickerMode = .time
		closeTimePicker?.datePickerMode = .time
		openTimePicker?.minuteInterval = 5
		closeTimePicker?.minuteInterval = 5
		if #available(iOS 13.4, *) {
			openTimePicker?.preferredDatePickerStyle = .wheels
			closeTimePicker?.preferredDatePickerStyle = .wheels
		}
		openTimePicker?.addTarget(self, action: #selector(timeUpdated(_:)), for: .valueChanged)
		closeTimePicker?.addTarget(self, action: #selector(timeUpdated(_:)), for: .valueChanged)
		openTimeTextField.inputView = openTimePicker
		closeTimeTextField.inputView = closeTimePicker
		
		if let weeklyHours = hoursOfOperationVC?.businessRegisterVC?.weeklyHours {
			
			if weeklyHours[dayOfTheWeekIdentifier] == nil {
				hoursOfOperationVC?.businessRegisterVC?.weeklyHours?[dayOfTheWeekIdentifier] = "closed"
			}
			
			scheduleString = weeklyHours[dayOfTheWeekIdentifier] ?? "closed"
			if scheduleString == "closed" {
				setUpAsClosed()
			} else {
				openSwitch.isOn = true
				openClosedLabel.text = "Open"
				hoursStackView.alpha = 1
				let openAndCloseTimes = Helpers.getOpenAndCloseTime(from: scheduleString)
				let openTime = openAndCloseTimes[0]
				let closeTime = openAndCloseTimes[1]
				openTimePicker?.setDate(from: "2000-1-1 \(openTime)", format: K.Strings.dateAndTimeFormatString, animated: false)
				closeTimePicker?.setDate(from: "2000-1-1 \(closeTime)", format: K.Strings.dateAndTimeFormatString, animated: false)
				timeUpdated(openTimePicker!)
				timeUpdated(closeTimePicker!)
			}
			
		} else {
			hoursOfOperationVC?.businessRegisterVC?.weeklyHours = [dayOfTheWeekIdentifier : "closed"]
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
		openClosedLabel.text = "Closed"
		scheduleString = "closed"
		openTimePicker?.setDate(from: "2000-1-1 9:00", format: K.Strings.dateAndTimeFormatString, animated: false)
		closeTimePicker?.setDate(from: "2000-1-1 17:00", format: K.Strings.dateAndTimeFormatString, animated: false)
		timeUpdated(openTimePicker!)
		timeUpdated(closeTimePicker!)
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
			scheduleString = "closed"
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
	
	
	@objc func timeUpdated(_ datePicker: UIDatePicker) {
		let formatter = DateFormatter()
		formatter.timeStyle = .short
		if datePicker == openTimePicker {
			openTimeTextField.text = formatter.string(from: datePicker.date)
		} else if datePicker == closeTimePicker {
			closeTimeTextField.text = formatter.string(from: datePicker.date)
		}
	}
	
	
	
	@IBAction func savePressed(_ sender: UIButton) {
		timeUpdated(openTimePicker!)
		timeUpdated(closeTimePicker!)
		
		var newScheduleString = "closed"
		
		if openSwitch.isOn {
			let openTimeArray = openTimePicker!.getTime()
			let closeTimeArray = closeTimePicker!.getTime()
			
			if openTimeArray.count != 2 {
				openTimeTextField.changePlaceholderText(to: "Invalid opening time", withColor: .systemRed)
				textFieldsHoldAlert[0] = true
				return
			}
			if closeTimeArray.count != 2 {
				closeTimeTextField.changePlaceholderText(to: "Invalid closing time", withColor: .systemRed)
				textFieldsHoldAlert[1] = true
				return
			}
			
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
		
		scheduleString = newScheduleString
		if hoursOfOperationVC?.businessRegisterVC?.weeklyHours == nil {
			hoursOfOperationVC?.businessRegisterVC?.weeklyHours = [dayOfTheWeekIdentifier : scheduleString]
		} else {
			hoursOfOperationVC?.businessRegisterVC?.weeklyHours?[dayOfTheWeekIdentifier] = scheduleString
		}
		
		var messageString = ""
		if scheduleString == "closed" {
			messageString = "Your business is now closed on \(K.Collections.daysOfTheWeek[hoursOfOperationVC?.selectedDayIndex ?? 0])s"
		} else {
			if let openTime = openTimeTextField.text, let closeTime = closeTimeTextField.text {
				messageString = "Your hours of operation for \(K.Collections.daysOfTheWeek[hoursOfOperationVC?.selectedDayIndex ?? 0]) are now \(openTime) - \(closeTime)"
			} else {
				messageString = "Your new hours of operation for \(K.Collections.daysOfTheWeek[hoursOfOperationVC?.selectedDayIndex ?? 0]) have been saved"
			}
		}
		
		Alerts.showNoOptionAlert(title: "Changes Saved", message: messageString, sender: self) { (_) in
			self.navigationController?.popViewController(animated: true)
		}
	}
	
	
}




extension WeekdayScheduleViewController: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		if textField == openTimeTextField {
			textField.changePlaceholderText(to: "Open time")
		} else if textField == closeTimeTextField {
			textField.changePlaceholderText(to: "Close time")
		}
	}
}
