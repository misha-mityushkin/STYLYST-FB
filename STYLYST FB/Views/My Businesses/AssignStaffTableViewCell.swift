//
//  AssignStaffTableViewCell.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-08-03.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class AssignStaffTableViewCell: UITableViewCell {
	
	@IBOutlet weak var staffMemberNameLabel: UILabel!
	@IBOutlet weak var tapToEnableLabel: UILabel!
	@IBOutlet weak var checkmark: UIImageView!
	@IBOutlet weak var moreDetailsButton: UIButton!
	
	var assignStaffVC: AssignStaffMembersViewController?
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
		assignStaffVC?.selectedIndex = cellIndex
		assignStaffVC?.performSegue(withIdentifier: K.Segues.assignStaffToSpecificDetails, sender: assignStaffVC)
	}
	
}
