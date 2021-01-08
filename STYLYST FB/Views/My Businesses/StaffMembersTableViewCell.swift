//
//  StaffMembersTableViewCell.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-08-03.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class StaffMembersTableViewCell: UITableViewCell {
	
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var emailLabel: UILabel!
	@IBOutlet weak var phoneNumber: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
