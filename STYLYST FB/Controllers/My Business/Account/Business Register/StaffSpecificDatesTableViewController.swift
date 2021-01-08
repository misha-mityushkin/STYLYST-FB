//
//  StaffSpecificDatesTableViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-09-04.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class StaffSpecificDatesTableViewController: UITableViewController {

	var staffWorkingHoursVC: StaffWorkingHoursViewController?
	
	var staffMember: User?

	var specificDates: [String : [String]]?
	var specificDatesSortedArray: [Dictionary<String, [String]>.Element]?

	var selectedCellIndex: Int?

	var noDataLabel: UILabel?

	override func viewDidLoad() {
		super.viewDidLoad()
		
		staffMember = staffWorkingHoursVC?.addStaffMemberVC?.staffMember

		specificDates = staffWorkingHoursVC?.addStaffMemberVC?.specificHours
		specificDatesSortedArray = specificDates?.sorted(by: { (date1, date2) -> Bool in
			return date1.key < date2.key
		})

		noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
		noDataLabel?.numberOfLines = 0
		noDataLabel!.text = "No specific dates found. Tap the + icon in the top right corner to add one"
		noDataLabel!.textColor = K.Colors.goldenThemeColorDefault
		noDataLabel!.textAlignment = .center
		noDataLabel!.isHidden = true
		tableView.backgroundView = UIImageView(image: UIImage(named: K.ImageNames.backgroundNoLogo))
		tableView.register(UINib(nibName: K.Nibs.specificDateCellNibName, bundle: nil), forCellReuseIdentifier: K.Identifiers.specificDateCellIdentifier)
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
		performSegue(withIdentifier: K.Segues.staffSpecificDatesToAddStaffSpecificDate, sender: self)
	}

	func updateSpecificDates() {
		if let specificDates = specificDates {
			specificDatesSortedArray = specificDates.sorted(by: { (date1, date2) -> Bool in
				return date1.key < date2.key
			})
			staffWorkingHoursVC?.addStaffMemberVC?.specificHours = specificDates
			tableView.reloadData()
		}
	}

	// MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
		if staffWorkingHoursVC?.addStaffMemberVC?.specificHours?.count ?? 0 == 0 {
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
		return staffWorkingHoursVC?.addStaffMemberVC?.specificHours?.count ?? 0
	}


	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.specificDateCellIdentifier, for: indexPath) as! SpecificDateTableViewCell

		if let dateString = specificDatesSortedArray?[indexPath.row].key {
			cell.dateLabel.text = "\(dateString.formattedDate())"
		}
		
		if let timeArray = specificDatesSortedArray?[indexPath.row].value {
			if timeArray == ["closed"] {
				cell.scheduleLabel.text = "Not Working"
			} else {
				var timeString = timeArray[0].formattedStartEndTime()
				if timeArray.count > 1 {
					timeString.append(", ")
					timeString.append(timeArray[1].formattedStartEndTime())
				}
				cell.scheduleLabel.text = timeString
			}
		}

		return cell
	}

	//MARK: - Table view delegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		selectedCellIndex = indexPath.row
		performSegue(withIdentifier: K.Segues.staffSpecificDatesToAddStaffSpecificDate, sender: self)
	}

	// MARK: - Navigation

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is AddStaffSpecificDateViewController {
			let addStaffSpecificDateVC = segue.destination as! AddStaffSpecificDateViewController
			addStaffSpecificDateVC.staffSpecificDatesVC = self
			if let selectedCellIndex = selectedCellIndex {
				addStaffSpecificDateVC.isEditSpecificDate = true
				addStaffSpecificDateVC.selectedIndex = selectedCellIndex
			}
		}
	}
}
