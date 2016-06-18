//
//  ProfileHeaderTableViewCell.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/18/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit

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
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
