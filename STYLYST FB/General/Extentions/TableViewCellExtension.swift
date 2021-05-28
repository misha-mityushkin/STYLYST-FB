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
		let disclosureIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
		if #available(iOS 13.0, *) {
			disclosureIcon.image = UIImage(systemName: K.ImageNames.chevronRight)
		} else {
			disclosureIcon.image = UIImage(named: K.ImageNames.chevronRight)
		}
		disclosureIcon.contentMode = .scaleAspectFit
		disclosureIcon.tintColor = .gray
		self.accessoryView = disclosureIcon
	}
}
