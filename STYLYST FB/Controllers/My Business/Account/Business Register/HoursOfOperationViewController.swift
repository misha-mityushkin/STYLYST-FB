//
//  HoursOfOperationViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-08-22.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class HoursOfOperationViewController: UIViewController {
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var tableView: UITableView!
	
	var businessRegisterVC: BusinessRegisterViewController?
	
	var selectedDayIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.tintColor = K.Colors.goldenThemeColorInverse
		UIView.animate(withDuration: 0.5) {
			self.navigationItem.leftBarButtonItem?.tintColor = K.Colors.goldenThemeColorLight?.withAlphaComponent(1)
			self.navigationController?.makeTransparent()
			let textAttributes = [NSAttributedString.Key.foregroundColor:K.Colors.goldenThemeColorDefault!]
			self.navigationController?.navigationBar.titleTextAttributes = textAttributes
			self.navigationController?.navigationBar.layoutIfNeeded()
		}
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		navigationController?.navigationBar.tintColor = K.Colors.goldenThemeColorInverse
		navigationController?.makeTransparent()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.destination is WeekdayScheduleViewController {
			let weekdayScheduleVC = segue.destination as! WeekdayScheduleViewController
			weekdayScheduleVC.hoursOfOperationVC = self
		} else if segue.destination is SpecificDatesTableViewController {
			let specificDatesVC = segue.destination as! SpecificDatesTableViewController
			specificDatesVC.hoursOfOperationVC = self
		}
	}
	
	@IBAction func scheduleInfoPressed(_ sender: UIButton) {
		Alerts.showNoOptionAlert(title: "Hours of Operation Info", message: "Hours specified here do not impact staff members' schedules or appointment booking. They are only used to display on your front page", sender: self)
	}
	
	@IBAction func setSpecificDatesPressed(_ sender: UIButton) {
		performSegue(withIdentifier: K.Segues.hoursOfOperationToSpecificDates, sender: self)
	}
	

}


extension HoursOfOperationViewController: UITableViewDataSource, UITableViewDelegate {
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
		performSegue(withIdentifier: K.Segues.hoursOfOperationToWeekdaySchedule, sender: self)
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	
}


extension HoursOfOperationViewController: UIScrollViewDelegate {
	
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
