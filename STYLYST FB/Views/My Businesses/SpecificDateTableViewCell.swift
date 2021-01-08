//
//  SpecificDateTableViewCell.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-08-24.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class SpecificDateTableViewCell: UITableViewCell {
	
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var scheduleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
