//
//  AddServicesTableViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-07-22.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class ServicesTableViewController: UITableViewController {
	
	var businessRegisterVC: BusinessRegisterViewController?
	
	var services: [[String : Any]]?
	
	var selectedCellIndex: Int?
	
	var noDataLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
		noDataLabel?.numberOfLines = 0
		noDataLabel!.text = "No services found. Tap the + icon in the top right corner to add a service"
		noDataLabel!.textColor = K.Colors.goldenThemeColorDefault
		noDataLabel!.textAlignment = .center
		noDataLabel!.isHidden = true
		tableView.backgroundView = UIImageView(image: UIImage(named: K.ImageNames.backgroundNoLogo))
		tableView.register(UINib(nibName: K.Nibs.servicesCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.servicesCellIdentifier)
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.tintColor = .black
		UIView.animate(withDuration: 0.5) {
			self.navigationItem.leftBarButtonItem?.tintColor = .black
			self.navigationItem.rightBarButtonItem?.tintColor = .black
			self.navigationController?.returnToOriginalState()
			let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
			self.navigationController?.navigationBar.titleTextAttributes = textAttributes
			self.navigationController?.navigationBar.layoutIfNeeded()
		}
	}
	
	
	@IBAction func addServiceButtonPressed(_ sender: UIBarButtonItem) {
		selectedCellIndex = nil
		performSegue(withIdentifier: K.Segues.servicesToAddService, sender: self)
	}
	
	
	func updateServices() {
		print("update services, businessRegVC is nil: \(businessRegisterVC == nil)")
		if let services = services {
			businessRegisterVC?.services = services
			tableView.reloadData()
		}
	}
	

    // MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
		
		if services?.count == 0 {
			if let noDataLabel = noDataLabel {
				noDataLabel.isHidden = false
				tableView.backgroundView?.addSubview(noDataLabel)
			}
			tableView.separatorStyle = .none
		} else {
			tableView.separatorStyle = .singleLine
			tableView.backgroundView = UIImageView(image: UIImage(named: K.ImageNames.backgroundNoLogo))
		}
		
		return 1
	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return services?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.servicesCellIdentifier, for: indexPath) as! ServicesTableViewCell
		print("cell for row at")
		if let service = services?[indexPath.row] {
			print("service exists")
			if let name = service[K.Firebase.PlacesFieldNames.Services.name] as? String, let price = service[K.Firebase.PlacesFieldNames.Services.defaultPrice] as? Double, let time = service[K.Firebase.PlacesFieldNames.Services.defaultTime] as? String {
				print("name etc exists")
				cell.serviceNameLabel.text = name
				if service[K.Firebase.PlacesFieldNames.Services.enabled] as? Bool ?? true {
					cell.enabledIndicator.tintColor = .systemGreen
				} else {
					cell.enabledIndicator.tintColor = .systemRed
				}
				cell.servicePriceLabel.text = String(format: "$%.02f", price)
				cell.serviceTimeLabel.text = time
			} else {
				print("name etc does not exist")
				cell.serviceNameLabel.text = "Error loading service"
				cell.enabledIndicator.tintColor = .clear
				cell.servicePriceLabel.text = ""
				cell.serviceTimeLabel.text = ""
			}
		} else {
			print("service does not exist")
			cell.serviceNameLabel.text = "Error loading service"
			cell.enabledIndicator.tintColor = .clear
			cell.servicePriceLabel.text = ""
			cell.serviceTimeLabel.text = ""
		}
		
        return cell
    }
	
	//MARK: - Table view delegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		selectedCellIndex = indexPath.row
		performSegue(withIdentifier: K.Segues.servicesToAddService, sender: self)
	}

    // MARK: - Navigation
	
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is AddServiceViewController {
			let addServiceVC = segue.destination as! AddServiceViewController
			addServiceVC.servicesVC = self
			if let selectedCellIndex = selectedCellIndex {
				addServiceVC.isEditService = true
				addServiceVC.selectedIndex = selectedCellIndex
			}
		}
    }

	
}
