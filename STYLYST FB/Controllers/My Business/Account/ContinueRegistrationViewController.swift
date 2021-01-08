//
//  ConfirmRegistrationViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-06-20.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import Firebase

class ContinueRegistrationViewController: UIViewController {
    
    @IBOutlet weak var otpTextField: UITextField!
    @IBOutlet weak var passwordTextField: PasswordTextField!
    @IBOutlet weak var confirmPasswordTextField: PasswordTextField!
    @IBOutlet weak var strengthProgressView: UIProgressView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var instructionHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var continueButton: UIButton!
    
    var firstName: String?
    var lastName: String?
    var email: String?
    var phoneNumber: String?
	var personalCode: String?
    var verificationID: String?
    
    var textFields: [UITextField] = []
    var textFieldsHoldAlert = [false, false, false]

    var spinnerView = LoadingView()
    
    var isPasswordValid: Bool = false

    override func viewDidLoad() {
        print("confirm registration did load")
        super.viewDidLoad()
                
        strengthProgressView.setProgress(0, animated: true)
        instructionLabel.textColor = UIColor.systemRed
        instructionLabel.text = ""
        instructionLabel.isHidden = true
        
        navigationController?.isNavigationBarHidden = false
        
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }

        textFields = [otpTextField, passwordTextField, confirmPasswordTextField]
        for textField in textFields {
            textField.delegate = self
			textField.addDoneButtonOnKeyboard()
        }
        UITextField.format(textFields: textFields, height: 40, padding: 10)
        let passwordIcon: UIImage
        if #available(iOS 13.0, *) {
            passwordIcon = UIImage(systemName: K.ImageNames.eyeSlash)!
        } else {
            passwordIcon = UIImage(named: K.ImageNames.eyeSlash)!
        }
        passwordTextField.setRightViewButton(icon: passwordIcon, width: passwordTextField.frame.height * 1.05, height: passwordTextField.frame.height * 0.7, parentVC: self, action: #selector(self.showHidePassword(_:)))
        confirmPasswordTextField.setRightViewButton(icon: passwordIcon, width: passwordTextField.frame.height * 1.05, height: passwordTextField.frame.height * 0.7, parentVC: self, action: #selector(self.showHidePassword(_:)))

        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.makeTransparent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.makeTransparent()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.returnToOriginalState()
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
    
    
    
    @IBAction func passwordEditingChanged(_ sender: PasswordTextField) {
        
        if sender.changingPasswordVisibility {
            return
        }
        if let password = passwordTextField.text, password.isNotEmpty {
            let validationId = PasswordStrengthManager.checkValidationWithUniqueCharacter(pass: password, rules: PasswordRules.passwordRule, minLength: PasswordRules.minPasswordLength, maxLength: PasswordRules.maxPasswordLength)
            UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: { [weak self] in
                print("animate with unknown alpha")
                self?.instructionLabel.alpha = CGFloat(validationId.alpha)
                self?.instructionHeightConstraint.constant = CGFloat(validationId.constant)
                self?.instructionLabel.text  = validationId.text
            })
            
            let progressInfo = PasswordStrengthManager.setProgressView(strength: validationId.strength)
            self.isPasswordValid = progressInfo.shouldValid
            self.strengthProgressView.setProgress(progressInfo.percentage, animated: true)
            self.strengthProgressView.progressTintColor = UIColor.colorFrom(hexString: progressInfo.color)
            if validationId.strength == .strong || validationId.strength == .veryStrong {
                if instructionLabel.alpha == 1 && !instructionLabel.isHidden && instructionHeightConstraint.constant != 0 {
                    UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: { [weak self] in
                        print("animate to disapear2")
                        self?.instructionLabel.alpha = 0
                        self?.instructionLabel.isHidden = true
                    })
                }
            } else {
                UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: { [weak self] in
                    print("animate to appear1")
                    self?.instructionLabel.alpha = 1
                    self?.instructionHeightConstraint.constant = 25
                    self?.instructionLabel.isHidden = false
                })
            }
        } else {
            self.instructionLabel.isHidden = false
            self.instructionLabel.alpha = 0
            self.strengthProgressView.setProgress(0, animated: true)
            UIView.animate(withDuration: 0.5, delay: 0, options: [], animations: { [weak self] in
                print("animate to appear2")
                self?.instructionLabel.alpha = 1
                self?.instructionHeightConstraint.constant = 25
                self?.instructionLabel.text = "Password cannot be empty."
            })
        }
    }
    
    

    @IBAction func continuePressed(_ sender: UIButton) {
        
        Alerts.showTwoOptionAlert(title: "Registration Confirmation", message: "Once you leave this page, you will not be able to change your account details such as your name, email, phone number, etc. Do you wish to proceed or go back and verify your details?", option1: "Proceed", option2: "Go Back", sender: self, handler1: { (_) in
            
            
            if let password = self.passwordTextField.text, !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                print("password is not empty")
                if let confirmedPassword = self.confirmPasswordTextField.text, !confirmedPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    print("confirmed password is not empty")
                    if self.isPasswordValid {
                        print("password is valid")
                        if password == confirmedPassword {
                            print("passwords match")
                            if let otpCode = self.otpTextField.text, !otpCode.isEmpty {
                                print("otp code is not empty")
                                
                                                       
                                guard let verificationID = UserDefaults.standard.string(forKey: K.UserDefaultKeys.User.verificationID) else {
                                    Alerts.showNoOptionAlert(title: "Error verifying phone number", message: "An error has occurred while retrieving verification code please go back to the previous page and re-verify your phone number", sender: self)
                                    return
                                }
                                self.hideKeyboard()
                                self.spinnerView.create(parentVC: self)
								self.spinnerView.label.text = "Creating account..."
                                self.continueButton.isUserInteractionEnabled = false
                                
                                let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: otpCode)
                                
                                Auth.auth().signIn(with: credential) { (result, error) in
                                    if error == nil {
                                        let user = result!.user
                                        
										guard let firstName = self.firstName, let lastName = self.lastName, let email = self.email, let phoneNumber = self.phoneNumber, let personalCode = self.personalCode else {
											Alerts.showNoOptionAlert(title: "Error", message: "An unknown error occurred. Please restart the app and try again", sender: self)
											return
										}
                                        let uid = user.uid
										let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
                                        
                                        Helpers.addUserToUserDefaults(firstName: firstName, lastName: lastName, email: email, phoneNumber: phoneNumber, password: cleanPassword, uid: uid)
                                        
                                        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                                        user.link(with: credential) { (authResult, error) in
                                            
                                            if error == nil {
                                                Auth.auth().signIn(with: credential) { (authResult2, error2) in
                                                    
                                                    if error2 == nil {
                                                        
                                                        let db = Firestore.firestore()
                                                        // Add user to "users" collection with document id = uid
                                                        db.collection(K.Firebase.CollectionNames.users).document(uid).setData([
                                                            K.Firebase.UserFieldNames.firstName:firstName,
                                                            K.Firebase.UserFieldNames.lastName:lastName,
                                                            K.Firebase.UserFieldNames.email:email,
                                                            K.Firebase.UserFieldNames.phoneNumber:phoneNumber,
                                                            K.Firebase.UserFieldNames.password:cleanPassword,
															K.Firebase.UserFieldNames.personalCode:personalCode,
                                                            K.Firebase.UserFieldNames.hasBusinessAccount:false,
                                                            K.Firebase.UserFieldNames.businesses:[],
															K.Firebase.UserFieldNames.employmentLocations:[],
															K.Firebase.UserFieldNames.favoritePlaces:[]
                                                        ]) { error in
                                                            
                                                            UserDefaults.standard.set(true, forKey: K.UserDefaultKeys.User.verifiedPhoneNumber)
                                                            self.spinnerView.remove()
                                                            if error != nil {
                                                                Alerts.showNoOptionAlert(title: "Minor error saving data", message: "You have completed the initial account setup, however, some of your information was not saved by our servers. We will try again at a later time. This should not impact user experience. Error description: \(error!.localizedDescription)", sender: self) { (action) in
																	self.askInitialBusinessSetupQuestions()
                                                                }
                                                            } else {
																
                                                                Alerts.showNoOptionAlert(title: "Success", message: "You have completed the inital account setup", sender: self) { (UIAlertAction) in
																	self.askInitialBusinessSetupQuestions()
                                                                }
                                                            }
                                                            
                                                        }
                                                        
                                                    } else {
                                                        self.spinnerView.remove()
                                                        Alerts.showNoOptionAlert(title: "Error creating account", message: "Please check your internet connection and try again. Error description: \(error!.localizedDescription)", sender: self)
                                                    }
                                                }
                                            } else {
                                                self.spinnerView.remove()
                                                Alerts.showNoOptionAlert(title: "Error creating account", message: "Please check your internet connection and try again. Error description: \(error!.localizedDescription)", sender: self)
                                            }
                                        }
                                    } else {
                                        self.spinnerView.remove()
                                        self.continueButton.isUserInteractionEnabled = true
                                        Alerts.showTwoOptionAlert(title: "Incorrect Verification Code", message: "If you believe this is an error, we can resend the verification code to \(self.phoneNumber ?? "(PHONE NUMBER UNAVAILABLE)")", option1: "Try Again", option2: "Resend Code", sender: self, handler1: nil) { (_) in
                                            
                                            self.spinnerView.create(parentVC: self)
                                            self.continueButton.isUserInteractionEnabled = false
                                            
                                            if let phoneNumber = self.phoneNumber?.trimmingCharacters(in: .whitespacesAndNewlines), !phoneNumber.isEmpty {
                                                PhoneAuthProvider.provider().verifyPhoneNumber("+1\(phoneNumber)", uiDelegate: nil) { (verificationID, error) in
                                                    
                                                    self.spinnerView.remove()
                                                    self.continueButton.isUserInteractionEnabled = true
                                                    if error == nil {
                                                        guard let verificationID = verificationID else {
                                                            Alerts.showNoOptionAlert(title: "Error verifying phone number", message: "An error has occurred while retrieving verification code", sender: self)
                                                            return
                                                        }
                                                        
                                                        UserDefaults.standard.set(verificationID, forKey: K.UserDefaultKeys.User.verificationID)
                                                        UserDefaults.standard.set(phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines), forKey: K.UserDefaultKeys.User.phoneNumber)
                                                        UserDefaults.standard.set(true, forKey: K.UserDefaultKeys.User.sentVerificationCode)
														
														Alerts.showNoOptionAlert(title: "Verification Code Sent", message: "Please enter your new verification code", sender: self)
                                                    } else {
                                                        Alerts.showNoOptionAlert(title: "Error sending verification code", message: "Error description: \(error!.localizedDescription)", sender: self)
                                                    }
                                                }
                                            } else {
                                                Alerts.showNoOptionAlert(title: "An error has occurred", message: "Please return to the previous page and re-enter your phone number", sender: self)
                                            }
                                            
                                        }
                                    }
                                }
                            } else {
                                self.otpTextField.text = ""
                                self.otpTextField.changePlaceholderText(to: "Enter verification code", withColor: .systemRed)
                                self.textFieldsHoldAlert[0] = true
                            }
                        } else {
                            self.confirmPasswordTextField.text = ""
                            self.confirmPasswordTextField.changePlaceholderText(to: "Passwords do not match", withColor: .systemRed)
                            self.textFieldsHoldAlert[2] = true
                        }
                    } else {
                        self.passwordTextField.text = ""
                        self.passwordTextField.changePlaceholderText(to: "Password is too weak", withColor: .systemRed)
                        self.textFieldsHoldAlert[1] = true
                    }
                } else {
                    self.confirmPasswordTextField.text = ""
                    self.confirmPasswordTextField.changePlaceholderText(to: "You must confirm your password", withColor: .systemRed)
                    self.textFieldsHoldAlert[2] = true
                }
            } else {
                self.passwordTextField.text = ""
                self.passwordTextField.changePlaceholderText(to: "You must enter a password", withColor: .systemRed)
                self.textFieldsHoldAlert[1] = true
            }
            
            
        }, handler2: nil)
    }
	
	func askInitialBusinessSetupQuestions() {
		if let uid = Auth.auth().currentUser?.uid {
			let userDocRef = Firestore.firestore().collection(K.Firebase.CollectionNames.users).document(uid)
			
			Alerts.showTwoOptionAlert(title: "More Account Details", message: "Are you a business owner or a staff member? If you own a business and plan on working there yourself, please select \"Business Owner\".", option1: "Business Owner", option2: "Staff Member", sender: self) { (_) in
				
				Alerts.showTwoOptionAlert(title: "Would you like to register your business now?", message: "In order to register your business, your staff members must already have a STYLYST For Business account", option1: "Register Now", option2: "Register Later", sender: self) { (_) in
					
					self.spinnerView.create(parentVC: self)
					self.spinnerView.label.text = "Creating business account..."
					userDocRef.updateData([
						K.Firebase.UserFieldNames.hasBusinessAccount:true
					]) { (error) in
						self.spinnerView.remove()
						if let error = error {
							
							Alerts.showNoOptionAlert(title: "An error occurred", message: "Please restart the app and try again. Error description: \(error.localizedDescription)", sender: self) { (_) in
								self.dismiss(animated: true, completion: nil)
							}
							
						} else {
							
							UserDefaults.standard.set(true, forKey: K.UserDefaultKeys.User.setUpBusinessAccount)
							self.performSegue(withIdentifier: K.Segues.continueRegisterToBusinessRegister, sender: self)
							Alerts.showNoOptionAlert(title: "Register your business", message: "Your account is created. Now it is time to register your business with us. You can always add more businesses later on", sender: self)
							
						}
					}
					
				} handler2: { (_) in
					
					self.spinnerView.create(parentVC: self)
					self.spinnerView.label.text = "Creating business account..."
					userDocRef.updateData([
						K.Firebase.UserFieldNames.hasBusinessAccount:true
					]) { (error) in
						self.spinnerView.remove()
						if let error = error {
							
							Alerts.showNoOptionAlert(title: "An error occurred", message: "Please restart the app and try again. Error description: \(error.localizedDescription)", sender: self) { (_) in
								self.dismiss(animated: true, completion: nil)
							}
							
						} else {
							
							Alerts.showNoOptionAlert(title: "Success", message: "Your account was created successfully. When you are ready to add your first business, sign in, tap \"Manage Businesses\", \"+\"", sender: self) { (_) in
								UserDefaults.standard.set(true, forKey: K.UserDefaultKeys.User.setUpBusinessAccount)
								self.dismiss(animated: true, completion: nil)
							}
							
						}
					}
					
				}
				
			} handler2: { (_) in
				
				self.spinnerView.create(parentVC: self)
				self.spinnerView.label.text = "Creating business account..."
				userDocRef.updateData([
					K.Firebase.UserFieldNames.hasBusinessAccount:true
				]) { (error) in
					self.spinnerView.remove()
					if let error = error {
						Alerts.showNoOptionAlert(title: "An error occurred", message: "Please restart the app and try again. Error description: \(error.localizedDescription)", sender: self) { (_) in
							self.dismiss(animated: true, completion: nil)
						}
					} else {
						
						Alerts.showNoOptionAlert(title: "Success", message: "Your account was created successfully. Ask your employer to add you as a staff member using the same email you used to create your account", sender: self) { (_) in
							UserDefaults.standard.set(true, forKey: K.UserDefaultKeys.User.setUpBusinessAccount)
							self.dismiss(animated: true, completion: nil)
						}
						
					}
				}
				
			}
			
			
		} else {
			Alerts.showNoOptionAlert(title: "An unknown error occurred", message: "Please restart the app and try again", sender: self) { (_) in
				self.dismiss(animated: true, completion: nil)
			}
		}
	}
    
    @objc func cancelButtonPressed() {
		Alerts.showTwoOptionAlertDestructive(title: "Are you sure you want to exit?", message: "Your changes will not be saved", sender: self, option1: "Exit", option2: "Stay", is1Destructive: true, is2Destructive: false, handler1: { (_) in
			self.dismiss(animated: true, completion: nil)
		}, handler2: nil)
    }
    
    
    @objc func showHidePassword(_ sender: UIButton) {
        if sender == passwordTextField.rightView {
            passwordTextField.togglePasswordVisibility()
        } else if sender == confirmPasswordTextField.rightView {
            confirmPasswordTextField.togglePasswordVisibility()
        } else {
            passwordTextField.togglePasswordVisibility()
            confirmPasswordTextField.togglePasswordVisibility()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is BusinessRegisterViewController {
			let businessRegisterVC = segue.destination as! BusinessRegisterViewController
			let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: businessRegisterVC, action: #selector(businessRegisterVC.cancelButtonPressed))
			
			businessRegisterVC.navigationItem.hidesBackButton = true
			businessRegisterVC.navigationItem.leftBarButtonItem = cancelButton
		}
		
        if segue.destination is BusinessRegisterViewController {
            let businessRegisterVC = segue.destination as! BusinessRegisterViewController
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: businessRegisterVC, action: #selector(businessRegisterVC.cancelButtonPressed))
            
            businessRegisterVC.navigationItem.hidesBackButton = true
            businessRegisterVC.navigationItem.leftBarButtonItem = cancelButton
        }
    }
    
}



extension ContinueRegistrationViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == passwordTextField {
            textField.changePlaceholderText(to: "Password")
        } else if textField == confirmPasswordTextField {
            textField.changePlaceholderText(to: "Confirm Password")
        } else if textField == otpTextField {
            textField.changePlaceholderText(to: "Verification Code")
        }
    }
    
}
