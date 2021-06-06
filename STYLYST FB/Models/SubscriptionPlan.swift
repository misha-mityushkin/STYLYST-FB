//
//  SubscriptionPlan.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-08-01.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import Foundation

struct SubscriptionPlan {
	var name: String
	var price: Double
	var numStaff: Int
	var numStaffDisplay: String
}


extension SubscriptionPlan: Comparable {
	static func < (lhs: SubscriptionPlan, rhs: SubscriptionPlan) -> Bool {
		return lhs.price < rhs.price
	}
}
