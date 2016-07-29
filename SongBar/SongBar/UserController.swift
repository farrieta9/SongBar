//
//  UserController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/14/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class UserController: UIViewController, UINavigationControllerDelegate {
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var profileView: UIView!
	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var profileUsernameLabel: UILabel!
	@IBOutlet weak var profileFullnameLabel: UILabel!
	@IBOutlet weak var profileActionButton: UIButton!
	@IBOutlet weak var segmentControl: UISegmentedControl!
	@IBOutlet weak var settingsBarItem: UIBarButtonItem!
	
	enum ContentOptions {
		case Posts, Fans, Following
	}
	
	var followingData = [User]()
	var fansData = [User]()
	var postsData = [Track]()
	var contentOptions: ContentOptions = .Posts
	var selectedIndexPath: NSIndexPath?
	var displayedUser: User?
	let refreshControl: UIRefreshControl = UIRefreshControl()
	var playPauseButton: UIBarButtonItem!
	
	lazy var settingsLauncher: SettingsLauncher = {
		let launcher = SettingsLauncher()
		launcher.userController = self
		return launcher
	}()
	
	@IBAction func handleSettings(sender: UIBarButtonItem) {
		settingsLauncher.showSettings()
	}
	
	@IBAction func handleProfileActionButton(sender: UIButton) {
		guard let user = displayedUser else {
			return
		}
		
		if sender.titleLabel?.text == "+ Follow" {
			followUser(user)
			sender.backgroundColor = UIColor.greenColor()
			sender.setTitle("Following", forState: .Normal)
		} else {
			unFollowUser(user)
			sender.backgroundColor = UIColor.clearColor()
			sender.setTitle("+ Follow", forState: .Normal)
		}
	}
	
	func unFollowUser(user: User) {
		guard let uid = user.uid else {
			return
		}
		
		guard let signedInUsersId = CurrentUser.uid else {
			return
		}
		
		FIRDatabase.database().reference().child("users_by_id/\(uid)/Fans/\(signedInUsersId)").removeValue()
		FIRDatabase.database().reference().child("users_by_id/\(signedInUsersId)/Following/\(uid)").removeValue()
	}

	@IBAction func handleProfileSegmentControl(sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0: contentOptions = .Posts
		case 1: contentOptions = .Fans
		case 2: contentOptions = .Following
		default:
			return
		}
		
		dispatch_async(dispatch_get_main_queue()) { 
			self.tableView.reloadData()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		setUpProfile()
		setUpView()
		fetchPosts()
		fetchFollowing()
		fetchFans()
	}
	
	func setUpView() {
		refreshControl.addTarget(self, action: #selector(self.handleRefreshControl), forControlEvents: .ValueChanged)
		tableView.addSubview(refreshControl)
	}
	
	func handleRefreshControl() {
		dispatch_async(dispatch_get_main_queue()) { 
			self.tableView.reloadData()
			self.refreshControl.endRefreshing()
		}
	}
	
	// This pulls up the camera, or the photo library
	func launchImagePicker(sourceType: UIImagePickerControllerSourceType){
		if UIImagePickerController.isSourceTypeAvailable(sourceType){
			let imagePicker = UIImagePickerController()
			imagePicker.sourceType = sourceType
			imagePicker.delegate = self
			imagePicker.allowsEditing = true
			presentViewController(imagePicker, animated: true, completion: nil)
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "userControllerID" {
			let vc = segue.destinationViewController as! UserController
			guard let indexPath = selectedIndexPath else {
				return
			}
			
			switch contentOptions {
			case .Fans:
				let selectedUser = fansData[indexPath.row]
				vc.displayedUser = selectedUser
			case .Following:
				let selectedUser = followingData[indexPath.row]
				vc.displayedUser = selectedUser
			default:
				return
			}
		}
	}

	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		switch contentOptions {
		case .Posts:
			return false  // Do not perform segue
		default:
			return true
		}
	}
	
	func fetchDisplayedUsersImage(imageURLString: String) {
		guard let uid = displayedUser?.uid else {
			return
		}
		
		FIRDatabase.database().reference().child("users_by_id/\(uid)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
			if let result = snapshot.value as? [String: AnyObject] {
				guard let urlString = result["imageURL"] as? String else {
					return
				}
				
				self.profileImageView.loadImageUsingURLString(urlString)
			}
			
			}, withCancelBlock: nil)
	}
	
	func fetchFans() {
		guard let uid = displayedUser?.uid else {
			return
		}
		
		FIRDatabase.database().reference().child("users_by_id/\(uid)/Fans").observeEventType(.Value, withBlock: { (snapshot) in
			
			self.fansData.removeAll()
			guard let result = snapshot.value as? [String: [String: String]] else {
				return
			}
			
			for (key, _) in result {
				
				FIRDatabase.database().reference().child("users_by_id/\(key)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
					guard let person = snapshot.value as? [String: AnyObject] else {
						return
					}
					
					var imageURL = ""
					if let imageURAsString = person["imageURL"] as? String {
						imageURL = imageURAsString
					}
					
					if let email = person["email"] as? String, fullname = person["fullname"] as? String, username = person["username"] as? String {
						let user = User(email: email, fullname: fullname, username: username, uid: key, image: imageURL)
						
						// Check the user is not already in the table
						if self.isUserADuplicateInTableData(key, tableData: self.fansData) == false {
							self.fansData.append(user)
						}
					}
					
					}, withCancelBlock: nil)
			}
			
			}, withCancelBlock: nil)
	}
	
	func fetchFollowing() {
		guard let uid = displayedUser?.uid else {
			return
		}
		
		FIRDatabase.database().reference().child("users_by_id/\(uid)/Following").observeEventType(.Value, withBlock: { (snapshot) in
			self.followingData.removeAll()
			
			guard let result = snapshot.value as? [String: [String: String]] else {
				return
			}

			
			for (key, _) in result {
				
				FIRDatabase.database().reference().child("users_by_id/\(key)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
					guard let person = snapshot.value as? [String: AnyObject] else {
						return
					}
					
					var imageURL = ""
					if let imageURAsString = person["imageURL"] as? String {
						imageURL = imageURAsString
					}
					
					if let email = person["email"] as? String, fullname = person["fullname"] as? String, username = person["username"] as? String {
						let user = User(email: email, fullname: fullname, username: username, uid: key, image: imageURL)
						
						if self.isUserADuplicateInTableData(key, tableData: self.followingData) == false {
							self.followingData.append(user)
						}
					}
					
					}, withCancelBlock: nil)
			}

			}, withCancelBlock: nil)
	}
	
	func fetchPosts() {
		guard let uid = displayedUser?.uid else {
			return
		}
		FIRDatabase.database().reference().child("users_by_id/\(uid)/sent").observeEventType(.Value, withBlock: { (snapshot) in
			guard let results = snapshot.value as? [String: [String: String]] else {
				return
			}
			
			self.postsData.removeAll()
			
			for (_, value) in results.sort({$0.0.compare($1.0) == NSComparisonResult.OrderedDescending}) {
				
				if let artist = value["artist"], title = value["title"], imageURL = value["imageURL"], previewURL = value["previewURL"] {
					let track = Track(artist: artist, title: title, previewURL: previewURL, imageURL: imageURL)
					self.postsData.append(track)
				}
			}

			dispatch_async(dispatch_get_main_queue(), {
				self.tableView.reloadData()
			})
			
			
			}, withCancelBlock: nil)
	}
	
	private func isUserADuplicateInTableData(uid: String, tableData: [User]) -> Bool {
		for user in tableData {
			if user.uid == uid {
				return true
			}
		}
		return false
	}
	
	
	func followUser(user: User) {
		guard let signedInUsersId = CurrentUser.uid, signedInUsersUsername = CurrentUser.username, signedInUsersFullname = CurrentUser.fullname, signedInUsersEmail = CurrentUser.email else {
			return // CurrentUser.uid has not been set
		}
	
		guard let name = user.username, email = user.email, uid = user.uid, fname = user.fullname else {
			return
		}
	
		var value = ["username": name, "email": email, "fullname": fname]
		FIRDatabase.database().reference().child("users_by_id/\(signedInUsersId)").child("Following").child(uid).updateChildValues(value)
		
		if let imageURLAsString = user.imageString {
			FIRDatabase.database().reference().child("users_by_id/\(signedInUsersId)").child("Following").child(uid).updateChildValues(["imageURL": imageURLAsString])
		}
	
		value = ["username": signedInUsersUsername, "email": signedInUsersEmail, "fullname": signedInUsersFullname]
		
		FIRDatabase.database().reference().child("users_by_id/\(uid)").child("Fans").child(signedInUsersId).updateChildValues(value)
		
		if let imageURLAsString = CurrentUser.imageString {
			FIRDatabase.database().reference().child("users_by_id/\(uid)").child("Fans").child(signedInUsersId).updateChildValues(["imageURL": imageURLAsString])
		}
	}

	
	private func registerImageToUser(image: UIImage) {
		// Stores the image into Firebase, and sets the image on the view
		guard let uploadData = UIImageJPEGRepresentation(image, 0.1), userID = CurrentUser.uid, name = CurrentUser.username else {
			return
		}
		
		
		FIRStorage.storage().reference().child("user_images/\(userID)").putData(uploadData, metadata: nil) { (metadata, error) in
			if error != nil {
				print(error)
				return
			}
			
			self.profileImageView.image = image
			guard let imageURL = metadata?.downloadURL()?.absoluteString else {
				print("Failed but why?")
				return
			}
			self.profileImageView.image = image
			FIRDatabase.database().reference().child("users_by_name/\(name)").updateChildValues(["imageURL": imageURL])
			FIRDatabase.database().reference().child("users_by_id/\(userID)").updateChildValues(["imageURL": imageURL])
		}
	}

	func setUpProfileView() {
		profileView.backgroundColor = UIColor.clearColor()
		segmentControl.setTitle("Posts", forSegmentAtIndex: 0)
		segmentControl.setTitle("Fans", forSegmentAtIndex: 1)
		segmentControl.insertSegmentWithTitle("Following", atIndex: 2, animated: false)
		
		profileActionButton.backgroundColor = UIColor.clearColor()
		profileActionButton.layer.cornerRadius = 15
		profileActionButton.layer.borderWidth = 1
		profileActionButton.layer.borderColor = UIColor.blackColor().CGColor
		
		settingsBarItem.enabled = false
	}
	
	func setUpActionButton() {
			guard let uid = displayedUser?.uid, signedInUsersId = CurrentUser.uid else {
				return
			}
			FIRDatabase.database().reference().child("users_by_id/\(signedInUsersId)/Following/\(uid)").observeSingleEventOfType(.Value,withBlock: { (snapshot) in
			if snapshot.value is NSNull {
				self.profileActionButton.setTitle("+ Follow", forState: .Normal)
				self.profileActionButton.backgroundColor = UIColor.clearColor()
			} else {
				self.profileActionButton.setTitle("Following", forState: .Normal)
				self.profileActionButton.backgroundColor = UIColor.greenColor()
			}

			}, withCancelBlock: nil)
		}
	
	func setUpProfile() {
		setUpProfileView()
		
		if displayedUser == nil {
			displayedUser = User()
			profileActionButton.hidden = true
			settingsBarItem.enabled = true
		}
		profileUsernameLabel.text = displayedUser?.username
		profileFullnameLabel.text = displayedUser?.fullname
		if let imageString = displayedUser?.imageString {
			fetchDisplayedUsersImage(imageString)
		}
		setUpActionButton()
	}
}

extension UserController: UITableViewDataSource {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 0
		} else {
			switch contentOptions {
			case .Posts:
				return postsData.count
			case .Fans:
				return fansData.count
			case .Following:
				return followingData.count
			}
		}
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ContentCell
		
		switch contentOptions {
		case .Posts:
			cell.setCell(postsData[indexPath.row].title, detail: postsData[indexPath.row].artist, imageString: postsData[indexPath.row].imageUrl)
			
		case .Fans:
			cell.setCell(fansData[indexPath.row].username!, detail: fansData[indexPath.row].fullname!, imageString: fansData[indexPath.row].imageString!)
			
		case .Following:
			cell.setCell(followingData[indexPath.row].username!, detail: followingData[indexPath.row].fullname!, imageString: followingData[indexPath.row].imageString!)
		}
		
		return cell
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 70
	}
}

extension UserController: UITableViewDelegate {
	func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
		selectedIndexPath = indexPath
		return indexPath
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		switch contentOptions {
		case .Posts:
			let previewURL = postsData[indexPath.row].previewUrl
			MusicPlayer.playSong(previewURL, title: postsData[indexPath.row].title, detail: postsData[indexPath.row].artist)
		default:
			return
		}
	}
}

extension UserController: UIImagePickerControllerDelegate {
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
		var selectedImageFromPicker: UIImage?
		if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
			selectedImageFromPicker = editedImage
			
		} else if let orginalImage = info[UIImagePickerControllerOriginalImage]  as? UIImage {
			selectedImageFromPicker = orginalImage
		}
		
		if let selectedImage = selectedImageFromPicker {
			self.registerImageToUser(selectedImage)
		}
		
		dismissViewControllerAnimated(true, completion: nil)
	}
}







