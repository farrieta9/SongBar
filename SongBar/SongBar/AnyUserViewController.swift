//
//  AnyUserViewController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/25/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase

class AnyUserViewController: UIViewController {
	
	enum contentType {
		case Fans, Following, Posts
	}
	
	var contentToDisplay: contentType = .Fans
	var audienceData = [String]()
	var followData = [String]()
	var postData = [String]()

	var username: String = ""
	var userFullname: String = ""
	var profileImageURL: String = ""
	
	@IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

		refreshAudience()
		refreshFollow()
		refreshPosts()
    }

	@IBAction func onActionButton(sender: UIButton) {
		if sender.titleLabel?.text! == "+ Follow" {
			followUser()
			sender.setTitle("Following", forState: .Normal)
			sender.backgroundColor = Utilities.getGreenColor()
		} else {
			unFollow(username)
			sender.setTitle("+ Follow", forState: .Normal)
			sender.backgroundColor = UIColor.clearColor()
		}
	}
	
	func followUser() -> Void {
		// Get the uid of the selected user
		FIRDatabase.database().reference().child("users/users_by_name/\(self.username)").observeSingleEventOfType(.Value, withBlock: {(snapshot) in
			if let uid = snapshot.value!["uid"] as? String {
				
				// Add the data
				FIRDatabase.database().reference().child("users/users_by_name/\(Utilities.getCurrentUsername())").child("friends_by_id").child(self.username).setValue([uid: self.username, "profileImageURL": self.profileImageURL])
				
				// Audience is your followers
				FIRDatabase.database().reference().child("users/users_by_name/\(self.username)").child("audience_by_id").child(Utilities.getCurrentUsername()).setValue([Utilities.getCurrentUID(): Utilities.getCurrentUsername(), "profileImageURL": Utilities.getProfileImageURL()])
				print("Mine: \(Utilities.getProfileImageURL())")
				print("Theirs: \(self.profileImageURL)")
			} else {
				print("followUser() failed")
			}
		})
	}
	
	func isFollowing(button: UIButton) -> Void {
		FIRDatabase.database().reference().child("users/users_by_name/\(Utilities.getCurrentUsername())/friends_by_id/\(self.username)").observeSingleEventOfType(.Value, withBlock: {(snapshot) in
			if snapshot.value is NSNull {
				button.setTitle("+ Follow", forState: .Normal)
			} else {
				button.setTitle("Following", forState: .Normal)
				button.backgroundColor = Utilities.getGreenColor()
			}
		})
	}
	
	func unFollow(username: String) -> Void {
		print("Unfollow \(username)")
		FIRDatabase.database().reference().child("users/users_by_name/\(Utilities.getCurrentUsername())/friends_by_id/\(username)").removeValue()
		
		FIRDatabase.database().reference().child("users/users_by_name/\(username)/audience_by_id/\(Utilities.getCurrentUsername())").removeValue()
	}
	
	@IBAction func onSegmentOptionChange(sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0:
			contentToDisplay = .Fans
		case 1:
			contentToDisplay = .Following
		case 2:
			contentToDisplay = .Posts
		default:
			break
		}
		tableView.reloadData()
	}
	
	func refreshAudience() {
		FIRDatabase.database().reference().child("users/users_by_name/\(username)/audience_by_id").observeEventType(.Value, withBlock: {(snapshot) in
		
			self.audienceData.removeAll()
			if snapshot.value is NSNull {
				print("No audience")
				return
			}
			guard let results = snapshot.value as? [String: [String: String]] else {
				print("AnyUserViewController.refreshAudience() failed")
				return
			}
			for person in results.keys {
				self.audienceData.append(person)
			}
			
			dispatch_async(dispatch_get_main_queue()) {
				[unowned self] in
				self.tableView.reloadData()
			}
		})
	}
	
	func refreshFollow() -> Void {
		FIRDatabase.database().reference().child("users/users_by_name/\(username)/friends_by_id").observeEventType(.Value, withBlock: {(snapshot) in
			self.followData.removeAll()
			if snapshot.value is NSNull {
				print("This user follows no one")
				return
			}
			guard let results = snapshot.value as? [String: [String: String]] else {
				print("AnyUserViewController.refreshFollow() failed")
				return
			}
			for person in results.keys {
				self.followData.append(person)
			}
			
			dispatch_async(dispatch_get_main_queue()) { [unowned self] in
				self.tableView.reloadData()
			}
		})
	}
	
	func refreshPosts() -> Void {
		FIRDatabase.database().reference().child("users/users_by_name/\(username)/songs_for_fans").queryOrderedByKey().observeEventType(.Value, withBlock: {(snapshot) in
			self.postData.removeAll()
			
			if snapshot.value is NSNull {
				print("This user has not shared any songs")
				return
			}
			
			guard let results = snapshot.value as? [String: [String: String]] else {
				print("AnyUserViewController.refreshPosts() failed")
				return
			}
			for (_, value) in results.sort({$0.0.compare($1.0) == NSComparisonResult.OrderedDescending}) {  // Sort by date while looping
					let title = value["title"]
				self.postData.append(title!)
			}
			
			dispatch_async(dispatch_get_main_queue()) { [unowned self] in
				self.tableView.reloadData()
			}
		
		})
	}
}

extension AnyUserViewController: UITableViewDataSource {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 1 {
			switch contentToDisplay {
			case .Fans:
				return audienceData.count
			case .Following:
				return followData.count
			case .Posts:
				return postData.count
			}
		}
		return 1
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		if indexPath.section == 1 {
			let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UserTableViewCell
			
			switch contentToDisplay {
			case .Fans:
				cell.title = audienceData[indexPath.row]
			case .Following:
				cell.title = followData[indexPath.row]
			case .Posts:
				cell.title = postData[indexPath.row]
			}
			return cell
			
		} else {
			let cell = tableView.dequeueReusableCellWithIdentifier("headerCell", forIndexPath: indexPath) as! UserHeaderTableViewCell
			cell.title = username
			isFollowing(cell.actionButton)
			return cell
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		switch indexPath.section {
		case 0:
			return 150
		default:
			return 50
		}
	}
}
