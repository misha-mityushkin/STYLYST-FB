//
//  TableViewCellExtension.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-08-22.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

extension UITableViewCell {
	func addDisclosureIndicator() {
		let button = UIButton(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
		if #available(iOS 13.0, *) {
			button.setImage(UIImage(systemName: K.ImageNames.chevronRight), for: .normal)
		} else {
			button.setImage(UIImage(named: K.ImageNames.chevronRight), for: .normal)
		}
		button.tintColor = .gray
		self.accessoryView = button
	}
}
