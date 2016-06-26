//
//  UserTableViewCell.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/25/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
	@IBOutlet weak var avatarImage: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subTitleLabel: UILabel!
	
	var avatar: UIImage! {
		didSet {
			avatarImage.image = avatar
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
