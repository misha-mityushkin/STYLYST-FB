//
//  Service.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2021-05-11.
//  Copyright © 2021 Michael Mityushkin. All rights reserved.
//

import Foundation


struct Service {
	
	static let NO_CATEGORY = "No Category"
	
	var enabled: Bool
	
	var category: String
	
	var name: String
	var description: String
	
	var defaultPrice: Double
	var specificPrices: [String : Double]
	
	var defaultTime: String
	var specificTimes: [String : String]
	
	var assignedStaff: [String] = []
	
	
	init(enabled: Bool, category: String, name: String, description: String, defaultPrice: Double, specificPrices: [String : Double], defaultTime: String, specificTimes: [String : String], assignedStaff: [String]) {
		self.enabled = enabled
		
		self.category = category
		
		self.name = name
		self.description = description
		
		self.defaultPrice = defaultPrice
		self.specificPrices = specificPrices
		
		self.defaultTime = defaultTime
		self.specificTimes = specificTimes
		
		self.assignedStaff = assignedStaff
	}
	
	init(serviceData: [String : Any]) {
		enabled = serviceData[K.Firebase.PlacesFieldNames.Services.enabled] as? Bool ?? false
		
		category = serviceData[K.Firebase.PlacesFieldNames.Services.category] as? String ?? Service.NO_CATEGORY
		
		name = serviceData[K.Firebase.PlacesFieldNames.Services.name] as? String ?? "No Service Name"
		description = serviceData[K.Firebase.PlacesFieldNames.Services.description] as? String ?? ""
		
		defaultPrice = serviceData[K.Firebase.PlacesFieldNames.Services.defaultPrice] as? Double ?? 0
		specificPrices = serviceData[K.Firebase.PlacesFieldNames.Services.specificPrices] as? [String : Double] ?? [:]
		
		defaultTime = serviceData[K.Firebase.PlacesFieldNames.Services.defaultTime] as? String ?? "0h 0min"
		specificTimes = serviceData[K.Firebase.PlacesFieldNames.Services.specificTimes] as? [String : String] ?? [:]
		
		assignedStaff = serviceData[K.Firebase.PlacesFieldNames.Services.staff] as? [String] ?? []
	}
	
	
	func getServiceData() -> [String : Any] {
		return [
			K.Firebase.PlacesFieldNames.Services.enabled : enabled,
			K.Firebase.PlacesFieldNames.Services.category : category,
			K.Firebase.PlacesFieldNames.Services.name : name,
			K.Firebase.PlacesFieldNames.Services.description : description,
			K.Firebase.PlacesFieldNames.Services.defaultPrice : defaultPrice,
			K.Firebase.PlacesFieldNames.Services.specificPrices : specificPrices,
			K.Firebase.PlacesFieldNames.Services.defaultTime : defaultTime,
			K.Firebase.PlacesFieldNames.Services.specificTimes : specificTimes,
			K.Firebase.PlacesFieldNames.Services.staff : assignedStaff
		]
	}
	
}



extension Service: Equatable, Comparable {
	
	static func < (lhs: Service, rhs: Service) -> Bool {
		return lhs.name.lowercased() < rhs.name.lowercased()
	}
	
	static func == (lhs: Service, rhs: Service) -> Bool {
		return lhs.enabled == rhs.enabled && lhs.category == rhs.category && lhs.name == rhs.name && lhs.description == rhs.description && lhs.defaultPrice == rhs.defaultPrice && lhs.specificPrices == rhs.specificPrices && lhs.defaultTime == rhs.defaultTime && lhs.specificTimes == rhs.specificTimes && lhs.assignedStaff == rhs.assignedStaff
	}
	
}
