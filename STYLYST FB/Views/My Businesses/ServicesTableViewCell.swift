//
//  ServicesTableViewCell.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-07-22.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class ServicesTableViewCell: UITableViewCell {
	
	@IBOutlet weak var serviceNameLabel: UILabel!
	@IBOutlet weak var enabledIndicator: UIImageView!
	@IBOutlet weak var servicePriceLabel: UILabel!
	@IBOutlet weak var serviceTimeLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
