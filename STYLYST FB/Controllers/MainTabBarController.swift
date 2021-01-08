//
//  TabBarController.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-06-01.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import Firebase
import Geofirestore

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let email = UserDefaults.standard.string(forKey: K.UserDefaultKeys.User.email), let password = UserDefaults.standard.string(forKey: K.UserDefaultKeys.User.password), !email.isEmpty, !password.isEmpty {
			print("email: \(email), pass: \(password)")
            
            if UserDefaults.standard.bool(forKey: K.UserDefaultKeys.User.sentVerificationCode) && UserDefaults.standard.bool(forKey: K.UserDefaultKeys.User.verifiedPhoneNumber) && UserDefaults.standard.bool(forKey: K.UserDefaultKeys.User.isSignedIn) {
                
				if let profileNavVC = self.viewControllers?.last as? UINavigationController {
					(profileNavVC.viewControllers[0] as? SignInViewController)?.spinnerView.create(parentVC: profileNavVC.viewControllers[0] as? SignInViewController ?? self)
				}
				
                Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                    
                    if error == nil {
                        
                        if let docID = UserDefaults.standard.string(forKey: K.UserDefaultKeys.Business.docID), !docID.isEmpty {
                            
                            let db = Firestore.firestore()
                            let placesCollectionRef = db.collection(K.Firebase.CollectionNames.places)
                            let geoFirestore = GeoFirestore(collectionRef: placesCollectionRef)
                            
                            if UserDefaults.standard.bool(forKey: K.UserDefaultKeys.Business.pendingLocation) && !UserDefaults.standard.bool(forKey: K.UserDefaultKeys.Business.pendingBusinessDelete) {
                                
                                let lat = UserDefaults.standard.double(forKey: K.UserDefaultKeys.Business.Location.lat)
                                let lon = UserDefaults.standard.double(forKey: K.UserDefaultKeys.Business.Location.lon)
                                
                                geoFirestore.setLocation(geopoint: GeoPoint(latitude: lat, longitude: lon), forDocumentWithID: docID) { (error) in
                                    if error == nil {
                                        UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.Business.Location.lat)
                                        UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.Business.Location.lon)
                                        UserDefaults.standard.set(false, forKey: K.UserDefaultKeys.Business.pendingLocation)
                                        UserDefaults.standard.set(nil, forKey: K.UserDefaultKeys.Business.docID)
                                    }
                                }
                                
                            } else if UserDefaults.standard.bool(forKey: K.UserDefaultKeys.Business.pendingBusinessDelete) && !UserDefaults.standard.bool(forKey: K.UserDefaultKeys.Business.pendingLocation) {
                                
                                placesCollectionRef.document(docID).delete { (error) in
                                    if error == nil {
                                        UserDefaults.standard.setValue(false, forKey: K.UserDefaultKeys.Business.pendingBusinessDelete)
                                        UserDefaults.standard.setValue(nil, forKey: K.UserDefaultKeys.Business.docID)
                                    }
                                }
                                
                            }
                            
                        }
                        
                        if let profileVC = self.storyboard?.instantiateViewController(withIdentifier: K.Storyboard.profileVC) as? ProfileViewController, let profileNavController = self.viewControllers?.last as? UINavigationController {
                            
                            profileNavController.viewControllers[0] = profileVC
                            profileNavController.popToRootViewController(animated: false)
                        }
                        
                    }
                }
            }
        }
    }
}
