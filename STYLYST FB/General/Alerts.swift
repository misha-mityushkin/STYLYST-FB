//
//  Alerts.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-05-15.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import Foundation
import UIKit

struct Alerts {
    
    static func showNoOptionAlert(title: String, message: String, sender: UIViewController, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
        sender.present(alert, animated: true)
    }
    
    
    static func showTwoOptionAlert(title: String, message: String, option1: String, option2: String, sender: UIViewController, handler1: ((UIAlertAction) -> Void)? = nil, handler2: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: option1, style: .default, handler: handler1))
        alert.addAction(UIAlertAction(title: option2, style: .default, handler: handler2))
        sender.present(alert, animated: true)
    }
    static func showTwoOptionAlertDestructive(title: String, message: String, sender: UIViewController, option1: String, option2: String, is1Destructive: Bool, is2Destructive: Bool, handler1: ((UIAlertAction) -> Void)? = nil, handler2: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var style1 = UIAlertAction.Style.default
        if is1Destructive {
            style1 = UIAlertAction.Style.destructive
        }
        var style2 = UIAlertAction.Style.default
        if is2Destructive {
            style2 = UIAlertAction.Style.destructive
        }
        alert.addAction(UIAlertAction(title: option1, style: style1, handler: handler1))
        alert.addAction(UIAlertAction(title: option2, style: style2, handler: handler2))
        sender.present(alert, animated: true)
    }
    
    static func showThreeOptionAlert(title: String, message: String, sender: UIViewController, option1: String, option2: String, option3: String, is1Destructive: Bool, is2Destructive: Bool, is3Destructive: Bool, handler1: ((UIAlertAction) -> Void)? = nil, handler2: ((UIAlertAction) -> Void)? = nil, handler3: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var style1 = UIAlertAction.Style.default
        if is1Destructive {
            style1 = UIAlertAction.Style.destructive
        }
        var style2 = UIAlertAction.Style.default
        if is2Destructive {
            style2 = UIAlertAction.Style.destructive
        }
        var style3 = UIAlertAction.Style.default
        if is3Destructive {
            style3 = UIAlertAction.Style.destructive
        }
        alert.addAction(UIAlertAction(title: option1, style: style1, handler: handler1))
        alert.addAction(UIAlertAction(title: option2, style: style2, handler: handler2))
        alert.addAction(UIAlertAction(title: option3, style: style3, handler: handler3))
        sender.present(alert, animated: true)
    }
	static func showNoOptionAlertTextField(title: String, message: String, actionText: String, placeholder: String, sender: UIViewController, handler: ((UIAlertAction) -> Void)? = nil) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addTextField { (textField) in
			textField.placeholder = placeholder
		}
		alert.addAction(UIAlertAction(title: actionText, style: .default, handler: handler))
		sender.present(alert, animated: true)
	}
	
    

    //Make sure to add completion handlers properly
    static func showMultiOptionAlert(title: String, message: String, options: [String], sender: UIViewController, handlers: [((UIAlertAction) -> Void)?]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for option in options {
            alert.addAction(UIAlertAction(title: option, style: .default, handler: nil))
        }

        sender.present(alert, animated: true)
    }
    
}

