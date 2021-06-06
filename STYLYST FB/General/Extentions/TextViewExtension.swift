//
//  TextViewExtension.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2021-06-03.
//  Copyright © 2021 Michael Mityushkin. All rights reserved.
//

import UIKit

extension UITextView :UITextViewDelegate {

	/// Resize the placeholder when the UITextView bounds change
	override open var bounds: CGRect {
		didSet {
			self.resizePlaceholder()
		}
	}

	/// The UITextView placeholder text
	public var placeholder: String? {
		get {
			var placeholderText: String?

			if let placeholderLabel = self.viewWithTag(100) as? UILabel {
				placeholderText = placeholderLabel.text
			}

			return placeholderText
		}
		set {
			if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
				placeholderLabel.text = newValue
				placeholderLabel.sizeToFit()
			} else {
				self.addPlaceholder(newValue!)
			}
		}
	}

	/// The UITextView placeholder text color
	public var placeholderColor: UIColor? {
		get {
			var placeholderTextColor: UIColor?

			if let placeholderLabel = self.viewWithTag(100) as? UILabel {
				placeholderTextColor = placeholderLabel.textColor
			}

			return placeholderTextColor
		}
		set {
			(self.viewWithTag(100) as? UILabel)?.textColor = newValue
		}
	}
	
	func updatePlaceholder() {
		if let placeholderLabel = self.viewWithTag(100) as? UILabel {
			placeholderLabel.isHidden = self.text.count > 0
		}
	}

	/// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
	func resizePlaceholder() {
		print("RESIZE PLACEHOLDER")
		if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
			print("RESIZE PLACEHOLDER 2")
			let labelX = self.textContainer.lineFragmentPadding
			let labelY = self.textContainerInset.top - 2
			let labelWidth = self.frame.width - (labelX * 2)
			let labelHeight = placeholderLabel.frame.height

			placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
		}
	}

	/// Adds a placeholder UILabel to this UITextView
	private func addPlaceholder(_ placeholderText: String) {
		let placeholderLabel = UILabel()

		placeholderLabel.text = placeholderText
		placeholderLabel.sizeToFit()

		placeholderLabel.font = self.font
		placeholderLabel.textColor = K.Colors.placeholderTextColor
		placeholderLabel.tag = 100

		placeholderLabel.isHidden = self.text.count > 0

		self.addSubview(placeholderLabel)
		self.resizePlaceholder()
	}
}
