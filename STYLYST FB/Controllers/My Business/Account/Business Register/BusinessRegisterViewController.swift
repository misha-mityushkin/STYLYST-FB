//
//  RegisterBusinessViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-06-20.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import Geofirestore

class BusinessRegisterViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
		
    @IBOutlet weak var locationNameTextField: UITextField!
    @IBOutlet weak var contactNumberTextField: UITextField!
    @IBOutlet weak var contactEmailTextField: UITextField!
    
	
	@IBOutlet weak var chooseLocationButton: UIButton!
	@IBOutlet weak var selectedLocationLabel: UILabel!
	@IBOutlet weak var manageBusinessHoursButton: UIButton!
	@IBOutlet weak var manageStaffButton: UIButton!
	@IBOutlet weak var manageServicesButton: UIButton!

    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var chooseImg1: UIButton!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var chooseImg2: UIButton!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var chooseImg3: UIButton!
    @IBOutlet weak var img4: UIImageView!
    @IBOutlet weak var chooseImg4: UIButton!
    @IBOutlet weak var img5: UIImageView!
    @IBOutlet weak var chooseImg5: UIButton!
        
    @IBOutlet weak var introParagraphTextField: UITextField!
	
	@IBOutlet weak var businessTypePickerView: UIPickerView!
	@IBOutlet weak var businessTypeSelectionLabel: UILabel!
	
	@IBOutlet weak var planTypeSegmentedControl: UISegmentedControl!
	@IBOutlet weak var planDetailsLabel: UILabel!
	@IBOutlet weak var monthlyFeeLabel: UILabel!
	@IBOutlet weak var numStaffMembersLabel: UILabel!
    
    var textFields: [UITextField] = []
    var textFieldsHoldAlert = [false, false, false, false]
    
    var spinnerView = LoadingView()
    
    var location: MKMapItem?
    
    var businessLocation: BusinessLocation? // if editing business
    var isEditBusiness = false
    var isNewLocation = false
	var changedImages = false
    var manageBusinessesVC: ManageBusinessesViewController?
    
    var placesDocRef: DocumentReference? //the reference to the document in the "places" firestore collection
    
    var imageViews: [UIImageView] = []
    var imageExists = [false, false, false, false, false]
    var chooseImageButtons: [UIButton] = []
    
    var images: [UIImage] = []
    var imagesData: [Data] = []
    var imageNames: [String] = []
    var numImagesUploaded = 0
    var placeholderImage = UIImage(named: K.ImageNames.photoPlaceholder)
    var selectedImage = 0
	var compressionQuality: CGFloat = 0.3
    
	var weeklyHours: [String : String]?
	var specificHours: [String : String]?
	var staffWeeklyHours: [String : [String : [String]]]?
	var staffSpecificHours: [String : [String : [String]]]?
	
	var services: [[String : Any]] = []
	
	var staffMembers: [User] = []
	
	var subscriptionPlans: [SubscriptionPlan]?
	var selectedPlanIndex = 0
	
	var originalPlanIndex = 0
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(true, forKey: K.UserDefaultKeys.User.sentVerificationCode)
        UserDefaults.standard.set(true, forKey: K.UserDefaultKeys.User.verifiedPhoneNumber)
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
            placeholderImage = UIImage(systemName: K.ImageNames.photoPlaceholder)
        }
		        
        textFields = [locationNameTextField, contactNumberTextField, contactEmailTextField, introParagraphTextField]
        for textField in textFields {
            textField.delegate = self
			textField.addDoneButtonOnKeyboard()
        }
        UITextField.format(textFields: textFields, height: 40, padding: 10)
		
        imageViews = [img1, img2, img3, img4, img5]
        for imageView in imageViews {
            imageView.image = placeholderImage
        }
        chooseImageButtons = [chooseImg1, chooseImg2, chooseImg3, chooseImg4, chooseImg5]
		
		businessTypePickerView.dataSource = self
		businessTypePickerView.delegate = self
		
		loadSubscriptionPlans()
		
		if isEditBusiness {
			titleLabel.text = "Edit Business"
			chooseLocationButton.setTitle("Change Location", for: .normal)
			manageBusinessHoursButton.setTitle("Edit Hours", for: .normal)
			manageStaffButton.setTitle("Edit Staff", for: .normal)
			manageServicesButton.setTitle("Edit Services", for: .normal)
		} else {
			titleLabel.text = "Add Business"
		}
        
        hideKeyboardWhenTappedAround()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		navigationController?.navigationBar.tintColor = K.Colors.goldenThemeColorDefault
        UIView.animate(withDuration: 0.5) {
            self.navigationItem.leftBarButtonItem?.tintColor = K.Colors.goldenThemeColorLight?.withAlphaComponent(1)
            self.navigationController?.makeTransparent()
			let textAttributes = [NSAttributedString.Key.foregroundColor:K.Colors.goldenThemeColorDefault!]
			self.navigationController?.navigationBar.titleTextAttributes = textAttributes
            self.navigationController?.navigationBar.layoutIfNeeded()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.tintColor = K.Colors.goldenThemeColorLight
        navigationController?.makeTransparent()
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        var nonAlteredTextFields: [UITextField] = []
        for i in 0..<textFieldsHoldAlert.count {
            if !textFieldsHoldAlert[i] {
                nonAlteredTextFields.append(textFields[i])
            }
        }
        UITextField.formatBackground(textFields: textFields, height: 40, padding: 10)
        UITextField.formatPlaceholder(textFields: nonAlteredTextFields, height: 40, padding: 10)
    }
	
	func loadSubscriptionPlans() {
		spinnerView.create(parentVC: self)
		Firestore.firestore().collection(K.Firebase.CollectionNames.subscriptionPlans).getDocuments { (querySnapshot, error) in
			if let error = error  {
				self.spinnerView.remove()
				Alerts.showNoOptionAlert(title: "Error", message: "A server-side error occurred. Please check your internet connection, restart the app and try again. Error description: \(error.localizedDescription)", sender: self) { (_) in
					self.dismiss(animated: true, completion: nil)
				}
			} else if let documents = querySnapshot?.documents, !documents.isEmpty {
				print("plans count: \(documents.count)")
				var subscriptionPlans: [SubscriptionPlan] = []
				for document in documents {
					if let price = document.get(K.Firebase.SubscriptionPlansFieldNames.price) as? Double, let numStaff = document.get(K.Firebase.SubscriptionPlansFieldNames.numStaff) as? Int, let numStaffDisplay = document.get(K.Firebase.SubscriptionPlansFieldNames.numStaffDisplay) as? String {
						subscriptionPlans.append(SubscriptionPlan(name: document.documentID, price: price, numStaff: numStaff, numStaffDisplay: numStaffDisplay))
					}
				}
				subscriptionPlans.sort { (plan1, plan2) -> Bool in
					return plan1.price < plan2.price
				}
				self.subscriptionPlans = subscriptionPlans
				var planNames: [String] = []
				for plan in subscriptionPlans {
					planNames.append(plan.name)
				}
				print("plan names: \(planNames)")
				self.planTypeSegmentedControl.replaceSegments(segments: planNames)
				self.planTypeSegmentedControl.selectedSegmentIndex = 0
				let selectedPlan = subscriptionPlans[0]
				self.selectedPlanIndex = 0
				self.planDetailsLabel.text = "\(selectedPlan.name) Plan Details"
				self.monthlyFeeLabel.text = "- $\(Int(selectedPlan.price)) monthly"
				self.numStaffMembersLabel.text = "- \(selectedPlan.numStaffDisplay) staff member"
				if selectedPlan.numStaff != 1 {
					self.numStaffMembersLabel.text?.append("s")
				}
				self.loadDataFromBusinessLocation()
				self.spinnerView.remove()
			} else {
				self.spinnerView.remove()
				Alerts.showNoOptionAlert(title: "Error", message: "A server-side error occurred. Please check your internet connection, restart the app and try again", sender: self) { (_) in
					self.dismiss(animated: true, completion: nil)
				}
			}
		}
	}
    
    
    func loadDataFromBusinessLocation() {
        if let businessLocation = businessLocation {
            locationNameTextField.text = businessLocation.name
            contactNumberTextField.text = Helpers.format(phoneNumber: businessLocation.phoneNumber)
            contactEmailTextField.text = businessLocation.email
            selectedLocationLabel.text = businessLocation.addressFormatted
            location = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: businessLocation.lat, longitude: businessLocation.lon)))
			if location == nil {
				print("location is nil")
			}
			for i in 0..<businessLocation.numActualImages {
				imageViews[i].contentMode = .scaleAspectFill
                imageViews[i].image = businessLocation.images[i]
                chooseImageButtons[i].setTitle("Remove", for: .normal)
                chooseImageButtons[i].setTitleColor(.systemRed, for: .normal)
                imageExists[i] = true
            }
            introParagraphTextField.text = businessLocation.introParagraph
			
			for i in 0..<K.Collections.businessTypeEnums.count {
				if K.Collections.businessTypeEnums[i] == businessLocation.businessType {
					businessTypePickerView.selectRow(i + 1, inComponent: 0, animated: false)
					businessTypeSelectionLabel.text = "Selected: \(K.Collections.businessTypes[i + 1])"
				}
			}
			
			services = businessLocation.services
			staffMembers = businessLocation.staffMembers
			weeklyHours = businessLocation.weeklyHours
			staffWeeklyHours = businessLocation.staffWeeklyHours
			specificHours = businessLocation.specificHours
			staffSpecificHours = businessLocation.staffSpecificHours
			if let subscriptionPlan = businessLocation.subscriptionPlan {
				self.planDetailsLabel.text = "\(subscriptionPlan.name) Plan Details"
				self.monthlyFeeLabel.text = "- $\(Int(subscriptionPlan.price)) monthly"
				self.numStaffMembersLabel.text = "- \(subscriptionPlan.numStaffDisplay) staff member"
				if subscriptionPlan.numStaff != 1 {
					self.numStaffMembersLabel.text?.append("s")
				}
				for i in 0..<subscriptionPlans!.count {
					if subscriptionPlans![i].name == subscriptionPlan.name {
						planTypeSegmentedControl.selectedSegmentIndex = i
						selectedPlanIndex = i
						originalPlanIndex = i
					}
				}
			} else {
				Alerts.showNoOptionAlert(title: "Error", message: "An error occurred. Please check your internet connection, restart the app and try again", sender: self) { (_) in
					self.dismiss(animated: true, completion: nil)
				}
			}
        }
    }
    
    
    @IBAction func chooseLocationPressed(_ sender: UIButton) {
        view.endEditing(true)
        performSegue(withIdentifier: K.Segues.registerBusinessToChooseLocation, sender: self)
    }
	
	@IBAction func subscriptionChanged(_ sender: UISegmentedControl) {
		sender.isUserInteractionEnabled = false
		let selectedPlan = subscriptionPlans![sender.selectedSegmentIndex]
		
		if staffMembers.count > selectedPlan.numStaff && selectedPlan.numStaff > 0 {
			Alerts.showNoOptionAlert(title: "Too Many Staff Members", message: "The \(selectedPlan.name) plan includes up to \(selectedPlan.numStaff) staff members. You currently have \(staffMembers.count) staff members. Please remove the extra staff members before downgrading.", sender: self) { (_) in
				sender.selectedSegmentIndex = self.selectedPlanIndex
				sender.isUserInteractionEnabled = true
			}
			return
		}
		
		selectedPlanIndex = sender.selectedSegmentIndex
		UIView.animate(withDuration: 0.3, animations: {
			self.planDetailsLabel.alpha = 0
			self.monthlyFeeLabel.alpha = 0
			self.numStaffMembersLabel.alpha = 0
		}) { (_) in
			self.planDetailsLabel.text = "\(selectedPlan.name) Plan Details"
			self.monthlyFeeLabel.text = "- $\(Int(selectedPlan.price)) monthly"
			self.numStaffMembersLabel.text = "- \(selectedPlan.numStaffDisplay) staff member"
			if selectedPlan.numStaff != 1 {
				self.numStaffMembersLabel.text?.append("s")
			}
			sender.isUserInteractionEnabled = true
			
			UIView.animate(withDuration: 0.3) {
				self.planDetailsLabel.alpha = 1
				self.monthlyFeeLabel.alpha = 1
				self.numStaffMembersLabel.alpha = 1
			}
		}
	}
	@IBAction func subscriptionPlansMoreDetailsPressed(_ sender: UIButton) {
		performSegue(withIdentifier: K.Segues.registerBusinessToSubscriptionPlanInfo, sender: self)
	}
	
	@IBAction func setHoursPressed(_ sender: UIButton) {
		view.endEditing(true)
		performSegue(withIdentifier: K.Segues.registerBusinessToHoursOfOperation, sender: self)
	}
	
	
	@IBAction func addStaffPressed(_ sender: UIButton) {
		view.endEditing(true)
		performSegue(withIdentifier: K.Segues.registerBusinessToAddStaffMembers, sender: self)
	}
	
	@IBAction func addServicesPressed(_ sender: UIButton) {
		view.endEditing(true)
		performSegue(withIdentifier: K.Segues.registerBusinessToAddServices, sender: self)
	}
	
	
    func setLocation(location: MKMapItem) {
        self.location = location
        selectedLocationLabel.text = Helpers.parseAddress(for: location.placemark)
        selectedLocationLabel.textColor = K.Colors.goldenThemeColorInverse
        chooseLocationButton.setTitle("Change Location", for: .normal)
    }
    
    
    @IBAction func chooseImg1Pressed(_ sender: UIButton) {
        if imageExists[0] {
			changedImages = true
			img1.contentMode = .scaleAspectFit
            img1.image = placeholderImage
            chooseImg1.setTitle("Choose", for: .normal)
            chooseImg1.setTitleColor(.black, for: .normal)
            imageExists[0] = false
        } else {
			spinnerView.create(parentVC: self)
            selectedImage = 0
            showImagePickerController()
        }
    }
    @IBAction func chooseImg2Pressed(_ sender: UIButton) {
        if imageExists[1] {
			changedImages = true
			img2.contentMode = .scaleAspectFit
            img2.image = placeholderImage
            chooseImg2.setTitle("Choose", for: .normal)
            chooseImg2.setTitleColor(.black, for: .normal)
            imageExists[1] = false
        } else {
			spinnerView.create(parentVC: self)
            selectedImage = 1
            showImagePickerController()
        }
    }
    @IBAction func chooseImg3Pressed(_ sender: UIButton) {
        if imageExists[2] {
			changedImages = true
			img3.contentMode = .scaleAspectFit
            img3.image = placeholderImage
            chooseImg3.setTitle("Choose", for: .normal)
            chooseImg3.setTitleColor(.black, for: .normal)
            imageExists[2] = false
        } else {
			spinnerView.create(parentVC: self)
            selectedImage = 2
            showImagePickerController()
        }
    }
    @IBAction func chooseImg4Pressed(_ sender: UIButton) {
        if imageExists[3] {
			changedImages = true
			img4.contentMode = .scaleAspectFit
            img4.image = placeholderImage
            chooseImg4.setTitle("Choose", for: .normal)
            chooseImg4.setTitleColor(.black, for: .normal)
            imageExists[3] = false
        } else {
			spinnerView.create(parentVC: self)
            selectedImage = 3
            showImagePickerController()
        }
    }
    @IBAction func chooseImg5Pressed(_ sender: UIButton) {
        if imageExists[4] {
			changedImages = true
			img5.contentMode = .scaleAspectFit
            img5.image = placeholderImage
            chooseImg5.setTitle("Choose", for: .normal)
            chooseImg5.setTitleColor(.black, for: .normal)
            imageExists[4] = false
        } else {
			spinnerView.create(parentVC: self)
            selectedImage = 4
            showImagePickerController()
        }
    }
    
    
    
    
    @IBAction func continuePressed(_ sender: UIButton) {
		if isEditBusiness {
			Alerts.showTwoOptionAlert(title: "Edit Confirmation", message: "Are you sure you want to apply these changes?", option1: "Confirm", option2: "Cancel", sender: self, handler1: { (_) in
				if self.originalPlanIndex != self.selectedPlanIndex {
					let selectedPlan = self.subscriptionPlans![self.planTypeSegmentedControl.selectedSegmentIndex]
					Alerts.showTwoOptionAlert(title: "Subscription Plan Changed", message: "You have changed your plan to the \(selectedPlan.name) plan. You will now be charged $\(Int(selectedPlan.price)) monthly. Are you sure you want to continue?", option1: "Continue", option2: "Cancel", sender: self, handler1: { (_) in
						self.addOrEditBusiness()
					}, handler2: nil)
				} else {
					self.addOrEditBusiness()
				}
			}, handler2: nil)
		} else {
			Alerts.showTwoOptionAlert(title: "Add Business Confirmation", message: "Are you sure you want to continue? You can change this information in the future.", option1: "Confirm", option2: "Cancel", sender: self, handler1: { (_) in
				let selectedPlan = self.subscriptionPlans![self.planTypeSegmentedControl.selectedSegmentIndex]
				Alerts.showTwoOptionAlert(title: "Subscription Plan Confirmation", message: "You have selected the \(selectedPlan.name) plan. You will be charged $\(Int(selectedPlan.price)) monthly after the 3 month trial period. Are you sure you want to continue?", option1: "Continue", option2: "Cancel", sender: self, handler1: { (_) in
					self.addOrEditBusiness()
				}, handler2: nil)
			}, handler2: nil)
		}
    }
	
	func addOrEditBusiness() {
		images = []
		imagesData = []
		imageNames = []
		
		var isValid = true
		
		if locationNameTextField.text?.isEmptyOrWhitespace() ?? true {
			locationNameTextField.text = ""
			locationNameTextField.changePlaceholderText(to: "You must provide a first name", withColor: .systemRed)
			isValid = false
			textFieldsHoldAlert[0] = true
		}
		if let phoneNumber = contactNumberTextField.text, !phoneNumber.isEmpty {
			if !phoneNumber.isValidPhoneNumber(isFormatted: true) {
				contactNumberTextField.text = ""
				contactNumberTextField.changePlaceholderText(to: "Invalid phone number", withColor: .systemRed)
				isValid = false
				textFieldsHoldAlert[1] = true
			}
		} else {
			contactNumberTextField.changePlaceholderText(to: "You must provide a phone number", withColor: .systemRed)
			isValid = false
			textFieldsHoldAlert[1] = true
		}
		if let email = contactEmailTextField.text, !email.isEmpty {
			if !email.isValidEmail() {
				contactEmailTextField.text = ""
				contactEmailTextField.changePlaceholderText(to: "Invalid email adress", withColor: .systemRed)
				isValid = false
				textFieldsHoldAlert[2] = true
			}
		} else {
			contactEmailTextField.changePlaceholderText(to: "You must provide an email adress", withColor: .systemRed)
			isValid = false
			textFieldsHoldAlert[2] = true
		}
		if let location = location {
			if !isEditBusiness || isNewLocation {
				if Helpers.parseAddress(for: location.placemark).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
					isValid = false
					Alerts.showNoOptionAlert(title: "Error loading address for location", message: "An unknown error occurred and we were unable to find the address of the location you selected. Please try using the full address instead of the common location name", sender: self)
					selectedLocationLabel.text = "Error loading location"
					selectedLocationLabel.textColor = .systemRed
				}
			}
		} else {
			isValid = false
			selectedLocationLabel.text = "You must select a location!"
			selectedLocationLabel.textColor = .systemRed
		}
		
		if let image1 = img1.image, image1 != placeholderImage {
			images.append(image1)
			if let data = image1.jpegData(compressionQuality: compressionQuality) {
				imagesData.append(data)
			} else {
				Alerts.showNoOptionAlert(title: "Error loading image data", message: "An error has occurred while loading the image data for image 1. Please try again", sender: self)
				isValid = false
			}
		}
		if let image2 = img2.image, image2 != placeholderImage {
			images.append(image2)
			if let data = image2.jpegData(compressionQuality: compressionQuality) {
				imagesData.append(data)
			} else {
				Alerts.showNoOptionAlert(title: "Error loading image data", message: "An error has occurred while loading the image data for image 2. Please try again", sender: self)
				isValid = false
			}
		}
		if let image3 = img3.image, image3 != placeholderImage {
			images.append(image3)
			if let data = image3.jpegData(compressionQuality: compressionQuality) {
				imagesData.append(data)
			} else {
				Alerts.showNoOptionAlert(title: "Error loading image data", message: "An error has occurred while loading the image data for image 3. Please try again", sender: self)
				isValid = false
			}
		}
		if let image4 = img4.image, image4 != placeholderImage {
			images.append(image4)
			if let data = image4.jpegData(compressionQuality: compressionQuality) {
				imagesData.append(data)
			} else {
				Alerts.showNoOptionAlert(title: "Error loading image data", message: "An error has occurred while loading the image data for image 4. Please try again", sender: self)
				isValid = false
			}
		}
		if let image5 = img5.image, image5 != placeholderImage {
			images.append(image5)
			if let data = image5.jpegData(compressionQuality: compressionQuality) {
				imagesData.append(data)
			} else {
				Alerts.showNoOptionAlert(title: "Error loading image data", message: "An error has occurred while loading the image data for image 5. Please try again", sender: self)
				isValid = false
			}
		}
		
		if images.isEmpty {
			isValid = false
			Alerts.showNoOptionAlert(title: "Missing images", message: "You must provide at least one image", sender: self)
		}
		
		if let introParagraph = introParagraphTextField.text, !introParagraph.isEmpty {
			if introParagraph.count > 500 {
//				introParagraphTextField.text = ""
//				introParagraphTextField.changePlaceholderText(to: "Too long!", withColor: .systemRed)
				isValid = false
//				textFieldsHoldAlert[3] = true
				Alerts.showNoOptionAlert(title: "Intro paragraph is too long", message: "Your paragraph must be 500 characters or less", sender: self)
				return
			}
		} else {
			introParagraphTextField.changePlaceholderText(to: "You must provide an intro paragraph!", withColor: .systemRed)
			isValid = false
			textFieldsHoldAlert[3] = true
		}
		
		if K.Collections.businessTypes[businessTypePickerView.selectedRow(inComponent: 0)] == "" {
			businessTypeSelectionLabel.text = "You must select a business type!"
			businessTypeSelectionLabel.textColor = .systemRed
			isValid = false
		}
		
		if subscriptionPlans?[planTypeSegmentedControl.selectedSegmentIndex] == nil {
			isValid = false
			Alerts.showNoOptionAlert(title: "Missing subscription plan", message: "Please select a subscription plan", sender: self)
			return
		}
		
		if let weeklyHours = weeklyHours {
			var allDaysSpecified = true
			var unspecifiedDays: [String] = []
			for i in 0..<K.Collections.daysOfTheWeekIdentifiers.count {
				let dayOfTheWeekIdentifier = K.Collections.daysOfTheWeekIdentifiers[i]
				if weeklyHours[dayOfTheWeekIdentifier] == nil || weeklyHours[dayOfTheWeekIdentifier]?.isEmpty ?? true {
					allDaysSpecified = false
					unspecifiedDays.append(K.Collections.daysOfTheWeek[i])
				}
			}
			
			if !allDaysSpecified {
				isValid = false
				var missingDaysString = ""
				
				if unspecifiedDays.count == 1 {
					missingDaysString = unspecifiedDays[0]
				} else {
					for i in 0..<unspecifiedDays.count - 1 {
						missingDaysString.append("\(unspecifiedDays[i]), ")
					}
					missingDaysString.append("and \(unspecifiedDays[unspecifiedDays.count - 1])")
				}
				
				Alerts.showNoOptionAlert(title: "Missing Hours of Operation", message: "You must specify your business hours for each day of the week. You are missing business hours for \(missingDaysString)", sender: self)
			}
		} else {
			isValid = false
			Alerts.showNoOptionAlert(title: "Missing Hours of Operation", message: "You must specify your business hours", sender: self)
		}
		
		if let staffWeeklyHours = staffWeeklyHours {
			var allStaffWeeklyHoursSpecified = true
			var unspecifiedStaffWeeklyHours: [String] = []
			for staffMember in staffMembers {
				if staffWeeklyHours[staffMember.userID] == nil || staffWeeklyHours[staffMember.userID]?.isEmpty ?? true {
					allStaffWeeklyHoursSpecified = false
					unspecifiedStaffWeeklyHours.append("\(staffMember.firstName) \(staffMember.lastName.first ?? Character(""))")
				}
			}
			
			if !allStaffWeeklyHoursSpecified {
				isValid = false
				var missingStaffHoursString = ""
				
				if unspecifiedStaffWeeklyHours.count == 1 {
					missingStaffHoursString = unspecifiedStaffWeeklyHours[0]
				} else {
					for i in 0..<unspecifiedStaffWeeklyHours.count - 1 {
						missingStaffHoursString.append("\(unspecifiedStaffWeeklyHours[i]), ")
					}
					missingStaffHoursString.append("and \(unspecifiedStaffWeeklyHours[unspecifiedStaffWeeklyHours.count - 1])")
				}
				
				Alerts.showNoOptionAlert(title: "Missing Staff Working Hours", message: "You must specify each staff member's weekly working hours for each day of the week. You are missing business hours for \(missingStaffHoursString)", sender: self)
			}
		} else {
			isValid = false
			Alerts.showNoOptionAlert(title: "Missing Staff Working Hours", message: "You must specify each staff member's working hours", sender: self)
		}
		
		if services.count <= 0 {
			isValid = false
			Alerts.showNoOptionAlert(title: "Missing Services", message: "You must add at least one service", sender: self)
		}
		
		if staffMembers.count <= 0 {
			isValid = false
			Alerts.showNoOptionAlert(title: "Missing Staff Members", message: "You must add at least one staff member", sender: self)
		}
		
		
		
		if isValid {
			guard let locationName = locationNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
			guard let phoneNumber = contactNumberTextField.text?.getRawPhoneNumber() else { return }
			guard let email = contactEmailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
			guard let placemark = location?.placemark else { return }
			guard let paragraph = introParagraphTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !paragraph.isEmpty else { return }
			let businessTypeIdentifier = K.Collections.businessTypeIdentifiers[businessTypePickerView.selectedRow(inComponent: 0) - 1]
			let planName = subscriptionPlans![planTypeSegmentedControl.selectedSegmentIndex].name
			var staffUserIDs: [String] = []
			for staffMember in staffMembers {
				staffUserIDs.append(staffMember.userID)
			}
			
			spinnerView.create(parentVC: self)
			
			//address information
			let streetNumber = placemark.subThoroughfare
			let streetName = placemark.thoroughfare
			let cityName = placemark.locality
			let province = placemark.administrativeArea
			let postalCode = placemark.postalCode
			
			let addressFormatted = Helpers.formatAddress(streetNumber: streetNumber ?? "", streetName: streetName ?? "", city: cityName ?? "", province: province ?? "", postalCode: postalCode ?? "")
			//coordinates
			let lat = placemark.coordinate.latitude
			let lon = placemark.coordinate.longitude
			
			var strings: [String] = []
			for service in services {
				if let name = service[K.Firebase.PlacesFieldNames.Services.name] as? String {
					strings.append(name)
				}
			}
			strings.append(locationName)
			strings.append(K.Collections.businessTypes[businessTypePickerView.selectedRow(inComponent: 0)])
			let keywords = Helpers.getKeywords(forArray: strings)
			print(keywords)
			
			//image names
			for i in 1...images.count {
				imageNames.append("image\(i)")
			}
			
			if isEditBusiness { // editing business
				
				if Auth.auth().currentUser != nil {
					
					if let businessLocation = businessLocation {
						
						//firestore references
						let db = Firestore.firestore()
						let placesCollectionRef = db.collection(K.Firebase.CollectionNames.places)
						let geoFirestore = GeoFirestore(collectionRef: placesCollectionRef)
						
						if isNewLocation { // the user changed the location
							spinnerView.label.text = "Updating fields..."
							placesCollectionRef.document(businessLocation.docID).updateData([
								K.Firebase.PlacesFieldNames.address: [
									K.Firebase.PlacesFieldNames.Address.streetNumber: streetNumber,
									K.Firebase.PlacesFieldNames.Address.streetName: streetName,
									K.Firebase.PlacesFieldNames.Address.city: cityName,
									K.Firebase.PlacesFieldNames.Address.province: province,
									K.Firebase.PlacesFieldNames.Address.postalCode: postalCode
								],
								K.Firebase.PlacesFieldNames.addressFormatted: addressFormatted,
								K.Firebase.PlacesFieldNames.lat: lat,
								K.Firebase.PlacesFieldNames.lon: lon,
								K.Firebase.PlacesFieldNames.email: email,
								K.Firebase.PlacesFieldNames.phoneNumber: phoneNumber,
								K.Firebase.PlacesFieldNames.name: locationName,
								K.Firebase.PlacesFieldNames.introParagraph: paragraph,
								K.Firebase.PlacesFieldNames.businessType: businessTypeIdentifier,
								K.Firebase.PlacesFieldNames.subscriptionPlan: planName,
								K.Firebase.PlacesFieldNames.services: services,
								K.Firebase.PlacesFieldNames.staffUserIDs: staffUserIDs,
								K.Firebase.PlacesFieldNames.weeklyHours: weeklyHours ?? [String : String](),
								K.Firebase.PlacesFieldNames.specificHours: specificHours ?? [String : String](),
								K.Firebase.PlacesFieldNames.staffWeeklyHours: staffWeeklyHours ?? [String : [String : [String]]](),
								K.Firebase.PlacesFieldNames.staffSpecificHours: staffSpecificHours ?? [String : [String : [String]]](),
								K.Firebase.PlacesFieldNames.keywords: keywords
							], completion: { (error) in
								if let error = error {
									self.spinnerView.remove()
									Alerts.showNoOptionAlert(title: "Error saving data", message: "There was an error saving your data in our servers. Please restart the app, check your internet connection and try again. Error description: \(error.localizedDescription)", sender: self)
									return
								} else {
									self.spinnerView.label.text = "Changing location..."
									geoFirestore.setLocation(geopoint: GeoPoint(latitude: lat, longitude: lon), forDocumentWithID: businessLocation.docID) { (error) in
										if let error = error {
											UserDefaults.standard.setValue(lat, forKey: K.UserDefaultKeys.Business.Location.lat)
											UserDefaults.standard.setValue(lon, forKey: K.UserDefaultKeys.Business.Location.lon)
											UserDefaults.standard.setValue(businessLocation.docID, forKey: K.UserDefaultKeys.Business.docID)
											UserDefaults.standard.setValue(true, forKey: K.UserDefaultKeys.Business.pendingLocation)
											Alerts.showNoOptionAlert(title: "An error has occured", message: "We were unable to save your business location in our servers. We will retry automatically at a later time. Error description: \(error.localizedDescription)", sender: self)
											
											self.checkForNewImages()
										} else {
											UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.Business.Location.lat)
											UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.Business.Location.lon)
											UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.Business.docID)
											self.checkForNewImages()
										}
									}
								}
							})
							
						} else { // the location was not changed
							spinnerView.label.text = "Updating fields..."
							placesCollectionRef.document(businessLocation.docID).updateData([
								K.Firebase.PlacesFieldNames.email: email,
								K.Firebase.PlacesFieldNames.phoneNumber: phoneNumber,
								K.Firebase.PlacesFieldNames.name: locationName,
								K.Firebase.PlacesFieldNames.introParagraph: paragraph,
								K.Firebase.PlacesFieldNames.businessType: businessTypeIdentifier,
								K.Firebase.PlacesFieldNames.subscriptionPlan: planName,
								K.Firebase.PlacesFieldNames.services: services,
								K.Firebase.PlacesFieldNames.staffUserIDs: staffUserIDs,
								K.Firebase.PlacesFieldNames.weeklyHours: weeklyHours ?? [String : String](),
								K.Firebase.PlacesFieldNames.specificHours: specificHours ?? [String : String](),
								K.Firebase.PlacesFieldNames.staffWeeklyHours: staffWeeklyHours ?? [String : [String : [String]]](),
								K.Firebase.PlacesFieldNames.staffSpecificHours: staffSpecificHours ?? [String : [String : [String]]](),
								K.Firebase.PlacesFieldNames.keywords: keywords
							], completion: { (error) in
								if let error = error {
									self.spinnerView.remove()
									Alerts.showNoOptionAlert(title: "Error saving data", message: "There was an error saving your data in our servers. Please restart the app, check your internet connection and try again. Error description: \(error.localizedDescription)", sender: self)
									return
								} else {
									UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.Business.Location.lat)
									UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.Business.Location.lon)
									UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.Business.docID)
									
									self.checkForNewImages()
								}
							})
							
						}
						
					} else {
						spinnerView.remove()
						Alerts.showNoOptionAlert(title: "An error has occurred", message: "Please restart the app and try again", sender: self) { (_) in
							self.dismiss(animated: true, completion: nil)
						}
					}
				} else {
					spinnerView.remove()
					Alerts.showNoOptionAlert(title: "It appears you are not signed in", message: "Please restart the app and try again", sender: self) { (_) in
						self.dismiss(animated: true, completion: nil)
					}
				}
				
			} else { // adding new business
				
				if let signedInUser = Auth.auth().currentUser {
					spinnerView.label.text = "Adding business..."
					let uid = signedInUser.uid
					
					//firestore references
					let db = Firestore.firestore()
					let placesCollectionRef = db.collection(K.Firebase.CollectionNames.places)
					let geoFirestore = GeoFirestore(collectionRef: placesCollectionRef)
					
					placesDocRef = placesCollectionRef.addDocument(data: [
						K.Firebase.PlacesFieldNames.address: [
							K.Firebase.PlacesFieldNames.Address.streetNumber: streetNumber,
							K.Firebase.PlacesFieldNames.Address.streetName: streetName,
							K.Firebase.PlacesFieldNames.Address.city: cityName,
							K.Firebase.PlacesFieldNames.Address.province: province,
							K.Firebase.PlacesFieldNames.Address.postalCode: postalCode
						],
						K.Firebase.PlacesFieldNames.addressFormatted: addressFormatted,
						K.Firebase.PlacesFieldNames.lat: lat,
						K.Firebase.PlacesFieldNames.lon: lon,
						K.Firebase.PlacesFieldNames.email: email,
						K.Firebase.PlacesFieldNames.phoneNumber: phoneNumber,
						K.Firebase.PlacesFieldNames.name: locationName,
						K.Firebase.PlacesFieldNames.dateEstablished: Date().dateStringWith(strFormat: K.Strings.dateFormatString),
						K.Firebase.PlacesFieldNames.ownerUserID: uid,
						K.Firebase.PlacesFieldNames.introParagraph: paragraph,
						K.Firebase.PlacesFieldNames.businessType: businessTypeIdentifier,
						K.Firebase.PlacesFieldNames.subscriptionPlan: planName,
						K.Firebase.PlacesFieldNames.services: services,
						K.Firebase.PlacesFieldNames.staffUserIDs: staffUserIDs,
						K.Firebase.PlacesFieldNames.weeklyHours: weeklyHours ?? [String : String](),
						K.Firebase.PlacesFieldNames.specificHours: specificHours ?? [String : String](),
						K.Firebase.PlacesFieldNames.staffWeeklyHours: staffWeeklyHours ?? [String : [String : [String]]](),
						K.Firebase.PlacesFieldNames.staffSpecificHours: staffSpecificHours ?? [String : [String : [String]]](),
						K.Firebase.PlacesFieldNames.keywords: keywords
					]) { (error) in
						if error == nil {
							self.addBusinessRefToUser(usingDatabase: db, toUserWithID: uid, geoFirestore: geoFirestore, geoPoint: GeoPoint(latitude: lat, longitude: lon))
						} else {
							self.spinnerView.remove()
							Alerts.showNoOptionAlert(title: "Error saving data", message: "There was an error saving your data in our servers. Please restart the app, check your internet connection and try again. Error description: \(error!.localizedDescription)", sender: self)
							return
						}
					}
				} else {
					spinnerView.remove()
					Alerts.showNoOptionAlert(title: "Your session has expired", message: "Please sign in to restart your registration", sender: self) { (_) in
						self.dismiss(animated: true, completion: nil)
					}
				}
			}
		} else {
			Alerts.showNoOptionAlert(title: "Missing or incomplete information", message: "Please go back and check the fields marked with red to find what information is either missing, incomplete, or incorrect", sender: self)
		}
	}
	
    
    func addBusinessRefToUser(usingDatabase db: Firestore, toUserWithID uid: String, geoFirestore: GeoFirestore, geoPoint: GeoPoint) {
		spinnerView.label.text = "Linking to your account..."
        if let docID = placesDocRef?.documentID {
            
            db.collection(K.Firebase.CollectionNames.users).document(uid).getDocument { (document, error) in
                if let document = document, document.exists, error == nil {
                    
                    var businesses: [String] = document.get(K.Firebase.UserFieldNames.businesses) as? [String] ?? []
                    businesses.append(docID)
                    
                    db.collection(K.Firebase.CollectionNames.users).document(uid).updateData([
                        K.Firebase.UserFieldNames.businesses: businesses,
                        K.Firebase.UserFieldNames.hasBusinessAccount: true
                    ]) { (error) in
                        if error == nil {
							self.spinnerView.label.text = "Setting location..."
                            
                            geoFirestore.setLocation(geopoint: geoPoint, forDocumentWithID: docID) { (error) in
                                if let error = error {
                                    self.spinnerView.remove()
                                    UserDefaults.standard.setValue(geoPoint.latitude, forKey: K.UserDefaultKeys.Business.Location.lat)
                                    UserDefaults.standard.setValue(geoPoint.longitude, forKey: K.UserDefaultKeys.Business.Location.lon)
                                    UserDefaults.standard.setValue(docID, forKey: K.UserDefaultKeys.Business.docID)
                                    UserDefaults.standard.setValue(true, forKey: K.UserDefaultKeys.Business.pendingLocation)
                                    Alerts.showNoOptionAlert(title: "An error has occured", message: "we were unable to save your business location in our servers. We will retry automatically at a later time. Error description: \(error.localizedDescription)", sender: self) { (_) in
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                } else {
									self.spinnerView.label.text = "Uploading images..."
                                    UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.Business.Location.lat)
                                    UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.Business.Location.lon)
                                    UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.Business.docID)
                                    self.addImages(using: Storage.storage().reference().child(K.Firebase.Storage.placesImagesFolder))
                                }
                            }
                        } else {
                            self.spinnerView.remove()
                            Alerts.showNoOptionAlert(title: "An error has occured", message: "Please sign in to restart your registration", sender: self) { (_) in
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                } else {
                    self.spinnerView.remove()
                    Alerts.showNoOptionAlert(title: "An error has occured", message: "Please sign in to restart your registration", sender: self) { (_) in
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        } else {
            self.spinnerView.remove()
            Alerts.showNoOptionAlert(title: "Error saving your business location data to our servers", message: "Please restart the app, check your internet connection and try again", sender: self)
        }
    }
	
	func checkForNewImages() {
		if self.changedImages {
			spinnerView.label.text = "Updating images..."
			self.addImages(using: Storage.storage().reference().child(K.Firebase.Storage.placesImagesFolder))
		} else {
			spinnerView.remove()
			Alerts.showNoOptionAlert(title: "Success", message: "Your business details were changed successfully", sender: self) { (_) in
				self.dismiss(animated: true) {
					self.manageBusinessesVC?.getBusinessIDs()
				}
			}
		}
	}
    
    func addImages(using imagesStorageReference: StorageReference) {
		if placesDocRef?.documentID != nil || businessLocation?.docID != nil {
			var docID: String = ""
			if placesDocRef?.documentID != nil {
				docID = placesDocRef!.documentID
			} else if businessLocation?.docID != nil {
				docID = businessLocation!.docID
			} else {
				Alerts.showNoOptionAlert(title: "Error saving your images to our servers", message: "Please restart the app, check your internet connection and try again", sender: self)
				self.spinnerView.remove()
				return
			}
			
			let specificImageFolder = imagesStorageReference.child(docID)
			
			// add the non-nil images
			for i in 0..<self.images.count {
				let data = self.imagesData[i]
				let name = self.imageNames[i]
				
				let imageRef = specificImageFolder.child(name)
				
				imageRef.putData(data, metadata: nil) { (metadata, error) in
					if let error = error {
						self.numImagesUploaded += 1
						Alerts.showNoOptionAlert(title: "An error occurred while uploading \(name) to our server", message: "Please check your internet connection, restart the app and try again. Error description: \(error.localizedDescription)", sender: self)
					} else {
						
						self.numImagesUploaded += 1
						if self.numImagesUploaded >= self.images.count {
							
							// remove the nil images from storage (if there are any)
							let numToDelete = 5 - self.images.count
							var numDeleted = 0
							if self.images.count < 5 {
								for i in self.images.count + 1...5 {
									specificImageFolder.child("image\(i)").delete { (_) in
										numDeleted += 1
										if numDeleted >= numToDelete {
											self.spinnerView.remove()
											
											if self.isEditBusiness {
												Alerts.showNoOptionAlert(title: "Success", message: "Your business details were changed successfully", sender: self) { (_) in
													self.dismiss(animated: true, completion: nil)
													self.manageBusinessesVC?.getBusinessIDs()
												}
											} else {
												Alerts.showNoOptionAlert(title: "Success", message: "Your business was added successfully", sender: self) { (_) in
													self.dismiss(animated: true, completion: nil)
													self.manageBusinessesVC?.getBusinessIDs()
												}
											}
										}
									}
								}
							} else {
								self.spinnerView.remove()
								
								if self.isEditBusiness {
									Alerts.showNoOptionAlert(title: "Success", message: "Your business details were changed successfully", sender: self) { (_) in
										self.dismiss(animated: true, completion: nil)
										self.manageBusinessesVC?.getBusinessIDs()
									}
								} else {
									Alerts.showNoOptionAlert(title: "Success", message: "Your business was added successfully", sender: self) { (_) in
										self.dismiss(animated: true, completion: nil)
										self.manageBusinessesVC?.getBusinessIDs()
									}
								}
							}
							
						}
						
					}
				}
			}
		}
    }
    
    
    
    
    func deleteBusiness() {
        spinnerView.create(parentVC: self)
        if let user = Auth.auth().currentUser {
            if let businessLocation = businessLocation {
				spinnerView.label.text = "Removing reference..."
                let db = Firestore.firestore()
                
                let userCollectionRef = db.collection(K.Firebase.CollectionNames.users)
                let placesCollectionRef = db.collection(K.Firebase.CollectionNames.places)
                
                let userDocumentRef = userCollectionRef.document(user.uid)
                let placeDocumentRef = placesCollectionRef.document(businessLocation.docID)
                
                userDocumentRef.getDocument { (document, error) in
                    if let document = document, document.exists, error == nil {
                        if var businessesArray = document.get(K.Firebase.UserFieldNames.businesses) as? [String], !businessesArray.isEmpty {
                            var removedBusiness = false
                            for i in 0..<businessesArray.count {
                                if businessesArray[i] == businessLocation.docID {
                                    businessesArray.remove(at: i)
                                    removedBusiness = true
									break
                                }
                            }
                            
                            if removedBusiness {
                                
                                userDocumentRef.updateData([
                                    K.Firebase.UserFieldNames.businesses: businessesArray
                                ]) { (error) in
                                    if let error = error {
                                        Alerts.showNoOptionAlert(title: "Unable to remove business", message: "Please restart the app, check your internet connection and try again. Error description: \(error.localizedDescription)", sender: self) { (_) in
                                            self.dismiss(animated: true) {
                                                self.manageBusinessesVC?.getBusinessIDs()
                                            }
                                        }
                                    } else {
										self.spinnerView.label.text = "Deleting business..."
                                        placeDocumentRef.delete { (error) in
                                            if let error = error {
                                                Alerts.showNoOptionAlert(title: "Minor error removing business", message: "Your business was not entirely removed. We will retry automatically at a later time. Error description: \(error.localizedDescription)", sender: self) { (_) in
                                                    UserDefaults.standard.setValue(true, forKey: K.UserDefaultKeys.Business.pendingBusinessDelete)
                                                    UserDefaults.standard.setValue(businessLocation.docID, forKey: K.UserDefaultKeys.Business.docID)
                                                    self.dismiss(animated: true) {
                                                        self.manageBusinessesVC?.getBusinessIDs()
                                                    }
                                                }
                                            } else { //might want to delete images regardless of whether business ref was deleted
												self.spinnerView.label.text = "Deleting images..."
                                                let imagesFolderRef = Storage.storage().reference().child("\(K.Firebase.Storage.placesImagesFolder)/\(businessLocation.docID)")
                                                var numDeletedImages = 0
                                                var numErrors = 0
                                                var lastError: Error?
												
												imagesFolderRef.listAll { (result, error) in
													if let error = error {
														Alerts.showNoOptionAlert(title: "Error deleting images", message: "Your business was deleted, however, we were unable to delete the images from our database. We will retry at a later time. Error description: \(error.localizedDescription)", sender: self) { (_) in
															self.dismiss(animated: true) {
																self.manageBusinessesVC?.getBusinessIDs()
															}
														}
													} else {
														
														for i in 1...result.items.count {
															imagesFolderRef.child("image\(i)").delete { (error) in
																if let error = error {
																	numErrors += 1
																	lastError = error
																} else {
																	numDeletedImages += 1
																}
																if numDeletedImages + numErrors >= result.items.count {
																	self.spinnerView.remove()
																	if numErrors > 0 {
																		Alerts.showNoOptionAlert(title: "Error deleting image", message: "Your business was deleted, however, we were unable to delete an image from our database. We will retry at a later time. Error description: \(lastError!.localizedDescription)", sender: self) { (_) in
																			self.dismiss(animated: true) {
																				self.manageBusinessesVC?.getBusinessIDs()
																			}
																		}
																	} else {
																		Alerts.showNoOptionAlert(title: "Success", message: "Your business was deleted successfully", sender: self) { (_) in
																			self.dismiss(animated: true) {
																				self.manageBusinessesVC?.getBusinessIDs()
																			}
																		}
																	}
																}
															}
														}
														
													}
												}
                                            }
                                        }
                                    }
                                }
                            } else {
                                Alerts.showNoOptionAlert(title: "Unable to remove business", message: "Please restart the app, check your internet connection and try again.", sender: self) { (_) in
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        } else {
                            Alerts.showNoOptionAlert(title: "An error occurred", message: "Please restart the app, check your internet connection and try again.", sender: self) { (_) in
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    } else {
                        Alerts.showNoOptionAlert(title: "An error occurred", message: "Please restart the app and try again. Error description: \(error?.localizedDescription ?? "No Description")", sender: self) { (_) in
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            } else {
                Alerts.showNoOptionAlert(title: "Error removing business", message: "Please restart the app and try again", sender: self) { (_) in
                    self.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            Alerts.showNoOptionAlert(title: "It appears your are not signed in", message: "Please restart the app and try again", sender: self) { (_) in
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
	
    
    
    @objc func cancelButtonPressed() {
		Alerts.showTwoOptionAlertDestructive(title: "Are you sure you want to exit?", message: "Your changes will not be saved", sender: self, option1: "Exit", option2: "Stay", is1Destructive: true, is2Destructive: false, handler1: { (_) in
			self.dismiss(animated: true, completion: nil)
		}, handler2: nil)
    }
	
	
	@objc func deletePressed() {
		Alerts.showThreeOptionAlert(title: "What would you like to remove?", message: "You can delete your business from our database entirely, or cancel your STYLYST For Business subscription. Canceling your subscription WILL NOT delete your business until the end of the billing cycle.", sender: self, option1: "Delete Business", option2: "Remove Subscription", option3: "Nevermind", is1Destructive: true, is2Destructive: true, is3Destructive: false, handler1: { (_) in
			Alerts.showTwoOptionAlertDestructive(title: "Are you sure you want to delete your business entirely?", message: "This action cannot be undone!", sender: self, option1: "Delete", option2: "Cancel", is1Destructive: true, is2Destructive: false, handler1: { (_) in
				self.deleteBusiness()
			}, handler2: nil)
		}, handler2: nil, handler3: nil)
	}
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ChooseLocationViewController {
			let chooseLocationVC = segue.destination as! ChooseLocationViewController
            chooseLocationVC.businessRegisterVC = self
			if isEditBusiness {
				let address = businessLocation!.addressFormatted
				let geoCoder = CLGeocoder()
				geoCoder.geocodeAddressString(address) { (placemarks, error) in
					guard let placemarks = placemarks, let location = placemarks.first?.location else { return }
					chooseLocationVC.setLocation(location: MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate)))
					chooseLocationVC.selectedLocationPin.title = address
				}
			} else {
				if let location = location {
					chooseLocationVC.selectedLocation = location
				}
			}
		} else if segue.destination is SubscriptionPlansViewController {
			let subscriptionPlansVC = segue.destination as! SubscriptionPlansViewController
			subscriptionPlansVC.businessRegisterVC = self
		} else if segue.destination is HoursOfOperationViewController {
			let hoursOfOperationVC = segue.destination as! HoursOfOperationViewController
			hoursOfOperationVC.businessRegisterVC = self
		} else if segue.destination is StaffMembersTableViewController {
			let staffMembersVC = segue.destination as! StaffMembersTableViewController
			staffMembersVC.businessRegisterVC = self
			staffMembersVC.staffMembers = staffMembers
		} else if segue.destination is ServicesTableViewController {
			let servicesVC = segue.destination as! ServicesTableViewController
			servicesVC.businessRegisterVC = self
			servicesVC.services = services
		}
    }

}








extension BusinessRegisterViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == locationNameTextField {
            textField.changePlaceholderText(to: "Business Name")
        } else if textField == contactNumberTextField {
            textField.changePlaceholderText(to: "Contact Number")
        } else if textField == contactEmailTextField {
            textField.changePlaceholderText(to: "Contact Email")
        } else if textField == introParagraphTextField {
            textField.changePlaceholderText(to: "Business description")
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == contactNumberTextField {
            var fullString = textField.text ?? ""
            fullString.append(string)
            if range.length == 1 {
                textField.text = Helpers.format(phoneNumber: fullString, shouldRemoveLastDigit: true)
            } else {
                textField.text = Helpers.format(phoneNumber: fullString)
            }
            return false
        } else if textField == introParagraphTextField {
            let maxLength = 500
            let currentString: NSString = textField.text! as NSString
            let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
        return true
    }
    
}










extension BusinessRegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showImagePickerController() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true) {
            self.spinnerView.remove()
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            switch selectedImage {
                case 0:
					img1.contentMode = .scaleAspectFill
                    img1.image = editedImage
                    chooseImg1.setTitle("Remove", for: .normal)
                    chooseImg1.setTitleColor(.systemRed, for: .normal)
                case 1:
					img2.contentMode = .scaleAspectFill
                    img2.image = editedImage
                    chooseImg2.setTitle("Remove", for: .normal)
                    chooseImg2.setTitleColor(.systemRed, for: .normal)
                case 2:
					img3.contentMode = .scaleAspectFill
                    img3.image = editedImage
                    chooseImg3.setTitle("Remove", for: .normal)
                    chooseImg3.setTitleColor(.systemRed, for: .normal)
                case 3:
					img4.contentMode = .scaleAspectFill
                    img4.image = editedImage
                    chooseImg4.setTitle("Remove", for: .normal)
                    chooseImg4.setTitleColor(.systemRed, for: .normal)
                case 4:
					img5.contentMode = .scaleAspectFill
                    img5.image = editedImage
                    chooseImg5.setTitle("Remove", for: .normal)
                    chooseImg5.setTitleColor(.systemRed, for: .normal)
                default: break
            }
            imageExists[selectedImage] = true
			changedImages = true
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            switch selectedImage {
                case 0:
					img1.contentMode = .scaleAspectFill
                    img1.image = originalImage
                    chooseImg1.setTitle("Remove", for: .normal)
                    chooseImg1.setTitleColor(.systemRed, for: .normal)
                case 1:
					img2.contentMode = .scaleAspectFill
                    img2.image = originalImage
                    chooseImg2.setTitle("Remove", for: .normal)
                    chooseImg2.setTitleColor(.systemRed, for: .normal)
                case 2:
					img3.contentMode = .scaleAspectFill
                    img3.image = originalImage
                    chooseImg3.setTitle("Remove", for: .normal)
                    chooseImg3.setTitleColor(.systemRed, for: .normal)
                case 3:
					img4.contentMode = .scaleAspectFill
                    img4.image = originalImage
                    chooseImg4.setTitle("Remove", for: .normal)
                    chooseImg4.setTitleColor(.systemRed, for: .normal)
                case 4:
					img5.contentMode = .scaleAspectFill
                    img5.image = originalImage
                    chooseImg5.setTitle("Remove", for: .normal)
                    chooseImg5.setTitleColor(.systemRed, for: .normal)
                default: break
            }
            imageExists[selectedImage] = true
			changedImages = true
        }
        
        dismiss(animated: true, completion: nil)
        
    }
}



extension BusinessRegisterViewController: UIPickerViewDataSource, UIPickerViewDelegate {

	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return K.Collections.businessTypes.count
	}

	func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		return NSAttributedString(string: K.Collections.businessTypes[row], attributes: [NSAttributedString.Key.foregroundColor: K.Colors.goldenThemeColorDefault ?? UIColor.black])
	}

	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		businessTypeSelectionLabel.textColor = K.Colors.goldenThemeColorDefault
		if K.Collections.businessTypes[row].isEmpty {
			businessTypeSelectionLabel.text = "Selected: None"
		} else {
			businessTypeSelectionLabel.text = "Selected: \(K.Collections.businessTypes[row])"
		}
	}

}



extension BusinessRegisterViewController: UIScrollViewDelegate {

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		if scrollView.contentOffset.y >= titleLabel.frame.maxY {
			if navigationItem.title != titleLabel.text {
				navigationItem.title = titleLabel.text
			}
		} else {
			if navigationItem.title == titleLabel.text {
				navigationItem.title = nil
			}
		}
		
	}

}
