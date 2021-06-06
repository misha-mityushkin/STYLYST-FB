//
//  SpecificDatesTableViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-08-24.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class SpecificDatesTableViewController: UITableViewController {
	
	var hoursOfOperationVC: HoursOfOperationViewController?
	
	var specificDates: [String : String]?
	var specificDatesSortedArray: [Dictionary<String, String>.Element]?
		
	var selectedCellIndex: Int?
	
	var noDataLabel: UILabel?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.backgroundView = UIImageView(image: K.Images.backgroundNoLogo)
		noDataLabel = addNoDataLabel(withText: "No specific dates added yet. Tap the + icon in the top right corner to add one")
		tableView.register(UINib(nibName: K.Nibs.specificDateCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.specificDateCellIdentifier)
		tableView.tableFooterView = UIView()
		
		specificDates = hoursOfOperationVC?.businessRegisterVC?.specificHours
		updateSpecificDates()
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
	
	@IBAction func addSpecificDateButtonPressed(_ sender: UIBarButtonItem) {
		selectedCellIndex = nil
		performSegue(withIdentifier: K.Segues.specificDatesToAddSpecificDate, sender: self)
	}
	
	func updateSpecificDates() {
		if let specificDates = specificDates {
			specificDatesSortedArray = specificDates.sorted(by: <)
			hoursOfOperationVC?.businessRegisterVC?.specificHours = specificDates
			tableView.reloadData()
		}
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		showHideNoDataLabel(noDataLabel: noDataLabel!, show: hoursOfOperationVC?.businessRegisterVC?.specificHours?.count ?? 0 == 0)
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return hoursOfOperationVC?.businessRegisterVC?.specificHours?.count ?? 0
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.specificDateCellIdentifier, for: indexPath) as! SpecificDateTableViewCell
		
		if let dateString = specificDatesSortedArray?[indexPath.row].key {
			cell.dateLabel.text = "\(dateString.formattedDate())"
		} else { //wat fek is dis
			cell.dateLabel.text = specificDatesSortedArray?[indexPath.row].key
		}
		
		if let timeString = specificDatesSortedArray?[indexPath.row].value {
			if timeString == "closed" {
				cell.scheduleLabel.text = "Closed"
			} else {
				cell.scheduleLabel.text = "\(timeString.formattedStartEndTime())"
			}
		} else {
			cell.scheduleLabel.text = specificDatesSortedArray?[indexPath.row].value
		}
		
		return cell
	}
	
	//MARK: - Table view delegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		selectedCellIndex = indexPath.row
		performSegue(withIdentifier: K.Segues.specificDatesToAddSpecificDate, sender: self)
	}
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is AddSpecificDateViewController {
			let addSpecificDateVC = segue.destination as! AddSpecificDateViewController
			addSpecificDateVC.specificDatesVC = self
			if let selectedCellIndex = selectedCellIndex {
				addSpecificDateVC.isEditSpecificDate = true
				addSpecificDateVC.selectedIndex = selectedCellIndex
			}
		}
	}

}
