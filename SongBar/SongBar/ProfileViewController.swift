//
//  LoginViewController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/13/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//


import UIKit
import Firebase

let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
let distance_W_LabelHeader:CGFloat = 30.0 // The distance between the top of the screen and the top of the White Label


enum contentTypes {
	case Audience, Follow
}

class ProfileViewController: UIViewController {
	
	// MARK: Outlet properties
	
	@IBOutlet var tableView : UITableView!
	@IBOutlet var headerView : UIView!
	@IBOutlet var profileView : UIView!
	@IBOutlet var segmentedView : UIView!
	@IBOutlet var avatarImage:UIImageView!
	@IBOutlet var handleLabel : UILabel!
	@IBOutlet var headerLabel : UILabel!
	@IBOutlet weak var userTagLabel: UILabel!
	var audienceData = [String]()
	var followData = [String]()
	
	var data = ["iPad", "iPhone", "iWatch", "iPod", "iMac"]
	var buttonData = ["US","China","London","Canada","Japan"];
	
	
	var headerImageView:UIImageView!
	var contentToDisplay: contentTypes = .Audience
	let userDefaults = NSUserDefaults.standardUserDefaults()
	
	let actionButtonWidth: CGFloat = 100.0
	let actionButtonHeight:CGFloat = 30.0
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.contentInset = UIEdgeInsetsMake(headerView.frame.height, 0, 0, 0)
		
		// Get the audience
		FIRDatabase.database().reference().child("users/users_by_name/\(Utilities.getCurrentUsername())/audience_by_id").observeEventType(.Value, withBlock: {(snapshot) in
//			print(snapshot)
			guard let results = snapshot.value as? [String: [String: String]] else {
				print("getting the audience failed")
				return
			}
			
//			print(results)
			for person in results.keys {
				self.audienceData.append(person)
			}
//			print(self.audienceData)
			
			self.tableView.reloadData()
		})
		
		FIRDatabase.database().reference().child("users/users_by_name/\(Utilities.getCurrentUsername())/friends_by_id").observeEventType(.Value, withBlock: {(snapshot) in
		
			print(snapshot)
			guard let results = snapshot.value as? [String: [String: String]] else {
				print("getting friends failed") // Perhaps there are no results
				return
			}
			print(results)
			for person in results.keys {
				self.followData.append(person)
			}
			self.tableView.reloadData()
		})
		
	}
	
	override func viewDidAppear(animated: Bool) {
		
		// Header - Image
		
		headerImageView = UIImageView(frame: headerView.bounds)
		headerImageView?.image = UIImage(named: "Music-Concert-Crowd")
		headerImageView?.contentMode = UIViewContentMode.ScaleAspectFill
		headerView.insertSubview(headerImageView, belowSubview: headerLabel)
		headerView.clipsToBounds = true
		
		userTagLabel.text = FIRAuth.auth()?.currentUser?.displayName  // TODO: Have the userTag have a @ at the beginning
		
	}
	
	@IBAction func onSignOut(sender: UIButton) {
		print("Sign out")
		do {
			try	FIRAuth.auth()?.signOut()
		} catch let error {
			print(error)
		}
		resetCurrentUser()
		
	}
	
	func resetCurrentUser() {
		userDefaults.setValue("", forKey: "email")
		userDefaults.setValue("", forKey: "password")
	}
	
	// MARK: Table view processing
	
	
	
	@IBAction func onSelectContentType(sender: UISegmentedControl) {
		
		switch sender.selectedSegmentIndex {
		case 0:
			contentToDisplay = .Audience
		case 1:
			contentToDisplay = .Follow
		default:
			break
		}
		
		tableView.reloadData()
	}
	
	@IBAction func shamelessActionThatNowBringsYouToDeansTwitterProfile() {
		
//		if !UIApplication.sharedApplication().openURL(NSURL(string:"twitter://user?screen_name=deanbrindley87")!){
//			UIApplication.sharedApplication().openURL(NSURL(string:"https://twitter.com/deanbrindley87")!)
//		}
		print("Follow button pressed")
	}
	
	//Button Action is
	func buttonPressed(sender:UIButton!)
	{
		print("oh yeha")
		let buttonRow = sender.tag
		print("button is Pressed")
		print("Clicked Button Row is", buttonRow)
	}
	
}



extension ProfileViewController: UITableViewDataSource {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		switch contentToDisplay {
		case .Audience:
			return audienceData.count
			
		case .Follow:
			return followData.count
		}
		
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = UITableViewCell()

		
		switch contentToDisplay {
		case .Audience:
			cell.textLabel?.text = audienceData[indexPath.row]
			
		case .Follow:
			cell.imageView?.image = UIImage(named: "default_profile.png")
			cell.textLabel?.text = followData[indexPath.row]
		}
		
		return cell
		
//		let label = UILabel(frame: CGRectMake(280.0, 14.0, 100.0, 30.0))
//		label.text = data[indexPath.row]
//		label.tag = indexPath.row
//		cell.contentView.addSubview(label)
//		
//		let btn = UIButton(type: UIButtonType.Custom) as UIButton
//		btn.backgroundColor = UIColor.greenColor()
//		btn.setTitle(buttonData[indexPath.row], forState: UIControlState.Normal)
//		btn.frame = CGRectMake(20, 5, 30, 30)
//		btn.addTarget(self, action: #selector(buttonPressed(_:)), forControlEvents: .TouchUpInside)
//		btn.tag = indexPath.row
//		cell.contentView.addSubview(btn)
		
//		let usernameLabel = UILabel(frame: CGRectMake(75, 5, 100, 30))
//		let actionButton = UIButton(type: .Custom)
//		
//		actionButton.frame = CGRectMake(tableView.frame.width - actionButtonWidth - 15, 5, actionButtonWidth, actionButtonHeight)
//
//		usernameLabel.tag = indexPath.row
//		actionButton.tag = indexPath.row
//		
//		actionButton.setTitle("Follow", forState: .Normal)
//		
//		
//		switch contentToDisplay {
//		case .Audience:
//			usernameLabel.text = audienceData[indexPath.row]
//		case .Follow:
//			usernameLabel.text = followData[indexPath.row]
//		}
//		actionButton.layer.cornerRadius = 15
//		actionButton.layer.borderWidth = 1
//		actionButton.layer.borderColor = UIColor.blackColor().CGColor
//		actionButton.backgroundColor = UIColor.blueColor()
//		
//		cell.contentView.addSubview(usernameLabel)
//		cell.contentView.addSubview(actionButton)
//		
//		return cell
	}
	
}

extension ProfileViewController: UIScrollViewDelegate {
	// MARK: Scroll view delegate
	
	func scrollViewDidScroll(scrollView: UIScrollView) {
		
		let offset = scrollView.contentOffset.y + headerView.bounds.height
		
		var avatarTransform = CATransform3DIdentity
		var headerTransform = CATransform3DIdentity
		
		// PULL DOWN -----------------
		
		if offset < 0 {
			
			let headerScaleFactor:CGFloat = -(offset) / headerView.bounds.height
			let headerSizevariation = ((headerView.bounds.height * (1.0 + headerScaleFactor)) - headerView.bounds.height)/2
			headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
			headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
			
			
			// Hide views if scrolled super fast
			headerView.layer.zPosition = 0
			headerLabel.hidden = true
			
		}
			
			// SCROLL UP/DOWN ------------
			
		else {
			
			// Header -----------
			
			headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
			
			//  ------------ Label
			
			headerLabel.hidden = false
			let alignToNameLabel = -offset + handleLabel.frame.origin.y + headerView.frame.height + offset_HeaderStop
			
			headerLabel.frame.origin = CGPointMake(headerLabel.frame.origin.x, max(alignToNameLabel, distance_W_LabelHeader + offset_HeaderStop))
			
			// Avatar -----------
			
			let avatarScaleFactor = (min(offset_HeaderStop, offset)) / avatarImage.bounds.height / 1.4 // Slow down the animation
			let avatarSizeVariation = ((avatarImage.bounds.height * (1.0 + avatarScaleFactor)) - avatarImage.bounds.height) / 2.0
			avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
			avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)
			
			if offset <= offset_HeaderStop {
				
				if avatarImage.layer.zPosition < headerView.layer.zPosition{
					headerView.layer.zPosition = 0
					headerImageView.alpha = 1.0
				}
				
				
			}else {
				if avatarImage.layer.zPosition >= headerView.layer.zPosition{
					headerView.layer.zPosition = 2
					headerImageView.alpha = 0.5
				}
			}
		}
		
		// Apply Transformations
		headerView.layer.transform = headerTransform
		avatarImage.layer.transform = avatarTransform
		
		// Segment control
		
		let segmentViewOffset = profileView.frame.height - segmentedView.frame.height - offset
		
		var segmentTransform = CATransform3DIdentity
		
		// Scroll the segment view until its offset reaches the same offset at which the header stopped shrinking
		segmentTransform = CATransform3DTranslate(segmentTransform, 0, max(segmentViewOffset, -offset_HeaderStop), 0)
		
		segmentedView.layer.transform = segmentTransform
		
		
		// Set scroll view insets just underneath the segment control
		tableView.scrollIndicatorInsets = UIEdgeInsetsMake(segmentedView.frame.maxY, 0, 0, 0)
		
		
		
	}

}













