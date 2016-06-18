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

	@IBOutlet weak var logOutButton: UIButton!
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
		logOutButton.setTitle("Log Out", forState: .Normal)
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









