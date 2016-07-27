//
//  UserContentCell.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/14/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit

class ContentCell: UITableViewCell {

	@IBOutlet weak var pictureView: UIImageView!
	
	
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var detailLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		setUpCell()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func setUpCell() {
		pictureView.image = UIImage(named: "default_profile.png")
		
		pictureView.layer.borderColor = UIColor.blackColor().CGColor
		pictureView.layer.cornerRadius = pictureView.frame.width / 2
		pictureView.layer.masksToBounds = true
		
		detailLabel.font = UIFont.systemFontOfSize(13)
	}
	
	func setCell(title: String, detail: String, imageString: String) {
		titleLabel.text = title
		detailLabel.text = detail
		pictureView.loadImageUsingURLString(imageString)
		
	}

}
