//
//  TableViewControllerExtension.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2021-06-01.
//  Copyright © 2021 Michael Mityushkin. All rights reserved.
//

import UIKit


extension UITableViewController {
	
	func addNoDataLabel(withText labelText: String) -> UILabel {
		let noDataLabel = Helpers.getNoDataLabel(withText: labelText, width: tableView.bounds.size.width, height: tableView.bounds.size.height)
		noDataLabel.isHidden = true
		if tableView.backgroundView == nil {
			tableView.backgroundView = UIView()
		}
		tableView.backgroundView?.addSubview(noDataLabel)
		return noDataLabel
	}
	
	func showHideNoDataLabel(noDataLabel: UILabel, show: Bool) {
		noDataLabel.isHidden = !show
		tableView.separatorStyle = show ? .none : .singleLine
	}
	
}
