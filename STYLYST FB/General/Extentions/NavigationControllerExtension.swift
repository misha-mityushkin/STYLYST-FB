//
//  NavigationControllerExtension.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-05-28.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    func makeTransparent() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
    }
    
    func returnToOriginalState() {
        navigationBar.setBackgroundImage(nil, for: .default)
        navigationBar.shadowImage = nil
    }
	
}
