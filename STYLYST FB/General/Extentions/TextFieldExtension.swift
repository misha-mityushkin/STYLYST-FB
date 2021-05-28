//
//  TextFieldExtension.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-05-28.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

extension UITextField {
    
    func changeTextFieldColor(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContext(self.frame.size)
        color.setFill()
        UIBezierPath(rect: self.frame).fill()
        let bgImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.background = bgImage
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    
    static func format(textFields: [UITextField], height: CGFloat, padding: CGFloat) {
        for textField in textFields {
            if #available(iOS 13.0, *) {
                textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: K.ColorNames.placeholderTextColor) ?? UIColor.gray])
            }
            textField.changeTextFieldColor(color: UIColor(named: K.ColorNames.goldenThemeColorDefault) ?? .black, size: CGSize(width: textField.frame.size.width, height: height))
            textField.setLeftPaddingPoints(padding)
        }
    }
    static func formatBackground(textFields: [UITextField], height: CGFloat, padding: CGFloat) {
        for textField in textFields {
            textField.changeTextFieldColor(color: UIColor(named: K.ColorNames.goldenThemeColorDefault) ?? .black, size: CGSize(width: textField.frame.size.width, height: height))
            textField.setLeftPaddingPoints(padding)
        }
    }
    static func formatPlaceholder(textFields: [UITextField], height: CGFloat, padding: CGFloat) {
        for textField in textFields {
            textField.changeTextFieldColor(color: UIColor(named: K.ColorNames.goldenThemeColorDefault) ?? .black, size: CGSize(width: textField.frame.size.width, height: height))
            textField.setLeftPaddingPoints(padding)
        }
    }
    
    
    func changePlaceholderText(to newText: String, withColor color: UIColor) {
        attributedPlaceholder = NSAttributedString(string: newText, attributes: [NSAttributedString.Key.foregroundColor: color])
    }
    
    func changePlaceholderText(to newText: String) {
        attributedPlaceholder = NSAttributedString(string: newText, attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: K.ColorNames.placeholderTextColor) ?? UIColor.gray])
    }
    
    
    func setRightViewButton(icon: UIImage, width: CGFloat, height: CGFloat, parentVC: UIViewController, action: Selector) {
        let btnView = UIButton(frame: CGRect(x: 0, y: 0, width: width, height: height))
        btnView.setImage(icon, for: .normal)
        btnView.tintColor = K.Colors.goldenThemeColorInverseMoreContrast
        btnView.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        btnView.addTarget(parentVC, action: action, for: .touchUpInside)
        self.rightViewMode = .always
        self.rightView = btnView
    }
	
	
	
//	@IBInspectable var doneAccessory: Bool{
//		get{
//			return self.doneAccessory
//		}
//		set (hasDone) {
//			if hasDone{
//				addDoneButtonOnKeyboard()
//			}
//		}
//	}
//
//	func addDoneButtonOnKeyboard() {
//		let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
//		doneToolbar.barStyle = .default
//
//		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//		let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
//		done.tintColor = K.Colors.goldenThemeColorInverseMoreContrast
//
//		let items = [flexSpace, done]
//		doneToolbar.items = items
//		doneToolbar.sizeToFit()
//
//		self.inputAccessoryView = doneToolbar
//	}
//
//	@objc func doneButtonAction() {
//		self.resignFirstResponder()
//	}
}
