//
//  UserHeaderTableViewCell.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/25/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit

class UserHeaderTableViewCell: UITableViewCell {

	@IBOutlet weak var avatarImage: UIImageView!
	
	@IBOutlet weak var titleLabel: UILabel!
	
	@IBOutlet weak var subLabel: UILabel!
	
	@IBOutlet weak var actionButton: UIButton!
	
	
	var title = "" {
		didSet {
			titleLabel.text = title
		}
	}
	
	var subTitle = "" {
		didSet {
			subLabel.text = subTitle
		}
	}
	
	var actionName = "Unnamed" {
		didSet {
			actionButton.setTitle(actionName, forState: .Normal)
		}
	}
	
	var avatar: UIImage! {
		didSet {
			avatarImage.image = avatar
		}
	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		avatar = UIImage(named: "default_profile.png")
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
