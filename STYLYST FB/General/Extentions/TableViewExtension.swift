//
//  TableViewExtension.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2021-06-01.
//  Copyright © 2021 Michael Mityushkin. All rights reserved.
//

import UIKit


extension UITableView {
	
	func addNoDataLabel(withText labelText: String) -> UILabel {
		let noDataLabel = Helpers.getNoDataLabel(withText: labelText, width: bounds.size.width, height: bounds.size.height)
		noDataLabel.isHidden = true
		if backgroundView == nil {
			backgroundView = UIView()
		}
		backgroundView?.addSubview(noDataLabel)
		return noDataLabel
	}
	
	func showHideNoDataLabel(noDataLabel: UILabel, show: Bool) {
		noDataLabel.isHidden = !show
		separatorStyle = show ? .none : .singleLine
	}
	
}
