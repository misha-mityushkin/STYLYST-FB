//
//  SearchBarFormatExt.swift
//  STYLYST
//
//  Created by Michael Mityushkin on 2020-05-20.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

extension UISearchBar {
    func changeSearchBarColor(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContext(self.frame.size)
        color.setFill()
        UIBezierPath(rect: self.frame).fill()
        let bgImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.setSearchFieldBackgroundImage(bgImage, for: .normal)
    }
    
    
    // instance method for formatting one search bar with default color
    func format(height: CGFloat) {
        changeSearchBarColor(color: UIColor(named: K.ColorNames.goldenThemeColorDefault) ?? .black, size: CGSize(width: frame.size.width, height: height))
        if #available(iOS 13.0, *) {
            searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: K.ColorNames.placeholderTextColor) ?? UIColor.gray])
        }
    }
    
    // instance method for formatting one search bar with specified color
    func format(height: CGFloat, color: UIColor?) {
        changeSearchBarColor(color: color ?? .black, size: CGSize(width: frame.size.width, height: height))
        if #available(iOS 13.0, *) {
            searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: K.ColorNames.placeholderTextColor) ?? UIColor.gray])
        }
    }
    
    
    // class method for formatting an array of search bars
    static func format(searchBars: [UISearchBar], height: CGFloat) {
        for searchBar in searchBars {
            searchBar.format(height: height)
        }
    }
}

