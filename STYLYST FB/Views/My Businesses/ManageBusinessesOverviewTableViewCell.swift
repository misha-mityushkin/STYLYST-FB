//
//  ManageBusinessesOverviewTableViewCell.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-06-23.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class ManageBusinessesOverviewTableViewCell: UITableViewCell {
    
    @IBOutlet weak var businessNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
	@IBOutlet weak var businessTypeLabel: UILabel!
    
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img4: UIImageView!
    @IBOutlet weak var img5: UIImageView!
    
	@IBOutlet weak var bottomLine: UIView!
	
	var imageViews: [UIImageView] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        
        imageViews = [img1, img2, img3, img4, img5]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
