//
//  BusinessLocation.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-06-27.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import Firebase

class BusinessLocation {
    
    var docID: String
    
    var name: String
    
    var phoneNumber: String
    var email: String
    
    var addressFormatted: String
    var streetNumber: String
    var streetName: String
    var city: String
    var province: String
    var postalCode: String
    var lat: Double
    var lon: Double
    
    var images: [UIImage] = []
	var numActualImages: Int
    
    var introParagraph: String
	var businessType: BusinessType
	
	var serviceCategories: [String]
	var services: [Service]
	
	var staffUserIDs: [String]
	var staffMembers: [User] = []
	
	var subscriptionPlan: SubscriptionPlan?
	
	var weeklyHours: [String : String]?
	var specificHours: [String : String]?
	var staffWeeklyHours: [String : [String : [String]]]?
	var staffSpecificHours: [String : [String : [String]]]?
	

	
	init(docID: String, data: [String : Any]?, images: [UIImage?], placeholderImage: UIImage) {
		self.docID = docID
		self.name = data?[K.Firebase.PlacesFieldNames.name] as? String ?? "Unknown Name"
		self.phoneNumber = data?[K.Firebase.PlacesFieldNames.phoneNumber] as? String ?? "Unknown Number"
		self.email = data?[K.Firebase.PlacesFieldNames.email] as? String ?? "Unknown Email"
		
		let address = data?[K.Firebase.PlacesFieldNames.address] as? [String:String]
		self.streetNumber = address?[K.Firebase.PlacesFieldNames.Address.streetNumber] ?? "Unknown Address"
		self.streetName = address?[K.Firebase.PlacesFieldNames.Address.streetName] ?? ""
		self.city = address?[K.Firebase.PlacesFieldNames.Address.city] ?? ""
		self.province = address?[K.Firebase.PlacesFieldNames.Address.province] ?? ""
		self.postalCode = address?[K.Firebase.PlacesFieldNames.Address.postalCode] ?? ""
		self.lat = data?[K.Firebase.PlacesFieldNames.lat] as? Double ?? 0.0
		self.lon = data?[K.Firebase.PlacesFieldNames.lon] as? Double ?? 0.0
		self.addressFormatted = Helpers.formatAddress(streetNumber: streetNumber, streetName: streetName, city: city, province: province, postalCode: postalCode)
		
		self.introParagraph = data?[K.Firebase.PlacesFieldNames.introParagraph] as? String ?? ""
		self.staffUserIDs = data?[K.Firebase.PlacesFieldNames.staffUserIDs] as? [String] ?? []
		
		self.serviceCategories = data?[K.Firebase.PlacesFieldNames.serviceCategories] as? [String] ?? []
		if self.serviceCategories.isEmpty {
			self.serviceCategories = [Service.NO_CATEGORY]
		}
		self.services = Helpers.parseServicesArray(servicesData: data?[K.Firebase.PlacesFieldNames.services] as? [[String : Any]] ?? [])
		
		self.weeklyHours = data?[K.Firebase.PlacesFieldNames.weeklyHours] as? [String : String]
		self.specificHours = data?[K.Firebase.PlacesFieldNames.specificHours] as? [String : String]
		self.staffWeeklyHours = data?[K.Firebase.PlacesFieldNames.staffWeeklyHours] as? [String : [String : [String]]]
		self.staffSpecificHours = data?[K.Firebase.PlacesFieldNames.staffSpecificHours] as? [String : [String : [String]]]
		
		let businessTypeIdentifier = data?[K.Firebase.PlacesFieldNames.businessType] as? String ?? "barbershop"
		self.businessType = Helpers.getBusinessTypeEnum(fromIdentifier: businessTypeIdentifier)
		
		for image in images {
			if let image = image {
				self.images.append(image)
			}
		}
		numActualImages = self.images.count
		for image in images {
			if image == placeholderImage {
				numActualImages -= 1
			}
		}
		
		for i in 0..<staffUserIDs.count {
			let uid = staffUserIDs[i]
			Firestore.firestore().collection(K.Firebase.CollectionNames.users).document(uid).getDocument { (document, error) in
				if let document = document, document.exists {
					self.staffMembers.append(User(userID: uid, data: document.data()))
				}
			}
		}
		
		let subscriptionPlanName = data?[K.Firebase.PlacesFieldNames.subscriptionPlan] as? String ?? "Lite"
		
		Firestore.firestore().collection(K.Firebase.CollectionNames.subscriptionPlans).document(subscriptionPlanName).getDocument { (document, error) in
			if let document = document, document.exists {
				if let price = document.get(K.Firebase.SubscriptionPlansFieldNames.price) as? Double, let numStaff = document.get(K.Firebase.SubscriptionPlansFieldNames.numStaff) as? Int, let numStaffDisplay = document.get(K.Firebase.SubscriptionPlansFieldNames.numStaffDisplay) as? String {
					self.subscriptionPlan = SubscriptionPlan(name: subscriptionPlanName, price: price, numStaff: numStaff, numStaffDisplay: numStaffDisplay)
				}
			}
		}
	}
}
