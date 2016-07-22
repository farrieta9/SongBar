//
//  HomeController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/13/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class HomeController: UIViewController {

	@IBOutlet weak var tableView: UITableView!
	
	@IBOutlet weak var toolBar: UIToolbar!
	@IBOutlet weak var playButton: UIBarButtonItem!
	
	var spotifyData = [Track]()
	var donorsData = [User]()
	var playPauseButton: UIBarButtonItem!
	
	@IBAction func onStopToolBar(sender: UIBarButtonItem) {
		toolBar.hidden = true
		MusicPlayer.hidden = true
		MusicPlayer.audioPlay.pause()
	}
	
	@IBAction func onPlay(sender: UIBarButtonItem) {
		switch MusicPlayer.musicStatus {
		case .Pause:
			MusicPlayer.musicStatus = .Play
			loadPauseButton()
			MusicPlayer.audioPlay.play()

		case .Play:
			MusicPlayer.musicStatus = .Pause
			loadPlayButton()
			MusicPlayer.audioPlay.pause()
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		getLoggedInUser()
		setUpViews()
		fetchReceived()
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		toolBar.hidden = MusicPlayer.hidden
		
		switch MusicPlayer.musicStatus {
		case .Play:
			loadPauseButton()
		case .Pause:
			loadPlayButton()
		}
	}
	
	private func loadPlayButton() {
		playPauseButton = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: #selector(self.onPlay(_:)))
		var items = toolBar.items!
		items[0] = playPauseButton
		toolBar.setItems(items, animated: false)
	}
	
	private func loadPauseButton() {
		playPauseButton = UIBarButtonItem(barButtonSystemItem: .Pause, target: self, action: #selector(self.onPlay(_:)))
		var items = toolBar.items!
		items[0] = playPauseButton
		toolBar.setItems(items, animated: false)
	}

	func setUpViews() {
		tableView.dataSource = self
		tableView.delegate = self
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
			
			guard let results = snapshot.value as? [String: [String: String]] else {
				return
			}
			
			self.spotifyData.removeAll()
			self.donorsData.removeAll()
			
			for (key, value) in results.sort({$0.0.compare($1.0) == NSComparisonResult.OrderedDescending}) {
				
				guard let uid = value["donor"] else {
					return
				}
				
				FIRDatabase.database().reference().child("users_by_id/\(uid)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
					
					if let results = snapshot.value as? [String: AnyObject] {
						
						if let artist = value["artist"], title = value["title"], imageURL = value["imageURL"], previewURL = value["previewURL"], username = results["username"] as? String, fullname = results["fullname"] as? String, email = results["email"] as? String {
							
							var imageUrlAsString = ""
							if let image = results["imageURL"] as? String {
								imageUrlAsString = image
							}
							
							let track = Track(artist: artist, title: title, previewURL: previewURL, imageURL: imageURL)
							let user = User(email: email, fullname: fullname, username: username, uid: uid, image: imageUrlAsString)
							
							track.date = key
							track.donor = uid
							self.spotifyData.append(track)
							self.donorsData.append(user)
						}
					}
					
					
					dispatch_async(dispatch_get_main_queue(), {
						self.tableView.reloadData()
					})
					
					
					}, withCancelBlock: nil)
			}
			}, withCancelBlock: nil)
	}
}

extension HomeController: UITableViewDataSource {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return spotifyData.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! FeedCell
		cell.titleLabel.text = spotifyData[indexPath.row].title
		cell.detailLabel.text = spotifyData[indexPath.row].artist
		cell.donorLabel.text = donorsData[indexPath.row].username
		cell.pictureView.loadImageUsingURLString(spotifyData[indexPath.row].imageUrl)
		
		return cell
	}
}

extension HomeController: UITableViewDelegate {
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		MusicPlayer.hidden = false
		toolBar.hidden = false
		let previewURL = spotifyData[indexPath.row].previewUrl
		let url = NSURL(string: previewURL)
		MusicPlayer.audioPlay = AVPlayer(URL: url!)
		MusicPlayer.audioPlay.play()
		MusicPlayer.musicStatus = .Play
		loadPauseButton()
		
	}
}







