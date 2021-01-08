//
//  NavigationBarExtention.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-07-25.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

extension UINavigationBar {
	
	func makeTransparent() {
		setBackgroundImage(UIImage(), for: .default)
		shadowImage = UIImage()
		isTranslucent = true
	}
	
	func returnToOriginalState() {
		setBackgroundImage(nil, for: .default)
		shadowImage = nil
	}
	
}
