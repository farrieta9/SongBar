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
	
	enum contentTypes {
		case Audience, Follow
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

//		To have a circular image, uncomment this line below with the following two lines
//		userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
		userImageView.layer.cornerRadius = 10.0
		userImageView.layer.borderColor = UIColor.whiteColor().CGColor
		userImageView.layer.borderWidth = 3.0
		userImageView.clipsToBounds	= true  // Makes the corners blend with the corner radius
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
}










