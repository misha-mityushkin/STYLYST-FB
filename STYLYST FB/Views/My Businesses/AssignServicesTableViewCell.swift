//
//  AssignServicesTableViewCell.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-08-03.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class AssignServicesTableViewCell: UITableViewCell {
	
	@IBOutlet weak var serviceNameLabel: UILabel!
	@IBOutlet weak var tapToEnableLabel: UILabel!
	@IBOutlet weak var checkmark: UIImageView!
	@IBOutlet weak var moreDetailsButton: UIButton!
	
	var assignServicesVC: AssignServicesViewController?
	var cellIndex = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	@IBAction func specificDetailsPressed(_ sender: UIButton) {
		assignServicesVC?.selectedIndex = cellIndex
		assignServicesVC?.performSegue(withIdentifier: K.Segues.assignServicesToSpecificDetails, sender: assignServicesVC)
	}
    
}
