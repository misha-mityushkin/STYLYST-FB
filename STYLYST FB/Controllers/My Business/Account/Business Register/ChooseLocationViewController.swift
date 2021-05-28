//
//  ChooseLocationViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-06-20.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ChooseLocationViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var doneButton: UIButton!
	
    var resultSearchController: UISearchController?
    
    var businessRegisterVC: BusinessRegisterViewController?
	
	var selectedLocation: MKMapItem?
	var selectedLocationPin = MKPointAnnotation()
	    
    let regionMeters = 10000.0
        
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if let location = selectedLocation {
			setLocation(location: location)
		}
        
		doneButton.isHidden = true
            
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: K.Storyboard.locationSearchTable) as! LocationSearchTable
        locationSearchTable.tableView.backgroundView = UIImageView(image: K.Images.backgroundNoLogo)
        locationSearchTable.mapView = mapView
        locationSearchTable.chooseLocationVC = self
        
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavBar()
        UIView.animate(withDuration: 0.5) {
            self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black.withAlphaComponent(0)
            self.navigationController?.returnToOriginalState()
            self.navigationController?.navigationBar.layoutIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
            
        if #available(iOS 13.0, *) {
           self.resultSearchController!.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search for address", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: K.ColorNames.placeholderTextColor) ?? UIColor.gray])
        }
    }
    
        
    func setUpNavBar() {
        let searchBar = resultSearchController!.searchBar
        searchBar.placeholder = "Search for address"
        searchBar.searchBarStyle = .minimal
            
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = .black
        navigationController?.navigationBar.tintColor = .black
        navigationItem.titleView = resultSearchController!.searchBar
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
//        if #available(iOS 13.0, *) {
//            resultSearchController!.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: K.Colors.placeholderTextColor) ?? UIColor.gray])
//        }
    }
    

	
	
	func setLocation(location: MKMapItem) {
		selectedLocation = location
		selectedLocationPin.coordinate = location.placemark.coordinate
//		if (businessRegisterVC?.isEditBusiness ?? false) && !(businessRegisterVC?.isNewLocation ?? false) && false {
//			selectedLocationPin.title = businessRegisterVC?.businessLocation?.addressFormatted
//		} else {
//			selectedLocationPin.title = Helpers.parseAddress(for: location.placemark)
//		}
		selectedLocationPin.title = Helpers.parseAddress(for: location.placemark)
		mapView.addAnnotation(selectedLocationPin)
		mapView.setRegion(MKCoordinateRegion(center: location.placemark.coordinate, latitudinalMeters: regionMeters / 10, longitudinalMeters: regionMeters / 10), animated: true)
	}

	
	@IBAction func donePressed(_ sender: UIButton) {
		if let location = selectedLocation {
			print("setting business register location")
			businessRegisterVC?.setLocation(location: location)
			businessRegisterVC?.isNewLocation = true
			navigationController?.popViewController(animated: true)
		} else {
			Alerts.showNoOptionAlert(title: "An error occurred", message: "We were unable to load this location. Please restart the app and try again.", sender: self)
			doneButton.isHidden = true
		}
	}
	
	
}
