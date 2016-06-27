//
//  AudienceViewController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/26/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase

class AudienceViewController: UIViewController {
	
	var audienceData = [String]()
	var selectedUsers = [String]()
	var track: SpotifyTrack!

	@IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
		refreshAudience()
    }

	@IBAction func onActionButton(sender: UIButton) {
		
	}
	@IBAction func onSend(sender: AnyObject) {
		print("send")
		print(selectedUsers)
		
		let date = Utilities.getServerTime()
		
		
		FIRDatabase.database().reference().child("users/users_by_name/\(Utilities.getCurrentUsername())/songs_for_audience").child(date).setValue(["title": track.title, "artist": track.artist, "imageURL": track.imageUrl, "previewURL": track.previewUrl])
		
		for person in selectedUsers {
			FIRDatabase.database().reference().child("users/users_by_name/\(person)/received").child(date).setValue(["title": track.title, "artist": track.artist, "imageURL": track.imageUrl, "previewURL": track.previewUrl, "host": Utilities.getCurrentUsername()])
		}
		self.navigationController?.popViewControllerAnimated(true)
	}
	
	func refreshAudience() {
		FIRDatabase.database().reference().child("users/users_by_name/\(Utilities.getCurrentUsername())/friends_by_id").observeEventType(.Value, withBlock: {(snapshot) in
			self.audienceData.removeAll()
			
			if snapshot.value is NSNull {
				print("No audience")
			} else {
				guard let results = snapshot.value as? [String: [String: String]] else {
					print("getting the audience failed")
					return
				}
				
				for person in results.keys {
					self.audienceData.append(person)
				}
			}
			
			dispatch_async(dispatch_get_main_queue()) { [unowned self] in
				self.tableView.reloadData()
			}
		})
	}
}

extension AudienceViewController: UITableViewDataSource {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return audienceData.count
	}
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! AudienceTableViewCell
		
		cell.title = audienceData[indexPath.row]
		
		return cell
	}
}

extension AudienceViewController: UITableViewDelegate {
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		print(indexPath.row)
		let cell = tableView.cellForRowAtIndexPath(indexPath) as! AudienceTableViewCell
		if cell.actionButton.backgroundColor == UIColor.clearColor() {
			cell.actionButton.backgroundColor = Utilities.getGreenColor()
			selectedUsers.append(cell.title)
		} else {
			cell.actionButton.backgroundColor = UIColor.clearColor()
			let index = selectedUsers.indexOf(cell.title)
			selectedUsers.removeAtIndex(index!)
		}
		
	}
}
