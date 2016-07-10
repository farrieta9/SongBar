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
		let date = Utilities.getServerTime()
		
		FIRDatabase.database().reference().child("users/users_by_name/\(Utilities.getCurrentUsername())/songs_for_fans").child(date).setValue(["title": track.title, "artist": track.artist, "imageURL": track.imageUrl, "previewURL": track.previewUrl])
		
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
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 50
	}
}

extension AudienceViewController: UITableViewDelegate {
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = tableView.cellForRowAtIndexPath(indexPath) as! AudienceTableViewCell
		cell.accessoryType = .Checkmark
		selectedUsers.append(cell.title)
		
	}
	
	func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = tableView.cellForRowAtIndexPath(indexPath) as! AudienceTableViewCell
		cell.accessoryType = .None
		let index = selectedUsers.indexOf(cell.title)
		selectedUsers.removeAtIndex(index!)
	}
}
