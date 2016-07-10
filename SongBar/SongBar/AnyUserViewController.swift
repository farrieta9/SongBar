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
	var fans = [User]()
	var following = [User]()
	var postData = [String]()

	let user: User = {
		let person = User()
		return person
	}()
	
	@IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

		loadFans()
		loadFollowing()
		loadPosts()
    }

	@IBAction func onActionButton(sender: UIButton) {
		if sender.titleLabel?.text! == "+ Follow" {
			followUser()
			sender.setTitle("Following", forState: .Normal)
			sender.backgroundColor = Utilities.getGreenColor()
		} else {
			Utilities.unFollow(user.username)
			sender.setTitle("+ Follow", forState: .Normal)
			sender.backgroundColor = UIColor.clearColor()
		}
	}
	
	func followUser() -> Void {
		// Get the uid of the selected user
		FIRDatabase.database().reference().child("users/users_by_name/\(self.user.username)").observeSingleEventOfType(.Value, withBlock: {(snapshot) in
			if let uid = snapshot.value!["uid"] as? String {
				
				// Add the data
				FIRDatabase.database().reference().child("users/users_by_name/\(Utilities.getCurrentUsername())").child("friends_by_id").child(self.user.username).setValue([uid: self.user.username, "profileImageURL": self.user.profileImageURL])
				
				// Fans is your followers
				FIRDatabase.database().reference().child("users/users_by_name/\(self.user.username)").child("audience_by_id").child(Utilities.getCurrentUsername()).setValue([Utilities.getCurrentUID(): Utilities.getCurrentUsername(), "profileImageURL": Utilities.getProfileImageURL()])
			} else {
				print("followUser() failed")
			}
		})
	}
	
	func isFollowing(button: UIButton) -> Void {
		FIRDatabase.database().reference().child("users/users_by_name/\(Utilities.getCurrentUsername())/friends_by_id/\(self.user.username)").observeSingleEventOfType(.Value, withBlock: {(snapshot) in
			if snapshot.value is NSNull {
				button.setTitle("+ Follow", forState: .Normal)
			} else {
				button.setTitle("Following", forState: .Normal)
				button.backgroundColor = Utilities.getGreenColor()
			}
		})
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
	
	private func loadFans() {
		FIRDatabase.database().reference().child("users/users_by_name/\(user.username)/audience_by_id").observeEventType(.Value, withBlock: {(snapshot) in
		
			self.fans.removeAll()
			if snapshot.value is NSNull {
				print("No audience")
				return
			}
			guard let results = snapshot.value as? [String: [String: String]] else {
				print("AnyUserViewController.loadFans() failed")
				return
			}
			for person in results.keys {
				let user = User()
				user.username = person
				if let uid = results[person]!["uid"] {
					user.uid = uid
				}
				if let profileImageURL = results[person]!["profileImageURL"] {
					user.profileImageURL = profileImageURL
				}
				self.fans.append(user)
			}
			
			dispatch_async(dispatch_get_main_queue()) {
				[unowned self] in
				self.tableView.reloadData()
			}
		})
	}
	
	private func loadFollowing() -> Void {
		FIRDatabase.database().reference().child("users/users_by_name/\(user.username)/friends_by_id").observeEventType(.Value, withBlock: {(snapshot) in
			self.following.removeAll()
			
			if snapshot.value is NSNull {
				print("This user follows no one")
				return
			}
			guard let results = snapshot.value as? [String: [String: String]] else {
				print("AnyUserViewController.loadFollowing() failed")
				return
			}
			for person in results.keys {
				let user = User()
				user.username = person
				if let uid = results[person]!["uid"] {
					user.uid = uid
				}
				if let profileImageURL = results[person]!["profileImageURL"] {
					user.profileImageURL = profileImageURL
				}
				self.following.append(user)
			}
			
			dispatch_async(dispatch_get_main_queue()) { [unowned self] in
				self.tableView.reloadData()
			}
		})
	}
	
	private func loadPosts() -> Void {
		FIRDatabase.database().reference().child("users/users_by_name/\(user.username)/songs_for_fans").queryOrderedByKey().observeEventType(.Value, withBlock: {(snapshot) in
			self.postData.removeAll()
			
			if snapshot.value is NSNull {
				print("This user has not shared any songs")
				return
			}
			
			guard let results = snapshot.value as? [String: [String: String]] else {
				print("AnyUserViewController.loadPosts() failed")
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
				return fans.count
			case .Following:
				return following.count
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
			
			cell.avatar = UIImage(named: "default_profile.png")
			
			switch contentToDisplay {
			case .Fans:
				cell.title = fans[indexPath.row].username
				
				// Load profile image
				let profileImageURLAsString = fans[indexPath.row].profileImageURL
				if profileImageURLAsString != "" {
					let url = NSURL(string: profileImageURLAsString)
					NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
						if error != nil {
							print(error)
							return
						}
						dispatch_async(dispatch_get_main_queue(), { 
							cell.avatar = UIImage(data: data!)
						})
					}).resume()
				}
				
			case .Following:
				cell.title = following[indexPath.row].username
				
				// Load profile image
				let profileImageURLAsString = following[indexPath.row].profileImageURL
				if profileImageURLAsString != "" {
					let url = NSURL(string: profileImageURLAsString)
					NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
						if error != nil {
							print(error)
							return
						}
						dispatch_async(dispatch_get_main_queue(), {
							cell.avatar = UIImage(data: data!)
						})
					}).resume()
				}
				
			case .Posts:
				cell.title = postData[indexPath.row]
			}
			return cell
			
		} else {
			let cell = tableView.dequeueReusableCellWithIdentifier("headerCell", forIndexPath: indexPath) as! UserHeaderTableViewCell
			cell.title = user.username
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
