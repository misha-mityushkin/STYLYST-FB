//
//  DatePickerExtension.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-08-23.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

extension UIDatePicker {
	
	func setDate(from string: String, format: String, animated: Bool = true) {
		let formater = DateFormatter()
		formater.dateFormat = format
		let date = formater.date(from: string) ?? Date()
		setDate(date, animated: animated)
	}
	
	func getTime() -> [Int] {
		let components = Calendar.current.dateComponents([.hour, .minute], from: date)
		return [components.hour!, components.minute!]
	}
}
