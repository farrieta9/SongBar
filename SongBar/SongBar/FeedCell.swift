//
//  FeedCell.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/19/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {

	
	@IBOutlet weak var donorLabel: UILabel!
	@IBOutlet weak var pictureView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var detailLabel: UILabel!
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		
		pictureView.layer.borderColor = UIColor.blackColor().CGColor
		pictureView.layer.cornerRadius = 15
		pictureView.layer.masksToBounds = true

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
