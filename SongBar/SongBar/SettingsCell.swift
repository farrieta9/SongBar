//
//  SettingsCell.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/8/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit

class SettingsCell: UICollectionViewCell {

	@IBOutlet weak var optionLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		// Initialization code
		optionLabel.font = UIFont.systemFontOfSize(16)
    }

}
