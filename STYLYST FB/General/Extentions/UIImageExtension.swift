//
//  UIImageExtension.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-08-11.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

extension UIImage {
	func colorImage(with color: UIColor) -> UIImage? {
		guard let cgImage = self.cgImage else { return nil }
		UIGraphicsBeginImageContext(self.size)
		let contextRef = UIGraphicsGetCurrentContext()
		
		contextRef?.translateBy(x: 0, y: self.size.height)
		contextRef?.scaleBy(x: 1.0, y: -1.0)
		let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
		
		contextRef?.setBlendMode(CGBlendMode.normal)
		contextRef?.draw(cgImage, in: rect)
		contextRef?.setBlendMode(CGBlendMode.sourceIn)
		color.setFill()
		contextRef?.fill(rect)
		
		let coloredImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return coloredImage
	}
}
