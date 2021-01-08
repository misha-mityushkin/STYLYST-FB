//
//  ViewControllerExtension.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-05-28.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    func hideKeyboardWhenTappedAround(for view: UIView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}

