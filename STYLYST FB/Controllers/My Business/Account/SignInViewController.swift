//
//  SignInViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-06-20.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: PasswordTextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    var textFields: [UITextField] = []
    var textFieldsHoldAlert = [false, false]
    
    let destinationRegister = "register"
    let destinationContinueRegister = "continueRegister"
    let destinationBusinessRegister = "businessRegister"
    var destination: String? //possible values: register, continueRegister, businessRegister
    
    var spinnerView = LoadingView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        textFields = [emailTextField, passwordTextField]
        for textField in textFields {
            textField.delegate = self
        }
        UITextField.format(textFields: textFields, height: 40, padding: 10)
        let passwordIcon: UIImage
        if #available(iOS 13.0, *) {
			passwordIcon = UIImage(systemName: K.ImageNames.eyeSlash)!
        } else {
            passwordIcon = UIImage(named: K.ImageNames.eyeSlash)!
        }
        passwordTextField.setRightViewButton(icon: passwordIcon, width: passwordTextField.frame.height * 1.05, height: passwordTextField.frame.height * 0.7, parentVC: self, action: #selector(self.showHidePassword(_:)))
        
        hideKeyboardWhenTappedAround()        
        
        
        
		if UserDefaults.standard.bool(forKey: K.UserDefaultKeys.User.sentVerificationCode) && !UserDefaults.standard.bool(forKey: K.UserDefaultKeys.User.verifiedPhoneNumber) && !UserDefaults.standard.bool(forKey: K.UserDefaultKeys.User.setUpBusinessAccount) && !UserDefaults.standard.bool(forKey: K.UserDefaultKeys.User.isSignedIn) { //user has completed initial setup but has yet to verify his phone number
            
            if let verificationID = UserDefaults.standard.string(forKey: K.UserDefaultKeys.User.verificationID), !verificationID.isEmpty { // verificationID is saved

                Alerts.showTwoOptionAlert(title: "You have an ongoing registration process", message: "Tap continue to complete your registration", option1: "Continue", option2: "Cancel", sender: self, handler1: { (action1) in
                    
                    self.destination = self.destinationContinueRegister
                    self.performSegue(withIdentifier: K.Segues.signInToRegister, sender: self)
                    
                }, handler2: nil)
                
            } else { // verificationID is missing
                
                Alerts.showTwoOptionAlert(title: "It appears you have began the registration process", message: "Due to an unknown error we will need to go through the registration process from the beginning", option1: "Continue", option2: "Cancel", sender: self, handler1: { (action1) in
                    
                    self.destination = self.destinationRegister
                    self.performSegue(withIdentifier: K.Segues.signInToRegister, sender: self)
                    
                }, handler2: nil)
                
            }
        }
        
        
        if UserDefaults.standard.bool(forKey: K.UserDefaultKeys.User.sentVerificationCode) && UserDefaults.standard.bool(forKey: K.UserDefaultKeys.User.verifiedPhoneNumber) && !UserDefaults.standard.bool(forKey: K.UserDefaultKeys.User.setUpBusinessAccount) && !UserDefaults.standard.bool(forKey: K.UserDefaultKeys.User.isSignedIn) {
			//user has registered and verified their phone number but has yet to complete the business account set up
            
            if let email = UserDefaults.standard.string(forKey: K.UserDefaultKeys.User.email)?.trimmingCharacters(in: .whitespacesAndNewlines), let password = UserDefaults.standard.string(forKey: K.UserDefaultKeys.User.password)?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty, !password.isEmpty {
                
                spinnerView.create(parentVC: self)
				self.spinnerView.label.text = "Signing in..."
                signInButton.isUserInteractionEnabled = false
                
                Auth.auth().signIn(withEmail: email, password: password) { (_, error) in
                    
                    self.spinnerView.remove()
                    self.signInButton.isUserInteractionEnabled = true
                    
                    if error == nil {
                        
                        Alerts.showTwoOptionAlert(title: "You have an ongoing registration process", message: "Tap continue to complete your registration", option1: "Continue", option2: "Cancel", sender: self, handler1: { (action1) in
                            
							self.performSegue(withIdentifier: K.Segues.signInToPersonalCode, sender: self)
                            
                        }, handler2: nil)
                        
                    } else {
                        Alerts.showNoOptionAlert(title: "You have an ongoing registration process", message: "Sign in to complete your registration", sender: self)
                    }
                }
            } else {
                Alerts.showNoOptionAlert(title: "You have an ongoing registration process", message: "Sign in to complete your registration", sender: self)
            }
            
        }
        
        
        if let email = UserDefaults.standard.string(forKey: K.UserDefaultKeys.User.email), !email.isEmpty {
            emailTextField.text = email
        }
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
    
    
    @IBAction func signInPressed(_ sender: UIButton) {
        if let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty {
            if let password = passwordTextField.text, !password.isEmpty {
                
                signInButton.isUserInteractionEnabled = false
                hideKeyboard()
                spinnerView.create(parentVC: self)
				self.spinnerView.label.text = "Signing in..."
                
                Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                    if error == nil {
                        if let user = authResult?.user {
                            let db = Firestore.firestore()
                            let docRef = db.collection(K.Firebase.CollectionNames.users).document(user.uid)
                            docRef.getDocument { (document, error) in
                                
                                if let document = document, document.exists, error == nil {
                                    let firstName = document.get(K.Firebase.UserFieldNames.firstName) as? String
                                    let lastName = document.get(K.Firebase.UserFieldNames.lastName) as? String
                                    let phoneNumber = document.get(K.Firebase.UserFieldNames.phoneNumber) as? String
                                    let uid = user.uid
                                    
                                    Helpers.addUserToUserDefaults(firstName: firstName ?? "", lastName: lastName ?? "", email: email, phoneNumber: phoneNumber ?? "" , password: password, uid: uid )
                                    
                                    let hasBusinessAccount = document.get(K.Firebase.UserFieldNames.hasBusinessAccount) as? Bool
                                    
                                    if hasBusinessAccount ?? false {
                                        UserDefaults.standard.set(true, forKey: K.UserDefaultKeys.User.isSignedIn)
										UserDefaults.standard.set(true, forKey: K.UserDefaultKeys.User.sentVerificationCode)
										UserDefaults.standard.set(true, forKey: K.UserDefaultKeys.User.verifiedPhoneNumber)
										UserDefaults.standard.set(true, forKey: K.UserDefaultKeys.User.setUpBusinessAccount)
										UserDefaults.standard.set(true, forKey: K.UserDefaultKeys.User.isSignedIn)
                                        self.signInButton.isUserInteractionEnabled = true
                                        self.spinnerView.remove()
                                        self.performSegue(withIdentifier: K.Segues.signInToProfile, sender: self)
                                    } else {
										self.signInButton.isUserInteractionEnabled = true
										self.spinnerView.remove()
                                        Alerts.showNoOptionAlert(title: "Business Registration Required", message: "You must complete the registration process for your business account", sender: self) { (_) in
											self.performSegue(withIdentifier: K.Segues.signInToPersonalCode, sender: self)
                                        }
                                    }
                                } else {
                                    self.signInButton.isUserInteractionEnabled = true
                                    self.spinnerView.remove()
                                    self.passwordTextField.text = ""
                                    Alerts.showNoOptionAlert(title: "Error signing in", message: "Restart the app, check your internet connection, and try again. Error description: \(error?.localizedDescription ?? "No description available")", sender: self)
                                }
                            }
                        } else {
                            print("authResult.user")
                            self.signInButton.isUserInteractionEnabled = true
                            self.spinnerView.remove()
                            self.passwordTextField.text = ""
                            Alerts.showNoOptionAlert(title: "Error signing in", message: "Restart the app, check your internet connection, and try again.", sender: self)
                        }
                    } else {
                        self.signInButton.isUserInteractionEnabled = true
                        self.spinnerView.remove()
                        self.passwordTextField.text = ""
                        self.passwordTextField.changePlaceholderText(to: "Incorrect email or password", withColor: .systemRed)
                        self.textFieldsHoldAlert[1] = true
                        //Alerts.showNoOptionAlert(title: "Error", message: error!.localizedDescription, sender: self)
                    }
                }
            } else {
                passwordTextField.text = ""
                passwordTextField.changePlaceholderText(to: "Enter your password", withColor: .systemRed)
                textFieldsHoldAlert[1] = true
            }
        } else {
            emailTextField.text = ""
            emailTextField.changePlaceholderText(to: "Enter your email", withColor: .systemRed)
            textFieldsHoldAlert[0] = true
        }
    }
    
    
    @objc func showHidePassword(_ sender: UIButton) {
        if sender == passwordTextField.rightView {
            passwordTextField.togglePasswordVisibility()
        }
    }
    
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        destination = destinationRegister
        self.performSegue(withIdentifier: K.Segues.signInToRegister, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is RegisterNavController {
            let registerNavContoller = segue.destination as! RegisterNavController
            switch destination {
                case destinationContinueRegister:
                    let continueRegisterVC = storyboard!.instantiateViewController(withIdentifier: K.Storyboard.continueRegisterVC) as! ContinueRegistrationViewController
                    registerNavContoller.viewControllers = [continueRegisterVC]
                    let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: continueRegisterVC, action: #selector(continueRegisterVC.cancelButtonPressed))
                    continueRegisterVC.navigationItem.leftBarButtonItem = cancelButton
                case destinationBusinessRegister:
                    let businessRegisterVC = storyboard!.instantiateViewController(withIdentifier: K.Storyboard.businessRegisterVC) as! BusinessRegisterViewController
                    registerNavContoller.viewControllers = [businessRegisterVC]
                    let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: businessRegisterVC, action: #selector(businessRegisterVC.cancelButtonPressed))
                    businessRegisterVC.navigationItem.leftBarButtonItem = cancelButton
                default:
                    break
            }
		} else if segue.destination is PersonalCodeViewController {
			let personalCodeVC = segue.destination as! PersonalCodeViewController
			personalCodeVC.signInVC = self
		}
    }
    
}



extension SignInViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTextField {
            textField.changePlaceholderText(to: "Email")
        } else if textField == passwordTextField {
            textField.changePlaceholderText(to: "Password")
        }
        
    }
}
