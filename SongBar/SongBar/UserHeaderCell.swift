//
//  UserHeaderCell.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/14/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase

class UserHeaderCell: UITableViewCell {
	@IBOutlet weak var fullnameLabel: UILabel!
	@IBOutlet weak var userImageView: UIImageView!
	
	@IBOutlet weak var usernameLabel: UILabel!
	
	@IBOutlet weak var actionButton: UIButton!
		
	override func awakeFromNib() {
        super.awakeFromNib()
		
		actionButton.backgroundColor = UIColor.clearColor()
		actionButton.layer.cornerRadius = 15
		actionButton.layer.borderWidth = 1
		actionButton.layer.borderColor = UIColor.blackColor().CGColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
