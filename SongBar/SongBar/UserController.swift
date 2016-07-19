//
//  UserController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/14/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase

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
	var postsData = [SpotifyTrack]()
	var contentOptions: ContentOptions = .Posts
	var selectedIndexPath: NSIndexPath?
	var displayedUser: User?
	
	lazy var settingsLauncher: SettingsLauncher = {
		let launcher = SettingsLauncher()
		launcher.userController = self
		return launcher
	}()
	
	@IBAction func handleSettings(sender: UIBarButtonItem) {
		settingsLauncher.showSettings()
	}
	
	@IBAction func handleProfileActionButton(sender: UIButton) {
		print(123)
		
//		guard let user = displayedUser else {
//						return
//					}
//			
//					if sender.titleLabel?.text == "+ Follow" {
//						followUser(user)
//						sender.backgroundColor = UIColor.greenColor()
//						sender.setTitle("Following", forState: .Normal)
//					} else {
//						unFollowUser(user)
//						sender.backgroundColor = UIColor.blackColor()
//						sender.setTitle("+ Follow", forState: .Normal)
//					}
		guard let user = displayedUser else {
			return
		}
		
		if sender.titleLabel?.text == "+ Follow" {
			followUser(user)
			sender.backgroundColor = UIColor.greenColor()
			sender.setTitle("Following", forState: .Normal)
		}
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
		fetchFollowing()
		fetchFans()
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
//		if segue.identifier == "userControllerID" {
//			let vc = segue.destinationViewController as! UserController
//			guard let indexPath = selectedIndexPath else {
//				return  // Have not selected a cell
//			}
//			var user = User()
//			switch contentOptions {
//			case .Fans:
//				user = fansData[indexPath.row]
//			case .Following:
//				user = followingData[indexPath.row]
//			default:
//				return
//			}
////			vc.displayedUser = user
//		}
		if segue.identifier == "userControllerID" {
			let vc = segue.destinationViewController as! UserController
			guard let indexPath = selectedIndexPath else {
				return
			}
			let selectedUser = followingData[indexPath.row]
			vc.displayedUser = selectedUser
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
						self.fansData.append(user)
					}
					
					}, withCancelBlock: nil)
			}
			
			dispatch_async(dispatch_get_main_queue(), {
				self.tableView.reloadData()
			})
			
			}, withCancelBlock: nil)
	}
	
	func fetchFollowing() {
		guard let uid = displayedUser?.uid else {
			return
		}
		
		FIRDatabase.database().reference().child("users_by_id/\(uid)/Following").observeEventType(.Value, withBlock: { (snapshot) in
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
						self.followingData.append(user)
					}
					
					}, withCancelBlock: nil)
			}
			
			dispatch_async(dispatch_get_main_queue(), { 
				self.tableView.reloadData()
			})
			
			}, withCancelBlock: nil)
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
		segmentControl.setTitle("Post", forSegmentAtIndex: 0)
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
			return cell
		case .Fans:
			cell.titleLabel.text = fansData[indexPath.row].username
			cell.detailLabel.text = fansData[indexPath.row].fullname
			cell.pictureView.loadImageUsingURLString(fansData[indexPath.row].imageString!)
		case .Following:
			cell.titleLabel.text = followingData[indexPath.row].username
			cell.detailLabel.text = followingData[indexPath.row].fullname
			cell.pictureView.loadImageUsingURLString(followingData[indexPath.row].imageString!)
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







