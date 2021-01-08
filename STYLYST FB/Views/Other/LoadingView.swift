//
//  LoadingView.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-06-11.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class LoadingView: UIViewController {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var label: UILabel!
    	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    func create(parentVC: UIViewController) {
        // add the spinner view controller
        parentVC.addChild(self)
        self.view.frame = parentVC.view.frame
        parentVC.view.addSubview(self.view)
        self.didMove(toParent: parentVC)
        self.spinner.startAnimating()
		self.label.isHidden = false
    }
    
    func remove() {
        self.spinner.stopAnimating()
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
		self.label.text = ""
		self.label.isHidden = true
    }
}
