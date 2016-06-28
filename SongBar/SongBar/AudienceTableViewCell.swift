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
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
