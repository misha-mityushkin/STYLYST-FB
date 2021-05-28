//
//  Helpers.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-06-01.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import MapKit

struct Helpers {
    
    static func addUserToUserDefaults(firstName: String, lastName: String, email: String, phoneNumber: String, password: String, uid: String) {
        UserDefaults.standard.set(firstName, forKey: K.UserDefaultKeys.User.firstName)
        UserDefaults.standard.set(lastName, forKey: K.UserDefaultKeys.User.lastName)
        UserDefaults.standard.set(email, forKey: K.UserDefaultKeys.User.email)
        UserDefaults.standard.set(phoneNumber, forKey: K.UserDefaultKeys.User.phoneNumber)
        UserDefaults.standard.set(password, forKey: K.UserDefaultKeys.User.password)
        UserDefaults.standard.set(uid, forKey: K.UserDefaultKeys.User.uid)
    }
    
    static func removeUserFromDefaults() {
        UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.User.firstName)
        UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.User.lastName)
        UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.User.email)
        UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.User.phoneNumber)
        UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.User.password)
        UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.User.uid)
        UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.User.verificationID)
        UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.User.otp)
        print("removed user")
    }
    
    
    static func format(phoneNumber: String, shouldRemoveLastDigit: Bool = false) -> String {
        guard !phoneNumber.isEmpty else { return "" }
        guard let regex = try? NSRegularExpression(pattern: "[\\s-\\(\\)]", options: .caseInsensitive) else { return "" }
        let r = NSString(string: phoneNumber).range(of: phoneNumber)
        var number = regex.stringByReplacingMatches(in: phoneNumber, options: .init(rawValue: 0), range: r, withTemplate: "")

        if number.count > 10 {
            let tenthDigitIndex = number.index(number.startIndex, offsetBy: 10)
            number = String(number[number.startIndex..<tenthDigitIndex])
        }

        if shouldRemoveLastDigit {
            let end = number.index(number.startIndex, offsetBy: number.count-1)
            number = String(number[number.startIndex..<end])
        }

        if number.count < 7 {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d+)", with: "($1) $2", options: .regularExpression, range: range)

        } else {
            let end = number.index(number.startIndex, offsetBy: number.count)
            let range = number.startIndex..<end
            number = number.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "($1) $2-$3", options: .regularExpression, range: range)
        }

        return number
    }
    
    
    static func parseAddress(for placemark: MKPlacemark) -> String {
        // put a space between number and street name
        let firstSpace = (placemark.subThoroughfare != nil && placemark.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (placemark.subThoroughfare != nil || placemark.thoroughfare != nil) && (placemark.subAdministrativeArea != nil || placemark.administrativeArea != nil) ? ", " : ""
        // put a space between city and state
        let secondSpace = (placemark.subAdministrativeArea != nil && placemark.administrativeArea != nil) ? " " : ""
        // put a space between state and postal code
        let thirdSpace = (placemark.administrativeArea != nil && placemark.postalCode != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@%@%@",
            // street number
            placemark.subThoroughfare ?? "",
            firstSpace,
            // street name
            placemark.thoroughfare ?? "",
            comma,
            // city
            placemark.locality ?? "",
            secondSpace,
            // state
            placemark.administrativeArea ?? "",
            thirdSpace,
            // postal code
			placemark.postalCode ?? ""
        )
			return addressLine
    }
	
	static func formatAddress(streetNumber: String, streetName: String, city: String, province: String, postalCode: String) -> String {
		return "\(streetNumber) \(streetName), \(city) \(province) \(postalCode)"
	}
	
	static func getTime(fromString string: String) -> [Int] {
		var timeArr = [0, 0]
		if let hPos = string.firstIndex(of: "h"), let mPos = string.lastIndex(of: "m") {
			let hours = Int(String(string[..<hPos]))
			let minutes = Int(String(string[string.index(hPos, offsetBy: 2)..<mPos]))
			timeArr[0] = hours ?? 0
			timeArr[1] = minutes ?? 0
		}
		return timeArr
	}
	
	
	static func getBusinessTypeEnum(fromIdentifier identifier: String) -> BusinessType {
		var businessType = BusinessType.BarberShop
		for i in 0..<K.Collections.businessTypeIdentifiers.count {
			if K.Collections.businessTypeIdentifiers[i] == identifier {
				businessType = K.Collections.businessTypeEnums[i]
			}
		}
		return businessType
	}
	
	
	static func getKeywords(forArray array: [String]) -> [String] {
		var keywords: [String] = []
		for string in array {
			keywords.append(contentsOf: getKeywords(forString: string.lowercased()))
		}
		return keywords
	}
	static func getKeywords(forString string: String) -> [String] {
		var keywords: [String] = getKeywords(forWord: Substring(string))
		let words = string.split(separator: " ")
		for i in 1..<words.count {
			keywords.append(contentsOf: getKeywords(forWord: words[i]))
		}
		return keywords
	}
	static func getKeywords(forWord substring: Substring) -> [String] {
		let string = String(substring)
		let characters = Array(string)
		var keywords: [String] = []
		var keyword = ""
		for i in 0..<characters.count {
			keyword.append(characters[i])
			keywords.append(keyword)
		}
		return keywords
	}
	
	static func getOpenAndCloseTime(from string: String) -> [String] {
		var openAndCloseTime: [String] = []
		
		let subStringArray = string.split(separator: "-")
		for subString in subStringArray {
			openAndCloseTime.append(String(subString))
		}
		
		return openAndCloseTime
	}
	
	
	static func getNoDataLabel(forTableView tableView: UITableView, withText labelText: String) -> UILabel {
		let tableWidth = tableView.bounds.size.width
		let noDataLabel = UILabel(frame: CGRect(x: tableWidth * 0.075, y: 0, width: tableWidth * 0.85, height: tableView.bounds.size.height))
		noDataLabel.numberOfLines = 0
		noDataLabel.text = labelText
		noDataLabel.textColor = K.Colors.goldenThemeColorDefault
		noDataLabel.textAlignment = .center
		noDataLabel.isHidden = true
		return noDataLabel
	}
	
}
