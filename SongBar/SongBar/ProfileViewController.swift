//
//  Profile2ViewController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/18/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UINavigationControllerDelegate {
	
	
	@IBOutlet weak var tableView: UITableView!
	private let tableHeaderHeight: CGFloat = 100.0
	private let tableHeaderCutAway: CGFloat = 0.0
	
	private var headerView: ProfileHeaderView!
	private var headerMaskLayer: CAShapeLayer!
	
	enum contentTypes {
		case Fans, Following, Posts
	}
	
	var contentToDisplay: contentTypes = .Fans
	var following = [User]()
	var fans = [User]()
	var songBook = [Track]()
	let imageOptions: [String] = ["Take a photo", "From library"]
	let imageOptionsCellHeight: CGFloat = 50
	lazy var settingsLauncher: SettingsLauncher = {
		let launcher = SettingsLauncher()
		launcher.profileController = self
		return launcher
	}()
	
	var headerCell: ProfileHeaderTableViewCell?
	var audienceProfileImages = [String]()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		headerView = tableView.tableHeaderView as! ProfileHeaderView
		tableView.tableHeaderView = nil  // Clear out the default header
		tableView.addSubview(headerView) // Add header
		
		tableView.contentInset = UIEdgeInsets(top: tableHeaderHeight, left: 0, bottom: 0, right: 0)
		tableView.contentOffset = CGPoint(x: 0, y: -tableHeaderHeight)
		
		headerMaskLayer = CAShapeLayer()
		headerMaskLayer.fillColor = UIColor.blackColor().CGColor
		
		headerView.layer.mask = headerMaskLayer
		
		updateHeaderView()
		
		loadFans()
		loadFollowing()
		loadPosts()
    }
	
	
	func loadFans() {
		FIRDatabase.database().reference().child("users/users_by_name/\(Utilities.getCurrentUsername())/audience_by_id").observeEventType(.Value, withBlock: {(snapshot) in
			self.fans.removeAll()

			if snapshot.value is NSNull {
				print("No audience")
			} else {
				guard let results = snapshot.value as? [String: [String: String]] else {
					print("getting the audience failed")
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
			}
			
			dispatch_async(dispatch_get_main_queue()) { [unowned self] in
				self.tableView.reloadData()
			}
		})
	}
	
	func loadPosts() {
		FIRDatabase.database().reference().child("users/users_by_name/\(Utilities.getCurrentUsername())/songs_for_fans").queryOrderedByKey().observeEventType(.Value, withBlock: {(snapshot) in
			self.songBook.removeAll()
			
			if snapshot.value is NSNull {
				print("you have not shared anything yet")
				return
			} else {
				guard let results = snapshot.value as? [String: [String: String]] else {
					print("refreshPosts() failed")
					return
				}
				for (_, value) in results.sort({$0.0.compare($1.0) == NSComparisonResult.OrderedDescending}) {  // Sort by date while looping
					
					let track = Track(artist: value["artist"]!, title: value["title"]!, previewURL: value["previewURL"]!, imageURL: value["imageURL"]!)
					
					self.songBook.append(track)
				}
				
				dispatch_async(dispatch_get_main_queue()) { [unowned self] in
					self.tableView.reloadData()
				}
			}
		})
	}
	
	func loadFollowing() {
		FIRDatabase.database().reference().child("users/users_by_name/\(Utilities.getCurrentUsername())/friends_by_id").observeEventType(.Value, withBlock: {(snapshot) in
			self.following.removeAll()

			if snapshot.value is NSNull {
				print("No one you follow")
			} else {
				guard let results = snapshot.value as? [String: [String: String]] else {
					print("getting friends failed") // Perhaps there are no results
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
			}
			
			dispatch_async(dispatch_get_main_queue()) { [unowned self] in
				self.tableView.reloadData()
			}
		})
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		updateHeaderView()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		updateHeaderView()
	}
	
	@IBAction func onContentDisplayChange(sender: UISegmentedControl) {
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
		dispatch_async(dispatch_get_main_queue()) { 
			self.tableView.reloadData()
		}
	}
	
	@IBAction func onActionButton(sender: UIButton) {
		var selectedUser: String = ""
		switch contentToDisplay {
		case .Following:
			selectedUser = following[sender.tag].username
			Utilities.unFollow(selectedUser)
			sender.backgroundColor = UIColor.clearColor()
		case .Fans:
			if sender.titleLabel?.text! == "+ Follow" {
				Utilities.followUser(fans[sender.tag].username)
				sender.setTitle("Following", forState: .Normal)
				sender.backgroundColor = Utilities.getGreenColor()
			} else {
				Utilities.unFollow(fans[sender.tag].username)
				sender.setTitle("+ Follow", forState: .Normal)
				sender.backgroundColor = UIColor.clearColor()
			}
		default:
			return  // Do nothing
		}
	}
	@IBAction func onSettings(sender: UIBarButtonItem) {
		handleSettings()
	}
	
	
	func handleSettings() {
		settingsLauncher.showSettings()
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
	
	func signOut() {
		Utilities.signOut()
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	func updateHeaderView() {
		let effectiveHeight = tableHeaderHeight - tableHeaderCutAway / 2
		var headerRect = CGRect(x: 0, y: -effectiveHeight, width: tableView.bounds.width, height: tableHeaderHeight)
		
		if tableView.contentOffset.y < -effectiveHeight {
			headerRect.origin.y = tableView.contentOffset.y
			headerRect.size.height = -tableView.contentOffset.y + tableHeaderCutAway / 2
		}
		
		headerView.frame = headerRect
		
		// Cut away
		let path = UIBezierPath()
		path.moveToPoint(CGPoint(x: 0, y: 0))
		path.addLineToPoint(CGPoint(x: headerRect.width, y: 0))
		path.addLineToPoint(CGPoint(x: headerRect.width, y: headerRect.height))
		
		path.addLineToPoint(CGPoint(x: 0, y:headerRect.height - tableHeaderCutAway))
		
		headerMaskLayer?.path = path.CGPath
	}
	
	func uploadImageToFirebase(image: UIImage) {
		guard let uploadData = UIImageJPEGRepresentation((headerCell?.userImage)!, 0.1) else {
			return
		}
		
		FIRStorage.storage().reference().child("profile_images/\(Utilities.getCurrentUID())").putData(uploadData, metadata: nil) { (metadata, error) in
			if error != nil {
				print(error)
				return
			}
			
			guard let profileImageURL = metadata?.downloadURL()?.absoluteString else {
				return
			}
			self.registerImageToUser(profileImageURL)
			self.storeProfileImageURL(profileImageURL)
		}
	}
	
	func registerImageToUser(imageURL: String) {
		FIRDatabase.database().reference().child("users/users_by_name/\(Utilities.getCurrentUsername())").updateChildValues(["profileImageURL": imageURL])
	}
	
	func storeProfileImageURL(url: String) {
		NSUserDefaults.standardUserDefaults().setValue(url, forKey: "profileImageURL")
	}
}


extension ProfileViewController: UITableViewDataSource	{
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 1 {
			switch contentToDisplay {
			case .Fans:
				return fans.count
			case .Following:
				return following.count
			case .Posts:
				return songBook.count
			}
		}
		return 1
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		if indexPath.section == 1 {
			let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! ProfileTableViewCell
			
			switch contentToDisplay {
			case .Fans:
				cell.username = fans[indexPath.row].username
				cell.actionButton.hidden = false
				cell.subTitle = ""
				Utilities.isFollowing(cell.actionButton, username: cell.username)
				cell.userImage = UIImage(named: "default_profile.png")
				
				let profileImageURLAsString = fans[indexPath.row].profileImageURL
				
				if profileImageURLAsString != "" {
					cell.userImageView.loadImageUsingCacheWithURLString(profileImageURLAsString)
				}
				
			case .Following:
				cell.subTitle = ""
				cell.username = following[indexPath.row].username
				cell.actionButton.hidden = false
				cell.actionButton.backgroundColor = Utilities.getGreenColor()
				cell.actionName = "Following"
				cell.userImage = UIImage(named: "default_profile.png")
				
				let profileImageURLAsString = following[indexPath.row].profileImageURL
				if profileImageURLAsString != "" {
					cell.userImageView.loadImageUsingCacheWithURLString(profileImageURLAsString)
				}
				
			case .Posts:
				cell.username = songBook[indexPath.row].title
				cell.actionButton.hidden = true
				cell.subTitle = songBook[indexPath.row].artist
				cell.userImageView.loadImageUsingCacheWithURLString(songBook[indexPath.row].imageUrl)
			}
			cell.actionButton.tag = indexPath.row
			
			return cell

		} else {
			let cell = tableView.dequeueReusableCellWithIdentifier("headerCell") as! ProfileHeaderTableViewCell
			cell.username = Utilities.getCurrentUsername()
			headerCell = cell
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

extension ProfileViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(scrollView: UIScrollView) {
		updateHeaderView()
	}
}

extension ProfileViewController: UIImagePickerControllerDelegate {
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
		var selectedImageFromPicker: UIImage?
		if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
			selectedImageFromPicker = editedImage
			
		} else if let orginalImage = info[UIImagePickerControllerOriginalImage]  as? UIImage {
			selectedImageFromPicker = orginalImage
		}
		
		if let selectedImage = selectedImageFromPicker {
			headerCell?.userImage = selectedImage // Make sure selctedImageFromPicker is not nil
			uploadImageToFirebase((headerCell?.userImage)!)
		}
		dismissViewControllerAnimated(true, completion: nil)
	}
}












