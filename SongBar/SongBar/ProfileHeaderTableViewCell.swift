//
//  ProfileHeaderTableViewCell.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/18/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase

class ProfileHeaderTableViewCell: UITableViewCell {

	@IBOutlet weak var userImageView: UIImageView!
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var segmentController: UISegmentedControl!
	
	var username = "" {
		didSet {
			usernameLabel.text = username
		}
	}
	
	var userImage = UIImage(named: "default_profile.png") {
		didSet {
			userImageView.image = userImage
		}
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
		setUpImage()
    }
	
	func setUpSegmentControl() {
		segmentController.setTitle("Fans", forSegmentAtIndex: 0)
		segmentController.setTitle("Following", forSegmentAtIndex: 1)
		segmentController.setTitle("Posts", forSegmentAtIndex: 2)
	}
	
	func setUpImage() {
		setUpSegmentControl()
		retrieveUserImage()
		
		userImageView.layer.cornerRadius = 10.0
		userImageView.layer.borderColor = UIColor.whiteColor().CGColor
		userImageView.layer.borderWidth = 3.0
		userImageView.layer.masksToBounds = true
		userImageView.clipsToBounds	= true
		userImageView.contentMode = .ScaleAspectFill
	}

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

	@IBAction func onActionButton(sender: UIButton) {
		print("Logged out")
		do {
			try FIRAuth.auth()?.signOut()
		} catch let error {
			print(error)
		}
		Utilities.resetCurrentUser()
	}
	
	
	func retrieveUserImage() {
		let profileImageURL = Utilities.getProfileImageURL()
		
		if profileImageURL == "" {
			return  // No image is stored
		}
		
		let url = NSURL(string: profileImageURL)
		NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
			if error != nil {
				print(error)  // Failed to download
				return
			}
			// Image downloaded successfully
			dispatch_async(dispatch_get_main_queue(), {
				self.userImage = UIImage(data: data!)
			})
			
		}).resume()
	}
}










