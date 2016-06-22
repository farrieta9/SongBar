//
//  Profile2TableViewCell.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/18/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit


class ProfileTableViewCell: UITableViewCell {

	@IBOutlet weak var userImageView: UIImageView!
	@IBOutlet weak var userNameLabel: UILabel!
	@IBOutlet weak var actionButton: UIButton!
	@IBOutlet weak var artistLabel: UILabel!
	@IBOutlet weak var songLabel: UILabel!
	
	var username = "" {
		didSet {
			userNameLabel.text = username
		}
	}
	
	var userImage = UIImage(named: "default_profile.png") {
		didSet {
			userImageView.image = userImage
		}
	}
	
	var song = "" {
		didSet {
			songLabel.text = song
		}
	}
	
	var artist = "" {
		didSet {
			artistLabel.text = artist
		}
	}
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
		songLabel.hidden = true
		artistLabel.hidden = true
		
        // Initialization code
		actionButton.setTitle("Follow", forState: .Normal)
		actionButton.backgroundColor = UIColor.clearColor()
		actionButton.layer.cornerRadius = 15
		actionButton.layer.borderWidth = 1
		actionButton.layer.borderColor = UIColor.blackColor().CGColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
