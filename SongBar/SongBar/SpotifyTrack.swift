//
//  SpotifyTrack.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/16/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import Foundation

class SpotifyTrack {
	
	var title = ""
	var artist = ""
	var previewUrl = ""
	var imageUrl = ""
	
	init(itemJSON: [String: AnyObject]) {
		
		guard let albumsObjectArray = itemJSON["album"] as? [String: AnyObject],
			let images = albumsObjectArray["images"] as? [[String: AnyObject]],
			let url = images.first?["url"] as? String
			else{
				print("Returned nothing ")
				return
		}
		self.imageUrl = url
		
		guard let title = itemJSON["name"] as? String
			else {
				return
		}
		self.title = title
		
		guard let artists = itemJSON["artists"] as? [[String: AnyObject]],
			let firstArtist = artists.first,
			let artist = firstArtist["name"] as? String
			else {
				return
		}
		
		self.artist = artist
		
		guard let previewUrl = itemJSON["preview_url"] as? String
			else {
				return
		}
		self.previewUrl = previewUrl
		
	}
	
}