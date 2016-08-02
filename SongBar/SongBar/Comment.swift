//
//  Comment.swift
//  SongBar
//
//  Created by Francisco Arrieta on 8/1/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import Foundation

class Comment: NSObject {
	var user: User?
	var comment: String = ""
	var timestamp: String = ""
	
	override init() {
		self.comment = ""
		self.timestamp = ""
	}
	
	init(user: User, comment: String, timestamp: String) {
		self.user = user
		self.comment = comment
		self.timestamp = timestamp
	}
}