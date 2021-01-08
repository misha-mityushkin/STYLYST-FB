//
//  SubscriptionPlansViewController.swift
//  STYLYST FB
//
//  Created by Michael Mityushkin on 2020-08-20.
//  Copyright © 2020 Michael Mityushkin. All rights reserved.
//

import UIKit

class SubscriptionPlansViewController: UIViewController {
	
	@IBOutlet weak var navigationBar: UINavigationBar!
	
	@IBOutlet weak var planTypeSegmentedControl: UISegmentedControl!
	@IBOutlet weak var planDetailsLabel: UILabel!
	@IBOutlet weak var monthlyFeeLabel: UILabel!
	@IBOutlet weak var numStaffMembersLabel: UILabel!
	
	var businessRegisterVC: BusinessRegisterViewController?
	
	var subscriptionPlans: [SubscriptionPlan]?
	var selectedPlanIndex = 0
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if let subscriptionPlans = businessRegisterVC?.subscriptionPlans {
			self.subscriptionPlans = subscriptionPlans
		} else {
			Alerts.showNoOptionAlert(title: "Error", message: "We were unable to load this content. Please try again later", sender: self) { (_) in
				self.dismiss(animated: true, completion: nil)
			}
			return
		}

		var planNames: [String] = []
		for plan in subscriptionPlans! {
			planNames.append(plan.name)
		}
		print("plan names: \(planNames)")
		self.planTypeSegmentedControl.replaceSegments(segments: planNames)
		self.planTypeSegmentedControl.selectedSegmentIndex = 0
		let selectedPlan = subscriptionPlans![0]
		self.selectedPlanIndex = 0
		self.planDetailsLabel.text = "\(selectedPlan.name) Plan Details"
		self.monthlyFeeLabel.text = "- $\(Int(selectedPlan.price)) monthly"
		self.numStaffMembersLabel.text = "- \(selectedPlan.numStaffDisplay) staff member"
		if selectedPlan.numStaff != 1 {
			self.numStaffMembersLabel.text?.append("s")
		}
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationBar.tintColor = .black
		navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
	}
    
	@IBAction func subscriptionChanged(_ sender: UISegmentedControl) {
		sender.isUserInteractionEnabled = false
		let selectedPlan = subscriptionPlans![sender.selectedSegmentIndex]
		selectedPlanIndex = sender.selectedSegmentIndex
		UIView.animate(withDuration: 0.3, animations: {
			self.planDetailsLabel.alpha = 0
			self.monthlyFeeLabel.alpha = 0
			self.numStaffMembersLabel.alpha = 0
		}) { (_) in
			self.planDetailsLabel.text = "\(selectedPlan.name) Plan Details"
			self.monthlyFeeLabel.text = "- $\(Int(selectedPlan.price)) monthly"
			self.numStaffMembersLabel.text = "- \(selectedPlan.numStaffDisplay) staff member"
			if selectedPlan.numStaff != 1 {
				self.numStaffMembersLabel.text?.append("s")
			}
			sender.isUserInteractionEnabled = true
			
			UIView.animate(withDuration: 0.3) {
				self.planDetailsLabel.alpha = 1
				self.monthlyFeeLabel.alpha = 1
				self.numStaffMembersLabel.alpha = 1
			}
		}
	}
	
	
	@IBAction func closePressed(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}
	

}
