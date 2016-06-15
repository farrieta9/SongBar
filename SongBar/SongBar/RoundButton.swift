//
//  RoundButton.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/14/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit

class RoundButton: UIButton {
	
	override func awakeFromNib() {
		
		self.layer.cornerRadius = 5.0
		self.layer.borderWidth = 1.0
		self.layer.borderColor = UIColor(red: 85.0/255.0, green: 172.0/255.0, blue: 238.0/255.0, alpha: 1.0).CGColor
		
	}
	
}
