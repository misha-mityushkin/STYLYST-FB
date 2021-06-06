//
//  ManageBusinessesViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-06-23.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//


import UIKit
import Firebase
import Geofirestore

class ManageBusinessesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
	
	let titleStr = "Manage Businesses"
    
    let db = Firestore.firestore()
    var businessLocations: [BusinessLocation] = []
    
    var spinnerView = LoadingView()
    
    var selectedLocation = -1
    
    var destination: String?
    let destinationAdd = "destinationAdd"
    let destinationEdit = "destinationEdit"
    
    var noDataLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
		print("didload")
        
        navigationController?.isNavigationBarHidden = false
        navigationItem.hidesBackButton = false
		
		noDataLabel = tableView.addNoDataLabel(withText: "") // Blank label
		tableView.register(UINib(nibName: K.Nibs.manageBusinessesHeaderCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.manageBusinessesHeaderCellIdentifier)
        tableView.register(UINib(nibName: K.Nibs.manageBusinessesCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.manageBusinessesCellIdentifier)
		tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        navigationController?.makeTransparent()
		noDataLabel?.isHidden = true
        getBusinessIDs()
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		// Have to set noDataLabel here for it to get the proper tableview bounds
		noDataLabel?.removeFromSuperview() // Remove blank label
		noDataLabel = tableView.addNoDataLabel(withText: "No businesses added yet. Tap the + icon in the top right to add a business")
		tableView.reloadData()
	}
    
    func getBusinessIDs() {
        if let user = Auth.auth().currentUser {
            spinnerView.create(parentVC: self)
			spinnerView.label.text = "Loading businesses..."
            businessLocations = []
            
            db.collection(K.Firebase.CollectionNames.users).document(user.uid).getDocument { (userDocument, error) in
                if let userDocument = userDocument, userDocument.exists, error == nil {
                    if let businessIDs = userDocument.get(K.Firebase.UserFieldNames.businesses) as? [String] {
                        if businessIDs.count > 0 {
							self.populateBusinessLocationsArray(businessIDs: businessIDs)
                        } else {
                            self.spinnerView.remove()
							self.tableView.reloadData()
                        }
                    } else {
                        self.spinnerView.remove()
                        Alerts.showNoOptionAlert(title: "Error loading data", message: "Please restart the app, check your internet connection and try again", sender: self)
                    }
                } else {
                    self.spinnerView.remove()
                    Alerts.showNoOptionAlert(title: "Error loading data", message: "Please restart the app, check your internet connection and try again", sender: self)
                }
            }
        } else {
            Alerts.showNoOptionAlert(title: "It appears you are not signed in", message: "Please tap sign out and/or restart the app and try again", sender: self) { (_) in
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    func populateBusinessLocationsArray(businessIDs: [String]) {
        let placesCollectionRef = db.collection(K.Firebase.CollectionNames.places)
        for id in businessIDs {
            placesCollectionRef.document(id).getDocument { (businessDocument, error1) in
				self.spinnerView.label.text = "Fetching business details..."
                if let businessDocument = businessDocument, businessDocument.exists, error1 == nil {
                    let name: String = businessDocument.get(K.Firebase.PlacesFieldNames.name) as? String ?? "Unknown Name"					
					
                    let imagesFolderRef = Storage.storage().reference().child("\(K.Firebase.Storage.placesImagesFolder)/\(id)")
                    imagesFolderRef.listAll { (result, error) in
                        //error image
                        var errorImage: UIImage?
						var placeholderImage: UIImage?
                        if #available(iOS 13.0, *) {
                            errorImage = UIImage(systemName: K.ImageNames.loadingError)
							placeholderImage = UIImage(systemName: K.ImageNames.photoPlaceholder)
                        } else {
                            errorImage = UIImage(named: K.ImageNames.loadingError)
							placeholderImage = UIImage(named: K.ImageNames.photoPlaceholder)
                        }
						var images: [UIImage?] = [placeholderImage, placeholderImage, placeholderImage, placeholderImage, placeholderImage]
                        
                        
                        if let error = error {
							if let errorImage = errorImage {
								images = [errorImage, errorImage, errorImage, errorImage, errorImage]
							}
                            Alerts.showNoOptionAlert(title: "Error loading images", message: "We were unable to load the images associated with \"\(name)\". Please make sure you have a stable internet connection and try again. Error description: \(error.localizedDescription)", sender: self)
							self.businessLocations.append(BusinessLocation(docID: id, data: businessDocument.data(), images: images, placeholderImage: placeholderImage!))
                            if self.businessLocations.count >= businessIDs.count {
                                self.spinnerView.remove()
								self.tableView.reloadData()
                            }
                        } else {
                            for i in 0..<result.items.count {
                                let item = result.items[i]
                                item.getData(maxSize: 5 * 1024 * 1024) { (data, error) in
									self.spinnerView.label.text = "Loading images..."
                                    if let error = error {
                                        
                                        if let errorImage = errorImage {
                                            images[i] = errorImage
                                        }
                                        Alerts.showNoOptionAlert(title: "Error loading an image", message: "We were unable to load an image associated with \"\(name)\". Please make sure you have a stable internet connection and try again. Error description: \(error.localizedDescription)", sender: self)
                                        
                                    } else {
                                        
                                        if let data = data {
                                            images[i] = UIImage(data: data)
                                        } else {
                                            if let errorImage = errorImage {
                                                images[i] = errorImage
                                            }
                                            Alerts.showNoOptionAlert(title: "Error loading an image", message: "We were unable to load an image associated with \"\(name)\". Please make sure you have a stable internet connection and try again.", sender: self)
                                        }
                                        
                                    }
                                    var numImages = 0
                                    for image in images {
                                        if image != placeholderImage {
                                            numImages += 1
                                        }
                                    }
                                    if numImages >= result.items.count {
										self.businessLocations.append(BusinessLocation(docID: id, data: businessDocument.data(), images: images, placeholderImage: placeholderImage!))
										self.tableView.reloadData()
                                    }
                                    if self.businessLocations.count >= businessIDs.count {
                                        self.spinnerView.remove()
										self.tableView.reloadData()
                                    }
                                    
                                }
                                
                            }
                        }
                    }
                } else {
                    self.spinnerView.remove()
                    Alerts.showNoOptionAlert(title: "Error loading a location", message: "Error description: \(error1?.localizedDescription ?? "No description")", sender: self) { (_) in
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
        }
    }
    
    
    
    @IBAction func addBusinessPressed(_ sender: UIBarButtonItem) {
        destination = destinationAdd
        performSegue(withIdentifier: K.Segues.manageBusinessToBusinessRegister, sender: self)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.destination is BusinessRegisterViewController {
//            (segue.destination as! BusinessRegisterViewController).isFirstBusiness = false
//        } else if segue.destination is EditBusinessNavController {
//            let navController = segue.destination as! EditBusinessNavController
//            let editBusinessVC = navController.viewControllers.first as? EditBusinessViewController
//            editBusinessVC?.businessLocation = businessLocations[selectedLocation]
//            editBusinessVC?.manageBusinessesVC = self
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is RegisterNavController {
            let registerNavContoller = segue.destination as! RegisterNavController
            
            let businessRegisterVC = storyboard!.instantiateViewController(withIdentifier: K.Storyboard.businessRegisterVC) as! BusinessRegisterViewController
            registerNavContoller.viewControllers = [businessRegisterVC]
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: businessRegisterVC, action: #selector(businessRegisterVC.cancelButtonPressed))
            businessRegisterVC.navigationItem.leftBarButtonItem = cancelButton
            
            switch destination {
                case destinationAdd:
                    businessRegisterVC.isEditBusiness = false
					businessRegisterVC.manageBusinessesVC = self
                case destinationEdit:
                    businessRegisterVC.isEditBusiness = true
                    businessRegisterVC.businessLocation = businessLocations[selectedLocation]
                    businessRegisterVC.manageBusinessesVC = self
                    
					let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: businessRegisterVC, action: #selector(businessRegisterVC.deletePressed))
//					deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: businessRegisterVC, action: #selector(businessRegisterVC.deletePressed))
					deleteButton.tintColor = .red
                    businessRegisterVC.navigationItem.rightBarButtonItem = deleteButton
                default:
                    break
            }
        }
    }
    

}


extension ManageBusinessesViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
		print("NUMBER OF SECTIONS")
		if !spinnerView.isActive {
			tableView.showHideNoDataLabel(noDataLabel: noDataLabel!, show: businessLocations.count == 0)
		}
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businessLocations.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if indexPath.row == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.manageBusinessesHeaderCellIdentifier, for: indexPath) as! ManageBusinessesHeaderTableViewCell
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.manageBusinessesCellIdentifier, for: indexPath) as! ManageBusinessesOverviewTableViewCell
			
			let location = businessLocations[indexPath.row - 1]
			cell.businessNameLabel.text = location.name
			cell.addressLabel.text = "Address: \(Helpers.formatAddress(streetNumber: location.streetNumber, streetName: location.streetName, city: location.city, province: location.province, postalCode: location.postalCode))"
			
			for i in 0..<K.Collections.businessTypeEnums.count {
				if K.Collections.businessTypeEnums[i] == location.businessType {
					cell.businessTypeLabel.text = "Business Type: \(K.Collections.businessTypes[i + 1])"
				}
			}
			
			for i in 0..<location.images.count {
				if i < location.numActualImages {
					cell.imageViews[i].image = location.images[i]
					cell.imageViews[i].contentMode = .scaleAspectFill
					cell.imageViews[i].layer.cornerRadius = 10
				} else {
					cell.imageViews[i].image = nil
				}
			}
			if indexPath.row < businessLocations.count {
				cell.bottomLine.alpha = 0
			} else {
				cell.bottomLine.alpha = 1
			}
			return cell
		}
        
    }
    
}

extension ManageBusinessesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //spinnerView.create(parentVC: self)
        
        selectedLocation = indexPath.row - 1
        destination = destinationEdit
        
        performSegue(withIdentifier: K.Segues.manageBusinessToBusinessRegister, sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


extension ManageBusinessesViewController: UIScrollViewDelegate {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		if scrollView.contentOffset.y >= 110 {
			if navigationItem.title != titleStr {
				navigationItem.title = titleStr
			}
		} else {
			if navigationItem.title == titleStr {
				navigationItem.title = nil
			}
		}
		
	}
	
}
