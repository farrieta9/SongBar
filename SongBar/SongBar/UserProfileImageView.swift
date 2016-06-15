//
//  UserProfileImageView.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/14/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit

class UserProfileImageView: UIImageView {
	
	override func awakeFromNib() {
		self.layer.cornerRadius = 10.0
		self.layer.borderColor = UIColor.whiteColor().CGColor
		self.layer.borderWidth = 3.0
	}
}
