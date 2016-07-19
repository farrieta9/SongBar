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
	
	enum ContentOptions {
		case Posts, Fans, Following
	}
	
	var followingData = [User]()
	var fansData = [User]()
	var postsData = [SpotifyTrack]()
	var contentOptions: ContentOptions = .Posts
	
	var username: String?
	var fullname: String?
	var uid: String?
	var headerImageAsString: String?
	var displayedUser: User?
	var selectedIndexPath: NSIndexPath?
	var shouldHideActionButton: Bool = true
	
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
		guard let user = displayedUser else {
			return
		}
		print(user)
		
		if sender.titleLabel?.text == "+ Follow" {
			followUser(user)
			sender.backgroundColor = UIColor.greenColor()
			sender.setTitle("Following", forState: .Normal)
		} else {
			unFollowUser(user)
			sender.backgroundColor = UIColor.blackColor()
			sender.setTitle("+ Follow", forState: .Normal)
		}
	}
	
	func setUpProfileActionButton() {
		guard let uid = displayedUser?.uid, signedInUsersId = CurrentUser.uid else {
			return
		}
		FIRDatabase.database().reference().child("users_by_id/\(signedInUsersId)/Following/\(uid)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
			if snapshot.value is NSNull {
				self.profileActionButton.setTitle("+ Follow", forState: .Normal)
				self.profileActionButton.backgroundColor = UIColor.clearColor()
			} else {
				self.profileActionButton.setTitle("Following", forState: .Normal)
				self.profileActionButton.backgroundColor = UIColor.greenColor()
			}
	
			}, withCancelBlock: nil)
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
		setUpView()
		setUpProfile()
	}
	
	func setUpView() {
		profileView.backgroundColor = UIColor.clearColor()
		segmentControl.setTitle("Posts", forSegmentAtIndex: 0)
		segmentControl.setTitle("Fans", forSegmentAtIndex: 1)
		segmentControl.insertSegmentWithTitle("Following", atIndex: 2, animated: false)
	}
	
	func fetchFollowing() {
		guard let signedInUsersId = CurrentUser.uid else {
			return
		}
		FIRDatabase.database().reference().child("users_by_id/\(signedInUsersId)/Following").observeEventType(.Value, withBlock: { (snapshot) in
			guard let results = snapshot.value as? [String: [String: String]] else {
				return
			}
	
			for (key, value) in results {
	
				let user = User(email: value["email"]!, fullname: value["fullname"]!, username: value["username"]!, uid: key, image: value["imageURL"]!)
				self.followingData.append(user)
			}
			
			dispatch_async(dispatch_get_main_queue(), {
				self.tableView.reloadData()
			})

			}, withCancelBlock: nil)
	}
	
	func setUpProfile() {
		if displayedUser != nil {
			username = displayedUser?.username
			fullname = displayedUser?.fullname
			uid = displayedUser?.uid
			shouldHideActionButton = false
		} else {
			// Display the user that is signed in
			username = CurrentUser.username
			fullname = CurrentUser.fullname
			uid = CurrentUser.uid
			shouldHideActionButton = true
		}
		
		profileActionButton.hidden = shouldHideActionButton
		profileUsernameLabel.text = username
		profileFullnameLabel.text = fullname

		fetchFollowing()
		setUpProfileActionButton()
		fetchDisplayedUsersImage()
	}
	
	func followUser(user: User) {
		guard let signedInUsersId = CurrentUser.uid, signedInUsersUsername = CurrentUser.username, signedInUsersFullname = CurrentUser.fullname, signedInUsersEmail = CurrentUser.email else {
			return // CurrentUser.uid has not been set
		}
		
		guard let name = user.username, email = user.email, uid = user.uid, fname = user.fullname else {
			return
		}
		
		var value = ["username": name, "email": email, "fullname": fname, "imageURL": user.imageString!]
		FIRDatabase.database().reference().child("users_by_id/\(signedInUsersId)").child("Following").child(uid).updateChildValues(value)
		
		value = ["username": signedInUsersUsername, "email": signedInUsersEmail, "fullname": signedInUsersFullname, "imageURL": CurrentUser.imageString!]
		FIRDatabase.database().reference().child("users_by_id/\(uid)").child("Fans").child(signedInUsersId).updateChildValues(value)
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
			FIRDatabase.database().reference().child("users_by_name/\(name)").updateChildValues(["imageURL": imageURL])
			FIRDatabase.database().reference().child("users_by_id/\(userID)").updateChildValues(["imageURL": imageURL])
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
				return  // Have not selected a cell
			}
			var user = User()
			switch contentOptions {
			case .Fans:
				user = fansData[indexPath.row]
			case .Following:
				user = followingData[indexPath.row]
			default:
				return
			}
			
			//			let user = tempUsers[indexPath.row]
			vc.displayedUser = user
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
	
	func fetchDisplayedUsersImage() {
		guard let name = username else {
			return // username has not been set
		}
		
		FIRDatabase.database().reference().child("users_by_name/\(name)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
			if let result = snapshot.value as? [String: AnyObject] {
				guard let urlString = result["imageURL"] as? String else {
					return // Has no set image
				}
				CurrentUser.imageString = urlString
				self.profileImageView.loadImageUsingURLString(urlString)
			}
			
			}, withCancelBlock: nil)
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
		cell.backgroundColor = UIColor.greenColor()
		
		switch contentOptions {
		case .Posts:
			return cell
		case .Fans:
			cell.titleLabel.text = fansData[indexPath.row].username
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
//
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









