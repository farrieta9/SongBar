//
//  AnyUserViewController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/25/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit

class AnyUserViewController: UIViewController {
	
	enum contentType {
		case Audience, Follow, Posts
	}
	
	var contentToDisplay: contentType = .Audience
	var audienceData = [String]()
	var followData = [String]()
	var postData = [String]()

	
	var username = ""
	var userFullname = ""
	
	@IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
		
		print("Username: \(username)")
		
    }
	
	@IBAction func onSegmentOptionChange(sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0:
			contentToDisplay = .Audience
		case 1:
			contentToDisplay = .Follow
		case 2:
			contentToDisplay = .Posts
		default:
			break
		}
	}
}

extension AnyUserViewController: UITableViewDataSource {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 1 {
			switch contentToDisplay {
			case .Audience:
				return audienceData.count
			case .Follow:
				return followData.count
			case .Posts:
				return postData.count
			}
		}
		return 1
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		switch indexPath.section {
		case 0:
			let cell = tableView.dequeueReusableCellWithIdentifier("headerCell", forIndexPath: indexPath) as! UserHeaderTableViewCell
			
			cell.actionName = "Follow"
			cell.title = username
			return cell
			
		default:
			let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UserTableViewCell
			
			cell.title = "Something"
			return cell
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		switch indexPath.section {
		case 0:
			return 175
		default:
			return 50
		}
	}
}
