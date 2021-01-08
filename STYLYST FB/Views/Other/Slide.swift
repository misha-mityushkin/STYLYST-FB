//
//  Slide.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-05-15.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class Slide: UIView {

    @IBOutlet weak var slideImage: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var firstLaunchVC: FirstLaunchSlideViewController?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        //exploreVC?.finishedFirstLaunchSlides = true
        if button.titleLabel?.text == "Enable" {
            
        } else if button.titleLabel?.text == "Get Started" {
            firstLaunchVC?.dismiss(animated: true, completion: nil)
        } else {
            print("wtf is going on")
        }
    }
    
}
