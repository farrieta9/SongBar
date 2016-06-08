//
//  HomeCollectionCell.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/7/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit


class HomeCollectionCell: UICollectionViewCell {
	
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
	
	@IBOutlet weak var albumImageView: UIImageView!
	@IBOutlet weak var artistLabel: UILabel!
	@IBOutlet weak var songLabel: UILabel!
}