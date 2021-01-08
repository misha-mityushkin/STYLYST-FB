//
//  DateExtension.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-07-25.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import Foundation

extension Date {
	
	var monthString: String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMMM"
		return dateFormatter.string(from: self)
	}
	
	func dateStringWith(strFormat: String) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = Calendar.current.timeZone
		dateFormatter.locale = Calendar.current.locale
		dateFormatter.dateFormat = strFormat
		return dateFormatter.string(from: self)
	}
}
