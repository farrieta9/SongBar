//
//  Profile2ViewController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/18/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
	
	
	@IBOutlet weak var tableView: UITableView!
	private let tableHeaderHeight: CGFloat = 100.0
	private let tableHeaderCutAway: CGFloat = 0.0
	
	private var headerView: ProfileHeaderView!
	private var headerMaskLayer: CAShapeLayer!
	
	enum contentTypes {
		case Audience, Follow
	}
	
	var contentToDisplay: contentTypes = .Audience
	var audienceData = [String]()
	var followData = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		headerView = tableView.tableHeaderView as! ProfileHeaderView
		tableView.tableHeaderView = nil  // Clear out the default header
		tableView.addSubview(headerView) // Add header
		
		tableView.contentInset = UIEdgeInsets(top: tableHeaderHeight, left: 0, bottom: 0, right: 0)
		tableView.contentOffset = CGPoint(x: 0, y: -tableHeaderHeight)
		
		headerMaskLayer = CAShapeLayer()
		headerMaskLayer.fillColor = UIColor.blackColor().CGColor
		
		headerView.layer.mask = headerMaskLayer
		
		updateHeaderView()
		
		refreshAudience()
		refreshFollow()
		
    }
	
	func refreshAudience() {
		// Get the audience
		FIRDatabase.database().reference().child("users/users_by_name/\(Utilities.getCurrentUsername())/audience_by_id").observeEventType(.Value, withBlock: {(snapshot) in
			
			guard let results = snapshot.value as? [String: [String: String]] else {
				print("getting the audience failed")
				return
			}
			
			for person in results.keys {
				self.audienceData.append(person)
			}
			
			self.tableView.reloadData()
		})
	}
	
	func refreshFollow() {
		FIRDatabase.database().reference().child("users/users_by_name/\(Utilities.getCurrentUsername())/friends_by_id").observeEventType(.Value, withBlock: {(snapshot) in
			
			guard let results = snapshot.value as? [String: [String: String]] else {
				print("getting friends failed") // Perhaps there are no results
				return
			}
			for person in results.keys {
				self.followData.append(person)
			}
			self.tableView.reloadData()
		})
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		updateHeaderView()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		updateHeaderView()
	}
	@IBAction func onContentDisplayChange(sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0:
			contentToDisplay = .Audience
		case 1:
			contentToDisplay = .Follow
		default:
			break
		}
		tableView.reloadData()
	}
	
	func updateHeaderView() {
		let effectiveHeight = tableHeaderHeight - tableHeaderCutAway / 2
		var headerRect = CGRect(x: 0, y: -effectiveHeight, width: tableView.bounds.width, height: tableHeaderHeight)
		
		if tableView.contentOffset.y < -effectiveHeight {
			headerRect.origin.y = tableView.contentOffset.y
			headerRect.size.height = -tableView.contentOffset.y + tableHeaderCutAway / 2
		}
		
		headerView.frame = headerRect
		
		// Cut away
		let path = UIBezierPath()
		path.moveToPoint(CGPoint(x: 0, y: 0))
		path.addLineToPoint(CGPoint(x: headerRect.width, y: 0))
		path.addLineToPoint(CGPoint(x: headerRect.width, y: headerRect.height))
		
		path.addLineToPoint(CGPoint(x: 0, y:headerRect.height - tableHeaderCutAway))
		
		headerMaskLayer?.path = path.CGPath
	}
}


extension ProfileViewController: UITableViewDataSource	{
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 1 {
			switch contentToDisplay {
			case .Audience:
				return audienceData.count
				
			case .Follow:
				return followData.count
			}
		}
		return 1
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		if indexPath.section == 1 {
			let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! ProfileTableViewCell
			
			switch contentToDisplay {
			case .Audience:
				cell.username = audienceData[indexPath.row]
			case .Follow:
				cell.username = followData[indexPath.row]
			}
			
			return cell
		} else {
			let cell = tableView.dequeueReusableCellWithIdentifier("headerCell") as! ProfileHeaderTableViewCell
			cell.username = Utilities.getCurrentUsername()
			
			return cell
		}
	}
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		switch indexPath.section {
		case 0:
			return 175
		case 1:
			return 50
		default:
			return 50
		}
	}
}

extension ProfileViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(scrollView: UIScrollView) {
		updateHeaderView()
	}
}