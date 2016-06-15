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
	case Tweets, Media
}

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
	
	// MARK: Outlet properties
	
	@IBOutlet var tableView : UITableView!
	@IBOutlet var headerView : UIView!
	@IBOutlet var profileView : UIView!
	@IBOutlet var segmentedView : UIView!
	@IBOutlet var avatarImage:UIImageView!
	@IBOutlet var handleLabel : UILabel!
	@IBOutlet var headerLabel : UILabel!
	@IBOutlet weak var userTagLabel: UILabel!
	
	
	var headerImageView:UIImageView!
	var contentToDisplay : contentTypes = .Tweets
	let userDefaults = NSUserDefaults.standardUserDefaults()
	// MARK: The view
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.contentInset = UIEdgeInsetsMake(headerView.frame.height, 0, 0, 0)
		
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
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		switch contentToDisplay {
		case .Tweets:
			return 40
			
		case .Media:
			return 20
		}
		
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		
		
		switch contentToDisplay {
		case .Tweets:
			cell.textLabel?.text = "Cool stuff!!"
			
		case .Media:
			cell.textLabel?.text = "Some texts!"
			cell.imageView?.image = UIImage(named: "Music-Concert-Crowd")
		}
		
		
		
		return cell
	}
	
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
	
	// MARK: Interface buttons
	
	@IBAction func selectContentType(sender: UISegmentedControl) {
		
		// crap code I know
		if sender.selectedSegmentIndex == 0 {
			contentToDisplay = .Tweets
		}
		else {
			contentToDisplay = .Media
		}
		
		tableView.reloadData()
	}
	
	
	@IBAction func shamelessActionThatNowBringsYouToDeansTwitterProfile() {
		
//		if !UIApplication.sharedApplication().openURL(NSURL(string:"twitter://user?screen_name=deanbrindley87")!){
//			UIApplication.sharedApplication().openURL(NSURL(string:"https://twitter.com/deanbrindley87")!)
//		}
		print("Follow button pressed")
	}
	
}

