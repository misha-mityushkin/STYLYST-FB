//
//  StringExtension.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-05-28.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import Foundation

extension String {
    
    func isEmptyOrWhitespace() -> Bool {
        if(self.isEmpty) {
            return true
        }
        return (self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{1,4}$"
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: self.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    
    func getRawPhoneNumber() -> String {
        var rawPhoneNumber: String = ""
        for c in self {
            if c.isNumber {
                rawPhoneNumber.append(c)
            }
        }
        return rawPhoneNumber
    }
    
    func isValidPhoneNumber(isFormatted: Bool) -> Bool {
        if isFormatted {
            return getRawPhoneNumber().isValidPhoneNumber(isFormatted: false)
        } else {
            return self.count == 10 && CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: self.trimmingCharacters(in: .whitespacesAndNewlines)))
        }
    }
	
	func isValidPersonalCode() -> Bool {
		return self.count == 4 && CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: self.trimmingCharacters(in: .whitespacesAndNewlines)))
	}
	
	func getDate(format: String) -> Date {
		let formater = DateFormatter()
		formater.dateFormat = format
		return formater.date(from: self) ?? Date()
	}
	
	func getYearMonthDay() -> [String] {
		var dateComponentsArray: [String] = []
		let components = self.split(separator: "-")
		for i in 0..<components.count {
			let component = components[i]
			if i == 1 { //if its the month component
				switch Int(String(component)) {
					case 1: dateComponentsArray.append("January")
					case 2: dateComponentsArray.append("February")
					case 3: dateComponentsArray.append("March")
					case 4: dateComponentsArray.append("April")
					case 5: dateComponentsArray.append("May")
					case 6: dateComponentsArray.append("June")
					case 7: dateComponentsArray.append("July")
					case 8: dateComponentsArray.append("August")
					case 9: dateComponentsArray.append("September")
					case 10: dateComponentsArray.append("October")
					case 11: dateComponentsArray.append("November")
					case 12: dateComponentsArray.append("December")
					default:
						dateComponentsArray.append("Unknown Month")
				}
			} else {
				dateComponentsArray.append(String(component))
			}
		}
		return dateComponentsArray
	}
	
	
	func getStartEndTimes() -> [String] {
		var startAndEndTimes: [String] = []
		let componentsArray = self.split(separator: "-")
		for component in componentsArray {
			startAndEndTimes.append(String(component))
		}
		return startAndEndTimes
	}
	
	
	func get12HourTime() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "H:mm"
		if let date12 = dateFormatter.date(from: self) {
			dateFormatter.dateFormat = "h:mm a"
			let date22 = dateFormatter.string(from: date12)
			return date22
		} else {
			return self
		}
	}
	
	
	func formattedStartEndTime() -> String {
		let startAndEndTimes = self.getStartEndTimes()
		let startTime = startAndEndTimes[0]
		let endTime = startAndEndTimes[1]
		return "\(startTime.get12HourTime()) - \(endTime.get12HourTime())"
	}
	
	func formattedDate() -> String {
		let dateComponents = self.getYearMonthDay()
		let year = dateComponents[0]
		let month = dateComponents[1]
		let day = String(Int(dateComponents[2]) ?? 0)
		return "\(month) \(day), \(year)"
	}
	
}
