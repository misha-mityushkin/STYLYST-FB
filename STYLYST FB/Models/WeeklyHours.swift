//
//  WeeklyHours.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2021-05-11.
//  Copyright © 2021 Michael Mityushkin. All rights reserved.
//

import Foundation

struct WeeklyHours {
	var monday: String?
	var tuesday: String?
	var wednesday: String?
	var thursday: String?
	var friday: String?
	var saturday: String?
	var sunday: String?
	
	init(weeklyHoursData: [String : String]?) {
		let safeWeeklyHoursData = weeklyHoursData ?? [:]
		monday = safeWeeklyHoursData[K.Collections.daysOfTheWeekIdentifiers[0]]
		tuesday = safeWeeklyHoursData[K.Collections.daysOfTheWeekIdentifiers[1]]
		wednesday = safeWeeklyHoursData[K.Collections.daysOfTheWeekIdentifiers[2]]
		thursday = safeWeeklyHoursData[K.Collections.daysOfTheWeekIdentifiers[3]]
		friday = safeWeeklyHoursData[K.Collections.daysOfTheWeekIdentifiers[4]]
		saturday = safeWeeklyHoursData[K.Collections.daysOfTheWeekIdentifiers[5]]
		sunday = safeWeeklyHoursData[K.Collections.daysOfTheWeekIdentifiers[6]]
	}
}
