//
//  BaseCell.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/14/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit

class BaseCell: UICollectionViewCell {
	override init(frame: CGRect) {
		super.init(frame: frame)
		setUpViews()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setUpViews() {
		// Ment to be overwritten
	}
}
