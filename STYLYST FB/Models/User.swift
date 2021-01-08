//
//  User.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-08-01.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import Foundation

struct User {
	
	var userID: String
	var firstName: String
	var lastName: String
	var email: String
	var phoneNumber: String
	var personalCode: String
	
	init(userID: String, data: [String : Any]?) {
		self.userID = userID
		firstName = data?[K.Firebase.UserFieldNames.firstName] as? String ?? "No First Name"
		lastName = data?[K.Firebase.UserFieldNames.lastName] as? String ?? "No Last Name"
		email = data?[K.Firebase.UserFieldNames.email] as? String ?? "No Email"
		phoneNumber = data?[K.Firebase.UserFieldNames.phoneNumber] as? String ?? "No Phone Number"
		personalCode = data?[K.Firebase.UserFieldNames.personalCode] as? String ?? "0000"
	}
}
