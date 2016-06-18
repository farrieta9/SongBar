//
//  SearchMusicTableCell.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/7/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit


class SearchMusicTableCell: UITableViewCell {
	
	var artist = "" {
		didSet {
			artistLabel.text = artist
		}
	}
	
	var song = "" {
		didSet {
			songLabel.text = song
		}
	}
	
	var username = "" {
		didSet {
			usernameLabel.text = username
		}
	}
	
	var actionButtonName = "" {
		didSet {
			actionButton.setTitle(actionButtonName, forState: UIControlState.Normal)
		}
	}
	
	@IBOutlet weak var albumImageView: UIImageView!
	@IBOutlet weak var artistLabel: UILabel!
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var songLabel: UILabel!
	@IBOutlet weak var actionButton: UIButton!
	
	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		actionButton.backgroundColor = UIColor.clearColor()
		actionButton.layer.cornerRadius = 15
		actionButton.layer.borderWidth = 1
		actionButton.layer.borderColor = UIColor.blackColor().CGColor

	}
	
	func getGreenColor() -> UIColor{
		// Green is used when it is a positive price
		return UIColor(red: 1.0/255.0, green: 216.0/255.0, blue: 106.0/255.0, alpha: 1.0)
	}

}
