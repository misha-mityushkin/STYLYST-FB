//
//  SegmentedControlExtention.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-08-01.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

extension UISegmentedControl {
	func replaceSegments(segments: Array<String>) {
		self.removeAllSegments()
		for segment in segments {
			self.insertSegment(withTitle: segment, at: self.numberOfSegments, animated: false)
		}
	}
}
