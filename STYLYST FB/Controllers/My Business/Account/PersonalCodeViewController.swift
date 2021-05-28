//
//  PersonalCodeViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-09-02.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import Firebase

class PersonalCodeViewController: UIViewController {

	@IBOutlet weak var navigationBar: UINavigationBar!
	
	@IBOutlet weak var personalCodeTextField: UITextField!
	
	var signInVC: SignInViewController?
	
	var textFields: [UITextField] = []
	var textFieldsHoldAlert = [false]
	
	var spinnerView = LoadingView()
		
	override func viewDidLoad() {
        super.viewDidLoad()
		
		if #available(iOS 13.0, *) {
			isModalInPresentation = true
		}
		
		textFields = [personalCodeTextField]
		for textField in textFields {
			textField.delegate = self
		}
		UITextField.format(textFields: textFields, height: 40, padding: 10)
		
		hideKeyboardWhenTappedAround()
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationBar.makeTransparent()
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
	
	
	@IBAction func continuePressed(_ sender: UIButton) {
		var isValid = true
		
		if let personalCode = personalCodeTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !personalCode.isEmpty {
			if !personalCode.isValidPersonalCode() {
				personalCodeTextField.changePlaceholderText(to: "Must be a 4 digit code", withColor: .systemRed)
				isValid = false
				textFieldsHoldAlert[0] = true
			}
		} else {
			personalCodeTextField.changePlaceholderText(to: "You must provide a personal code", withColor: .systemRed)
			isValid = false
			textFieldsHoldAlert[0] = true
		}
		
		if isValid {
			askInitialBusinessSetupQuestions()
		}
	}
	
	
	func askInitialBusinessSetupQuestions() {
		if let uid = Auth.auth().currentUser?.uid {
			let userDocRef = Firestore.firestore().collection(K.Firebase.CollectionNames.users).document(uid)
			
			Alerts.showTwoOptionAlert(title: "More Account Details", message: "Are you a business owner or a staff member? If you own a business and plan on working there yourself, please select \"Business Owner\".", option1: "Business Owner", option2: "Staff Member", sender: self) { (_) in // Business Owner
				
				Alerts.showTwoOptionAlert(title: "Would you like to register your business now?", message: "In order to register your business, your staff members must already have a STYLYST For Business account", option1: "Register Now", option2: "Register Later", sender: self) { (_) in // Register Now
					
					self.spinnerView.create(parentVC: self)
					self.spinnerView.label.text = "Creating business account..."
					userDocRef.updateData([
						K.Firebase.UserFieldNames.hasBusinessAccount: true,
						K.Firebase.UserFieldNames.personalCode: self.personalCodeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
					]) { (error) in
						self.spinnerView.remove()
						if let error = error {
							
							Alerts.showNoOptionAlert(title: "An error occurred", message: "Please restart the app and try again. Error description: \(error.localizedDescription)", sender: self)
							
						} else {
							
							UserDefaults.standard.set(true, forKey: K.UserDefaultKeys.User.setUpBusinessAccount)
							self.dismiss(animated: true) {
								self.signInVC?.destination = self.signInVC?.destinationBusinessRegister
								self.signInVC?.performSegue(withIdentifier: K.Segues.signInToRegister, sender: self.signInVC)
							}
							Alerts.showNoOptionAlert(title: "Register your business", message: "Your account is created. Now it is time to register your business with us. You can always add more businesses later on", sender: self.signInVC!)
							
						}
					}
					
				} handler2: { (_) in // Register Later
					
					self.spinnerView.create(parentVC: self)
					self.spinnerView.label.text = "Creating business account..."
					userDocRef.updateData([
						K.Firebase.UserFieldNames.hasBusinessAccount: true,
						K.Firebase.UserFieldNames.personalCode: self.personalCodeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
					]) { (error) in
						self.spinnerView.remove()
						if let error = error {
							Alerts.showNoOptionAlert(title: "An error occurred", message: "Please restart the app and try again. Error description: \(error.localizedDescription)", sender: self)
						} else {
							Alerts.showNoOptionAlert(title: "Success", message: "Your account was created successfully. When you are ready to add your first business, sign in, tap \"Manage Businesses\", \"+\"", sender: self) { (_) in
								UserDefaults.standard.set(true, forKey: K.UserDefaultKeys.User.setUpBusinessAccount)
								self.dismiss(animated: true, completion: nil)
							}
						}
					}
					
				}
				
			} handler2: { (_) in // Staff Member
				
				self.spinnerView.create(parentVC: self)
				self.spinnerView.label.text = "Creating business account..."
				userDocRef.updateData([
					K.Firebase.UserFieldNames.hasBusinessAccount: true,
					K.Firebase.UserFieldNames.personalCode: self.personalCodeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
				]) { (error) in
					self.spinnerView.remove()
					if let error = error {
						Alerts.showNoOptionAlert(title: "An error occurred", message: "Please restart the app and try again. Error description: \(error.localizedDescription)", sender: self)
					} else {
						Alerts.showNoOptionAlert(title: "Success", message: "Your account was created successfully. Ask your employer to add you as a staff member using the same email you used to create your account", sender: self) { (_) in
							UserDefaults.standard.set(true, forKey: K.UserDefaultKeys.User.setUpBusinessAccount)
							self.dismiss(animated: true, completion: nil)
						}
					}
				}
				
			}
			
		} else {
			Alerts.showNoOptionAlert(title: "An unknown error occurred", message: "Please restart the app and try again", sender: self)
		}
	}
	
	
	@IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		Alerts.showTwoOptionAlertDestructive(title: "Are you sure you want to exit?", message: "You have not finished the registration process. You can finish the process later.", sender: self, option1: "Exit", option2: "Stay", is1Destructive: true, is2Destructive: false, handler1: { (_) in
			self.dismiss(animated: true, completion: nil)
		}, handler2: nil)
	}
	
	
}



extension PersonalCodeViewController: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		if textField == personalCodeTextField {
			textField.changePlaceholderText(to: "Personal Identifier Code")
		}
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if textField == personalCodeTextField {
			let maxLength = 4
			let currentString: NSString = textField.text! as NSString
			let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
			return newString.length <= maxLength
		}
		return true
	}
}
