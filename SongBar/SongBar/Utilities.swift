//
//  Utilities.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/17/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import Foundation


// Functions that may come in handy.
class Utilities {
	
	
	static let userDefaults = NSUserDefaults.standardUserDefaults()
	
	
	static func getCurrentUsername() -> String {
		if let username = userDefaults.stringForKey("username") {
			return username
		}
		return ""
	}
	
	static func getCurrentUID() -> String {
		if let uid = userDefaults.stringForKey("uid") {
			return uid
		}
		return ""
	}
	
	static func resetCurrentUser() {
		userDefaults.setValue("", forKey: "email")
		userDefaults.setValue("", forKey: "password")
		userDefaults.setValue("", forKey: "uid")
	}
}





















