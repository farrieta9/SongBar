//
//  UserContentOptionsCell.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/14/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit

class UserContentOptionsCell: UITableViewCell {

	
	@IBOutlet weak var segmentControl: UISegmentedControl!
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
	
		segmentControl.setTitle("Posts", forSegmentAtIndex: 0)
		segmentControl.setTitle("Fans", forSegmentAtIndex: 1)
		segmentControl.insertSegmentWithTitle("Following", atIndex: 2, animated: true)
		
	}
	
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
