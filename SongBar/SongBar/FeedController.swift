//
//  FeedController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/13/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class FeedController: UIViewController {

	@IBOutlet weak var tableView: UITableView!
	
	var spotifyData = [Track]()
	var donorsData = [User]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		getLoggedInUser()
		setUpViews()
		fetchReceived()
    }

	func setUpViews() {
		tableView.dataSource = self
		tableView.delegate = self
		self.navigationItem.title = "SongBar"
	}
	
	private func getLoggedInUser() {
		if FIRAuth.auth()?.currentUser?.uid == nil {
			self.dismissViewControllerAnimated(true, completion: nil) // Back to the login in screen
		} else {
			let uid = FIRAuth.auth()?.currentUser?.uid
			FIRDatabase.database().reference().child("users_by_id").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
				if let result = snapshot.value as? [String: AnyObject] {
					CurrentUser.username = result["username"] as? String
					CurrentUser.fullname = result["fullname"] as? String
					CurrentUser.uid = uid
					CurrentUser.imageString = result["imageURL"] as? String
					CurrentUser.email = result["email"] as? String
				}
			})
		}
	}
	
	func fetchReceived() {
		guard let uid = CurrentUser.uid else {
			return
		}
		
		FIRDatabase.database().reference().child("users_by_id/\(uid)/received").observeEventType(.Value, withBlock: { (snapshot) in
			
			self.spotifyData.removeAll()
			
			guard let results = snapshot.value as? [String: [String: String]] else {
				return
			}

			for (key, value) in results.sort({$0.0.compare($1.0) == NSComparisonResult.OrderedDescending}) {
				if let artist = value["artist"], title = value["title"],
					donor = value["donor"], imageURL = value["imageURL"],
					commentReference = value["comment_reference"], previewURL = value["previewURL"] {
					
					let track = Track(artist: artist, title: title, previewURL: previewURL, imageURL: imageURL)
					track.donor = donor
					track.date = key
					track.commentReference = commentReference
					self.spotifyData.append(track)
				}
			}
			
			dispatch_async(dispatch_get_main_queue(), { 
				self.tableView.reloadData()
			})
			
			
		}, withCancelBlock: nil)
	}
}

extension FeedController: UITableViewDataSource {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return spotifyData.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! FeedCell
		
		cell.setCellContent(spotifyData[indexPath.row])
		
		return cell
	}
}

extension FeedController: UITableViewDelegate {
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		MusicPlayer.playSong(spotifyData[indexPath.row].previewUrl, title: spotifyData[indexPath.row].title, detail: spotifyData[indexPath.row].artist)
	}
}







