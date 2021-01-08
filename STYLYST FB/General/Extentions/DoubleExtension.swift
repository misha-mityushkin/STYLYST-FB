//
//  DoubleExtension.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-07-16.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import Foundation

extension Double {
	/// Rounds the double to decimal places value
	func rounded(toPlaces places:Int) -> Double {
		let divisor = pow(10.0, Double(places))
		return (self * divisor).rounded() / divisor
	}
}
