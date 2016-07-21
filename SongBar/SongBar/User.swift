//
//  User.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/13/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase

class User: NSObject {
	var email: String?
	var fullname: String?
	var username: String?
	var uid: String?
	var imageString: String?
	
	override init() {
		self.email = CurrentUser.email
		self.fullname = CurrentUser.fullname
		self.username = CurrentUser.username
		self.uid = CurrentUser.uid
		self.imageString = CurrentUser.imageString
	}
	
	init(email: String, fullname: String, username: String, uid: String) {
		self.email = email
		self.fullname = fullname
		self.username = username
		self.uid = uid
	}
	
	init(email: String, fullname: String, username: String, uid: String, image: String) {
		self.email = email
		self.fullname = fullname
		self.username = username
		self.uid = uid
		self.imageString = image
	}
}


class CurrentUser {
	static var email: String?
	static var fullname: String?
	static var username: String?
	static var uid: String?
	static var imageString: String?
	
	static let sharedInstance = CurrentUser()
	static let userDefaults = NSUserDefaults.standardUserDefaults()
	
	// Private methods
	private init () {}
	
	
	// Static methods
	static func getUID() -> String {
		guard let uid = userDefaults.stringForKey("uid") else {
			return "" // No uid is stored
		}
		return uid
	}
	
	static func getEmail() -> String {
		guard let email = userDefaults.stringForKey("email") else {
			return "" // No email is stored
		}
		return email
	}
	
	static func getPassword() -> String {
		guard let password = userDefaults.stringForKey("password") else {
			return "" // No password is stored
		}
		return password
	}

	static func getServerTime() -> String {
		let date = NSDate()
		let dateFormatter = NSDateFormatter()
		
		dateFormatter.dateFormat = "MMM dd, yyyy zzz HH:mm:ss"
		dateFormatter.timeZone = NSTimeZone(name: "MT")
		
		let stringDate = dateFormatter.stringFromDate(date)
		
		return stringDate
	}
	
	static func resetUser() {
		userDefaults.setValue("", forKey: "email")
		userDefaults.setValue("", forKey: "password")
		userDefaults.setValue("", forKey: "uid")
		userDefaults.setValue("", forKey: "username")
		email = ""
		username = ""
		fullname = ""
		uid = ""
	}
	
	static func storeUser(uid: String, email: String, password: String) {
		userDefaults.setValue(email, forKey: "email")
		userDefaults.setValue(uid, forKey: "uid")
		userDefaults.setValue(password, forKey: "password")
		
		self.email = email
		self.uid = uid
	}
	
	static func signOutAndReset() {
		signOut()
		resetUser()
	}
	
	static func signOut() {
		do {
			try FIRAuth.auth()?.signOut()
		} catch let error {
			print(error)
		}
	}
	
}