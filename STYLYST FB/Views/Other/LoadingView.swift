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
	
	var isActive = false
    	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
	func create(parentVC: UIViewController) {
		isActive = true
		// add the spinner view controller
		parentVC.addChild(self)
		print("parentVC.view w: \(parentVC.view.frame.width), h: \(parentVC.view.frame.height)")
		self.view.frame = parentVC.view.frame
		parentVC.view.addSubview(self.view)
		self.didMove(toParent: parentVC)
		self.spinner.startAnimating()
	}
	
	func remove() {
		isActive = false
		self.spinner.stopAnimating()
		self.willMove(toParent: nil)
		self.view.removeFromSuperview()
		self.removeFromParent()
	}
	
	func create(parentView: UIView) {
		isActive = true
		self.view.frame = parentView.frame
		parentView.addSubview(self.view)
		self.spinner.startAnimating()
	}
}
