//
//  AudienceTableViewCell.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/26/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit

class AudienceTableViewCell: UITableViewCell {
	@IBOutlet weak var userImage: UIImageView!
	@IBOutlet weak var subTitleLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var actionButton: UIButton!
	
	var avatar: UIImage! {
		didSet {
			userImage.image = avatar
		}
	}
	
	var title = "" {
		didSet {
			titleLabel.text = title
		}
	}
	
	var subTitle = "" {
		didSet {
			subTitleLabel.text = subTitle
		}
	}

    override func awakeFromNib() {
        super.awakeFromNib()
		// Initialization code
		actionButton.setTitle("", forState: .Normal)
		actionButton.backgroundColor = UIColor.clearColor()
		actionButton.layer.cornerRadius = actionButton.frame.size.width / 3
		actionButton.layer.borderWidth = 1
		actionButton.layer.borderColor = UIColor.blackColor().CGColor
		actionButton.backgroundColor = UIColor.clearColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
