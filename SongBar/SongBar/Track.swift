//
//  Track.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/27/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import Foundation

class Track {
	
	var title: String
	var artist: String
	var previewUrl: String
	var imageUrl: String
	var donor: String = ""
	var date: String = ""
	var commentReference: String = ""
	init(artist: String, title: String, previewURL: String, imageURL: String) {
		self.title = title
		self.artist = artist
		self.previewUrl = previewURL
		self.imageUrl = imageURL
	}
}