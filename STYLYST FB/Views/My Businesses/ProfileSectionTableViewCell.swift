//
//  ProfileSectionTableViewCell.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-05-30.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class ProfileSectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var sectionIcon: UIImageView!
    @IBOutlet weak var sectionName: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
