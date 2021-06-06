//
//  AddServicesTableViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-07-22.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class ServicesTableViewController: UITableViewController {
	
	@IBOutlet weak var addButton: UIBarButtonItem!
	
	var businessRegisterVC: BusinessRegisterViewController?
	
	var categories: [String] = []
	var services: [Service] = []
	var categorizedServices: [String : [Service]] = [:]
	
	var selectedCellIndex: Int?
	
	var noDataLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.backgroundView = UIImageView(image: K.Images.backgroundNoLogo)
		noDataLabel = addNoDataLabel(withText: "No services added yet. Tap the + icon in the top right corner to add a service")
		tableView.register(UINib(nibName: K.Nibs.servicesCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.servicesCellIdentifier)
		tableView.tableFooterView = UIView()
		
		if #available(iOS 14.0, *) {
			let children: [UIMenuElement] = [
				UIAction(title: "Add Category", image: UIImage(systemName: "tray.full"), identifier: nil, handler: { _ in
					self.addCategory()
				}),
				UIAction(title: "Add Service", image: UIImage(systemName: "doc.badge.plus"), identifier: nil, handler: { _ in
					self.addService()
				})
			]
			addButton.primaryAction = nil
			addButton.menu = UIMenu(title: "", children: children)
		} else {
			addButton.target = self
			addButton.action = #selector(displayOldContextMenu)
		}
		
		updateServices()
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
	
	@objc func displayOldContextMenu() {
		Alerts.showTwoOptionAlert(title: "What would you like to add?", message: "You can add a service or service category", option1: "Add Category", option2: "Add Service", sender: self) { _ in
			self.addCategory()
		} handler2: { _ in
			self.addService()
		}
	}
	
	@objc func deleteCategory(_ sender: UIButton) {
		let index = sender.tag
		let categoryName = categories[index]
		
		Alerts.showTwoOptionAlertDestructive(title: "Delete Service Category?", message: "This will delete all services in \(categoryName)", sender: self, option1: "Delete", option2: "Cancel", is1Destructive: true, is2Destructive: false, handler1: { _ in
			self.services.removeAll { service in
				return service.category == categoryName
			}
			self.categories.remove(at: index)
			self.updateServices()
		}, handler2: nil)
	}
	
	@objc func renameCategory(_ sender: UIButton) {
		let index = sender.tag
		let oldCategoryName = categories[index]
		
		let alert = UIAlertController(title: "Rename Service Category", message: "Enter the new category name", preferredStyle: .alert)
		alert.addTextField { (textField) in
			textField.placeholder = "Eg: Men's Hair"
			textField.text = oldCategoryName
		}
		// Style is .cancel cuz it makes it bold and on the left side
		alert.addAction(UIAlertAction(title: "Rename", style: .cancel, handler: { [weak alert] (_) in
			if let newCategoryName = alert?.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines), !newCategoryName.isEmpty {
				if self.categories.contains(newCategoryName) && newCategoryName != oldCategoryName {
					Alerts.showNoOptionAlert(title: "Duplicate Category Name", message: "You already have a category named \(newCategoryName)", sender: self) { _ in
						self.renameCategory(sender)
					}
				} else if newCategoryName == Service.NO_CATEGORY {
					Alerts.showNoOptionAlert(title: "Category Name Not Allowed", message: "You cannot name your service category \(Service.NO_CATEGORY). This is a system reserved name", sender: self) { _ in
						self.renameCategory(sender)
					}
				} else {
					self.categories[index] = newCategoryName
					for i in 0..<self.services.count {
						if self.services[i].category == oldCategoryName {
							self.services[i].category = newCategoryName
						}
					}
					self.updateServices()
					Alerts.showNoOptionAlert(title: "Service Category Renamed", message: "\(oldCategoryName) has been renamed to \(newCategoryName)", sender: self)
				}
			} else {
				Alerts.showNoOptionAlert(title: "Missing Category Name", message: "You must enter a category name", sender: self) { _ in
					self.renameCategory(sender)
				}
			}
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
	
	func addCategory() {
		selectedCellIndex = nil
		let alert = UIAlertController(title: "Add Service Category", message: "Enter the category name", preferredStyle: .alert)
		alert.addTextField { (textField) in
			textField.placeholder = "Eg: Men's Hair"
		}
		// Style is .cancel cuz it makes it bold and on the left side
		alert.addAction(UIAlertAction(title: "Add", style: .cancel, handler: { [weak alert] (_) in
			if let categoryName = alert?.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines), !categoryName.isEmpty {
				if self.categories.contains(categoryName) {
					Alerts.showNoOptionAlert(title: "Duplicate Category Name", message: "You already have a category named \(categoryName)", sender: self) { _ in
						self.addCategory()
					}
				} else if categoryName == Service.NO_CATEGORY {
					Alerts.showNoOptionAlert(title: "Category Name Not Allowed", message: "You cannot name your service category \(Service.NO_CATEGORY). This is a system reserved name", sender: self) { _ in
						self.addCategory()
					}
				} else {
					self.categories.append(categoryName)
					self.updateServices()
					Alerts.showNoOptionAlert(title: "Service Category Added", message: "\(categoryName) has been added", sender: self)
				}
			} else {
				Alerts.showNoOptionAlert(title: "Missing Category Name", message: "You must enter a category name", sender: self) { _ in
					self.addCategory()
				}
			}
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
		self.present(alert, animated: true, completion: nil)
	}
	
	func addService() {
		selectedCellIndex = nil
		if categories.isEmpty || (categories.count == 1 && categories.first == Service.NO_CATEGORY) {
			Alerts.showNoOptionAlert(title: "Missing Service Categories", message: "You must add at least one category before adding a service", sender: self)
		} else {
			performSegue(withIdentifier: K.Segues.servicesToAddService, sender: self)
		}
	}
	
	func categorizeServices() {
		// Clear all category arrays
		for category in categories {
			categorizedServices[category] = []
		}
		// Repopulate category arrays (ASSUMED THAT SERVICES ARRAY IS SORTED)
		for service in services {
			categorizedServices[service.category]?.append(service)
		}
	}
	
	func updateServices() {
		print("update services, businessRegVC is nil: \(businessRegisterVC == nil)")
		categories.sort { category1, category2 in
			return category1.lowercased() < category2.lowercased()
		}
		services.sort()
		categorizeServices()
		businessRegisterVC?.serviceCategories = categories
		businessRegisterVC?.services = services
		tableView.reloadData()
	}
	
}




// TableView Delegate & DataSource
extension ServicesTableViewController {

	override func numberOfSections(in tableView: UITableView) -> Int {
		showHideNoDataLabel(noDataLabel: noDataLabel!, show: categories.count == 0)
		return categories.count
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView(frame: CGRect.zero)
		
		let label = UILabel(frame: CGRect(x: 12, y: 0, width: tableView.frame.width - 90, height: 40))
		label.text = categories[section]
		label.font = UIFont(name: K.FontNames.glacialIndifferenceBold, size: 20)
		label.textColor = K.Colors.goldenThemeColorInverse
		
		let deleteButton = UIButton(frame: CGRect(x: tableView.frame.width - 50, y: 0, width: 40, height: 40))
		deleteButton.tag = section
		deleteButton.tintColor = .systemRed
		if #available(iOS 13.0, *) {
			deleteButton.setImage(UIImage(systemName: K.ImageNames.trash), for: .normal)
		} else {
			deleteButton.setImage(UIImage(named: K.ImageNames.trash), for: .normal)
		}
		deleteButton.addTarget(self, action: #selector(self.deleteCategory(_:)), for: .touchUpInside)
		
		let renameButton = UIButton(frame: CGRect(x: tableView.frame.width - 90, y: 0, width: 40, height: 40))
		renameButton.tag = section
		renameButton.tintColor = K.Colors.goldenThemeColorInverse
		if #available(iOS 13.0, *) {
			renameButton.setImage(UIImage(systemName: K.ImageNames.pencil), for: .normal)
		} else {
			renameButton.setImage(UIImage(named: K.ImageNames.pencil), for: .normal)
		}
		renameButton.addTarget(self, action: #selector(self.renameCategory(_:)), for: .touchUpInside)
		
		view.addSubview(label)
		view.addSubview(deleteButton)
		view.addSubview(renameButton)
		view.backgroundColor = .black.withAlphaComponent(0.5)
		
		return view
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return categories[section]
	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return categorizedServices[categories[section]]?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.servicesCellIdentifier, for: indexPath) as! ServicesTableViewCell
		
		if let service = categorizedServices[categories[indexPath.section]]?[indexPath.row] {
			cell.serviceNameLabel.text = service.name
			if service.enabled {
				cell.enabledIndicator.tintColor = .clear
			} else {
				cell.enabledIndicator.tintColor = .systemRed
			}
			cell.servicePriceLabel.text = String(format: "$%.02f", service.defaultPrice)
			cell.serviceTimeLabel.text = service.defaultTime
		} else {
			cell.serviceNameLabel.text = "Error Loading Service"
			cell.serviceTimeLabel.text = "Please restart the app and try again"
			cell.servicePriceLabel.text = ""
			cell.enabledIndicator.tintColor = .clear
		}
		
        return cell
    }
		
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if let selectedService = categorizedServices[categories[indexPath.section]]?[indexPath.row], let index = services.firstIndex(of: selectedService) {
			selectedCellIndex = index
			performSegue(withIdentifier: K.Segues.servicesToAddService, sender: self)
		} else {
			Alerts.showNoOptionAlert(title: "Error Loading Service", message: "Please restart the app and try again", sender: self)
		}
	}
	
}


