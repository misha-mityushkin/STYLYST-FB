//
//  StaffWorkingHoursViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-09-04.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class StaffWorkingHoursViewController: UIViewController {
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var specificDatesInstructionLabel: UILabel!
	
	var addStaffMemberVC: AddStaffMemberViewController?
	
	var selectedDayIndex = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.dataSource = self
		tableView.delegate = self
		titleLabel.text = "\(addStaffMemberVC?.staffMember?.firstName ?? "Staff Member")'s Working Hours"
		specificDatesInstructionLabel.text = "Specify dates when \(addStaffMemberVC?.staffMember?.firstName ?? "this staff memeber") works on an altered schedule"
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.tintColor = K.Colors.goldenThemeColorLight
		UIView.animate(withDuration: 0.5) {
			self.navigationItem.leftBarButtonItem?.tintColor = K.Colors.goldenThemeColorLight?.withAlphaComponent(1)
			self.navigationController?.makeTransparent()
			self.navigationController?.navigationBar.layoutIfNeeded()
		}
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		navigationController?.navigationBar.tintColor = K.Colors.goldenThemeColorInverse
		navigationController?.makeTransparent()
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is StaffWeekdayScheduleViewController {
			let staffWeekdayScheduleVC = segue.destination as! StaffWeekdayScheduleViewController
			staffWeekdayScheduleVC.staffWorkingHoursVC = self
		} else if segue.destination is StaffSpecificDatesTableViewController {
			let staffSpecificDatesVC = segue.destination as! StaffSpecificDatesTableViewController
			staffSpecificDatesVC.staffWorkingHoursVC = self
		}
	}
	
	@IBAction func closePressed(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}
	
	
	@IBAction func setSpecificDatesPressed(_ sender: UIButton) {
		performSegue(withIdentifier: K.Segues.staffWorkingHoursToStaffSpecificDates, sender: self)
	}
	
}


extension StaffWorkingHoursViewController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 7
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifiers.dayOfTheWeekCellIdentifier)!
		cell.textLabel?.text = K.Collections.daysOfTheWeek[indexPath.row]
		cell.textLabel?.textColor = .black
		//cell.textLabel?.font = .systemFont(ofSize: 20)
		cell.addDisclosureIndicator()
		return cell
	}
		
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedDayIndex = indexPath.row
		performSegue(withIdentifier: K.Segues.staffWorkingHoursToStaffWeekdaySchedule, sender: self)
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	
}



extension StaffWorkingHoursViewController: UIScrollViewDelegate {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		if scrollView.contentOffset.y >= titleLabel.frame.maxY {
			if navigationItem.title != titleLabel.text {
				navigationItem.title = titleLabel.text
			}
		} else {
			if navigationItem.title == titleLabel.text {
				navigationItem.title = nil
			}
		}
		
	}
	
}
