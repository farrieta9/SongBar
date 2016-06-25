//
//  SearchMusicTableCell.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/7/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit


class SearchMusicTableCell: UITableViewCell {
	
	var subTitle = "" {
		didSet {
			subLabel.text = subTitle
		}
	}
	
	var title = "" {
		didSet {
			titleLabel.text = title
		}
	}
	
	@IBOutlet weak var albumImageView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subLabel: UILabel!
	
	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

	}
	
	func getGreenColor() -> UIColor{
		// Green is used when it is a positive price
		return UIColor(red: 1.0/255.0, green: 216.0/255.0, blue: 106.0/255.0, alpha: 1.0)
	}

}
