//
//  Constants.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-05-15.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

struct K {
	
	struct Collections {
		static let businessTypes = ["", "Barbershop", "Hair Salon", "Nail Salon", "Beauty Salon", "Spa", "Other"]
		static let businessTypeIdentifiers = ["barberShop", "hairSalon", "nailSalon", "beautySalon", "spa", "other"]
		static let businessTypeEnums = [BusinessType.BarberShop, BusinessType.HairSalon, BusinessType.NailSalon, BusinessType.BeautySalon, BusinessType.Spa, BusinessType.Other]
		static let daysOfTheWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
		static let daysOfTheWeekIdentifiers = [K.Firebase.PlacesFieldNames.WeeklyHours.monday, K.Firebase.PlacesFieldNames.WeeklyHours.tuesday, K.Firebase.PlacesFieldNames.WeeklyHours.wednesday, K.Firebase.PlacesFieldNames.WeeklyHours.thursday, K.Firebase.PlacesFieldNames.WeeklyHours.friday, K.Firebase.PlacesFieldNames.WeeklyHours.saturday, K.Firebase.PlacesFieldNames.WeeklyHours.sunday]
	}
	
	struct FontNames {
		static let glacialIndifferenceRegular = "Glacial Indifference Regular"
	}
    
    struct Identifiers {
		static let profileHeaderCellIdentifier = "profileHeaderCell"
        static let profileSectionCellIdentifier = "profileSectionCell"
		static let manageBusinessesHeaderCellIdentifier = "manageBusinessesHeaderCell"
        static let manageBusinessesCellIdentifier = "manageBusinessesOverviewTableViewCell"
        static let locationSearchResultCellIdentifier = "locationSearchResultCell"
		static let dayOfTheWeekCellIdentifier = "dayOfTheWeekCell"
		static let specificDateCellIdentifier = "specificDateCell"
		static let servicesCellIdentifier = "servicesCell"
		static let assignServicesCellIdentifier = "assignServicesCell"
		static let staffMembersCellIdentifier = "staffMembersCell"
		static let assignStaffCellIdentifier = "assignStaffCell"
    }
	
	struct Nibs {
		static let loadingViewNibName = "LoadingView"
		static let mapViewNibName = "MapView"
		static let listViewNibName = "ListView"
		static let profileHeaderCellNibName = "ProfileHeaderTableViewCell"
		static let profileSectionCellNibName = "ProfileSectionTableViewCell"
		static let manageBusinessesHeaderCellNibName = "ManageBusinessesHeaderTableViewCell"
		static let manageBusinessesCellNibName = "ManageBusinessesOverviewTableViewCell"
		static let specificDateCellNibName = "SpecificDateTableViewCell"
		static let servicesCellNibName = "ServicesTableViewCell"
		static let assignServicesCellNibName = "AssignServicesTableViewCell"
		static let staffMembersCellNibName = "StaffMembersTableViewCell"
		static let assignStaffCellNibName = "AssignStaffTableViewCell"
	}
	
	struct Segues {
		static let firstLaunchSegue = "firstLaunchSegue"
		
		static let signInToRegister = "signInToRegister"
		static let signInToPersonalCode = "signInToPersonalCode"
		static let registerToContinueRegister = "registerToConfirm"
		static let continueRegisterToBusinessRegister = "confirmToBusinessRegister"
		static let registerBusinessToChooseLocation = "registerBusinessToChooseLocation"
		static let registerBusinessToSubscriptionPlanInfo = "registerBusinessToSubscriptionPlanInfo"
		static let registerBusinessToHoursOfOperation = "registerBusinessToHoursOfOperation"
		static let registerBusinessToAddServices = "registerBusinessToAddServices"
		static let registerBusinessToAddStaffMembers = "registerBusinessToAddStaffMembers"
		static let signInToProfile = "signInToProfile"
		
		static let profileToManageBusinesses = "profileToManageBusinesses"
		static let manageBusinessToBusinessRegister = "manageBusinessToAddBusiness"
		
		static let servicesToAddService = "servicesToAddService"
		static let addServiceToAssignStaff = "addServiceToAssignStaff"
		static let assignStaffToSpecificDetails = "assignStaffToSpecificDetails"
		
		static let staffMembersToAddStaffMember = "staffMembersToAddStaffMember"
		static let addStaffMemberToAssignServices = "addStaffMemberToAssignServices"
		static let addStaffMemberToStaffWorkingHours = "addStaffMemberToStaffWorkingHours"
		static let staffWorkingHoursToStaffWeekdaySchedule = "staffWorkingHoursToStaffWeekdaySchedule"
		static let staffWorkingHoursToStaffSpecificDates = "staffWorkingHoursToStaffSpecificDates"
		static let staffSpecificDatesToAddStaffSpecificDate = "staffSpecificDatesToAddStaffSpecificDate"
		static let assignServicesToSpecificDetails = "assignServicesToSpecificDetails"
		
		static let hoursOfOperationToWeekdaySchedule = "hoursOfOperationToWeekdaySchedule"
		static let hoursOfOperationToSpecificDates = "hoursOfOperationToSpecificDates"
		static let specificDatesToAddSpecificDate = "specificDatesToAddSpecificDate"
	}
    
    struct ImageNames {
        static let firstLaunchSlideImageName = "randomScreenshot"
        static let backgroundNoLogo = "background"
        static let backgroundWithLogo = "background.logo"
        static let listView = "list.bullet"
        static let mapView = "map"
        static let ellipsis = "ellipsis.circle"
        static let slider = "slider.horizontal.3"
        static let photoPlaceholder = "photo"
		static let eyeSlash = "eye.slash"
        static let loadingError = "exclamationmark.icloud"
		static let chevronRight = "chevron.right"
    }
    struct Images {
        static let firstLaunchSlideImageName = UIImage(named: K.ImageNames.firstLaunchSlideImageName)
        static let backgroundNoLogo = UIImage(named: K.ImageNames.backgroundNoLogo)
        static let backgroundWithLogo = UIImage(named: K.ImageNames.backgroundWithLogo)
        
        // icons
        @available(iOS 13.0, *)
        static let listViewSystem = UIImage(systemName: K.ImageNames.listView)
        static let listView = UIImage(named: K.ImageNames.listView)
        
        @available(iOS 13.0, *)
        static let mapViewSystem = UIImage(systemName: K.ImageNames.mapView)
        static let mapView = UIImage(named: K.ImageNames.mapView)
        
        @available(iOS 13.0, *)
        static let ellipsisSystem = UIImage(systemName: K.ImageNames.ellipsis)
        static let ellipsis = UIImage(named: K.ImageNames.ellipsis)
        
        @available(iOS 13.0, *)
        static let sliderSystem = UIImage(systemName: K.ImageNames.slider)
        static let slider = UIImage(named: K.ImageNames.slider)
    }
    
    struct Strings {
        static let appName = "STYLYST FB"
		static let dateAndTimeFormatString = "yyyy-MM-dd HH:mm"
		static let dateFormatString = "yyyy-MM-dd"
    }
    
    struct ColorNames {
        static let goldenThemeColorLight = "GoldenThemeColorLight"
        static let goldenThemeColorDark = "GoldenThemeColorDark"
        static let goldenThemeColorDefault = "GoldenThemeColorDefault"
        static let goldenThemeColorInverse = "GoldenThemeColorInverse"
        static let goldenThemeColorDarker = "GoldenThemeColorDarker"
        static let goldenThemeColorInverseMoreContrast = "GoldenThemeColorInverseMoreContrast"
        static let placeholderTextColor = "placeholderTextColor"
    }
    struct Colors {
        static let goldenThemeColorLight = UIColor(named: K.ColorNames.goldenThemeColorLight)
        static let goldenThemeColorDark = UIColor(named: K.ColorNames.goldenThemeColorDark)
        static let goldenThemeColorDefault = UIColor(named: K.ColorNames.goldenThemeColorDefault)
        static let goldenThemeColorInverse = UIColor(named: K.ColorNames.goldenThemeColorInverse)
        static let goldenThemeColorDarker = UIColor(named: K.ColorNames.goldenThemeColorDarker)
        static let goldenThemeColorInverseMoreContrast = UIColor(named: K.ColorNames.goldenThemeColorInverseMoreContrast)
        static let placeholderTextColor = UIColor(named: K.ColorNames.placeholderTextColor)
    }
    
    struct UserDefaultKeys {
        static let launchedBefore = "launchedBefore"
        
        struct User {
            static let firstName = "firstName"
            static let lastName = "lastName"
            static let email = "email"
            static let phoneNumber = "phoneNumber"
            static let phoneNumberFormatted = "phoneNumberFormatted"
            static let password = "password"
            static let verificationID = "verificationID"
            static let otp = "otp"
            static let uid = "uid"
            
            static let sentVerificationCode = "sentVerificationCode"
            static let verifiedPhoneNumber = "verifiedPhoneNumber"
            static let setUpBusinessAccount = "setUpBusinessAccount"
            static let isSignedIn = "isSignedIn"
        }
        
        struct Business {
            static let pendingBusinessDelete = "pendingBusinessDelete"
            static let pendingImagesDelete = "pendingImagesDelete"
            static let pendingLocation = "pendingLocation"
            
            static let docID = "docID"
            //static let businessesArray = "businessesArray"
            
            struct Location {
                static let streetNumber = "streetNumber"
                static let streetName = "streetName"
                static let city = "city"
                static let province = "province"
                static let postalCode = "postalCode"
                static let lat = "lat"
                static let lon = "lon"
            }
        }
        
        
        
    }
    
    struct Firebase {
        struct CollectionNames {
            static let users = "users"
            static let places = "places"
			static let subscriptionPlans = "subscriptionPlans"
        }
        
        struct UserFieldNames {
            static let firstName = "firstName"
            static let lastName = "lastName"
            static let email = "email"
            static let phoneNumber = "phoneNumber"
            static let password = "password"
            static let verificationID = "verificationID"
            static let otp = "otp"
			static let personalCode = "personalCode"
            static let hasBusinessAccount = "hasBusinessAccount"
            static let businesses = "businesses"
			static let employmentLocations = "employmentLocations"
			static let favoritePlaces = "favoritePlaces"
        }
        
        struct PlacesFieldNames {
			static let dateEstablished = "dateEstablished"
            static let name = "name"
            static let addressFormatted = "addressFormatted"
            static let lat = "lat"
            static let lon = "lon"
            static let address = "address"
            struct Address {
                static let streetNumber = "streetNumber"
                static let streetName = "streetName"
                static let city = "city"
                static let province = "province"
                static let postalCode = "postalCode"
            }
            static let ownerUserID = "ownerUserID"
            static let staffUserIDs = "staffUserIDs"
            static let email = "email"
            static let phoneNumber = "phoneNumber"
            static let coordinates = "coordinates"
            static let introParagraph = "introParagraph"
			static let businessType = "businessType"
			
			static let services = "services"
			struct Services {
				static let enabled = "enabled"
				static let name = "name"
				static let description = "description"
				static let defaultPrice = "price"
				static let specificPrices = "prices"
				static let defaultTime = "time"
				static let specificTimes = "times"
				static let staff = "staff"
			}
			
			static let weeklyHours = "weeklyHours"
			static let staffWeeklyHours = "staffWeeklyHours"
			struct WeeklyHours {
				static let monday = "monday"
				static let tuesday = "tuesday"
				static let wednesday = "wednesday"
				static let thursday = "thursday"
				static let friday = "friday"
				static let saturday = "saturday"
				static let sunday = "sunday"
			}
			static let specificHours = "specificHours"
			static let staffSpecificHours = "staffSpecificHours"
			
			static let keywords = "keywords"
			static let subscriptionPlan = "subscriptionPlan"
        }
		
		struct SubscriptionPlansFieldNames {
			static let price = "price"
			static let numStaff = "numStaff"
			static let numStaffDisplay = "numStaffDisplay"
		}
        
        struct Storage {
            static let placesImagesFolder = "placesImages"
        }
        
    }
    
    struct Storyboard {
        static let profileVC = "profileVC"
        static let signInVC = "signInVC"
        static let locationSearchTable = "locationSearchTable"
        static let continueRegisterVC = "continueRegisterVC"
        static let businessRegisterVC = "businessRegisterVC"
    }
}
