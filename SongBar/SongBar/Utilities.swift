//
//  Utilities.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/17/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import Foundation
import UIKit
import Firebase

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
	
	static func getDate(daysAgo: Int = 4) -> String{
		//        Source http://stackoverflow.com/questions/26942123/nsdate-of-yesterday
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "YYYY-MM-dd"
		let calendar = NSCalendar.currentCalendar()
		let yesterday = calendar.dateByAddingUnit(.Day, value: -daysAgo, toDate: NSDate(), options: []) // value -1 is yesterday, -2 is two days ago and so on.
		let oneDayAgo = dateFormatter.stringFromDate(yesterday!)
		return oneDayAgo
	}
	
	static func unFollow(username: String) -> Void {
		// Unfriends/unfollow the user. Changes appear on the current user and the user that is being removed.
		print("Unfollow \(username)")
		FIRDatabase.database().reference().child("users/users_by_name/\(Utilities.getCurrentUsername())/friends_by_id/\(username)").removeValue()
		
		FIRDatabase.database().reference().child("users/users_by_name/\(username)/audience_by_id/\(Utilities.getCurrentUsername())").removeValue()
	}
	
	static func followUser(username: String) {
		// Sets current user to follow this selected/shown user
		FIRDatabase.database().reference().child("users/users_by_name/\(username)").observeEventType(.Value, withBlock: {(snapshot) in
			guard let uid = snapshot.value!["uid"] as? String else {
				print("AnyUserViewController.followUser() failed")
				return
			}
			
			FIRDatabase.database().reference().child("users/users_by_name/\(Utilities.getCurrentUsername())/friends_by_id/\(username)").setValue([uid: username])
			FIRDatabase.database().reference().child("users/users_by_name/\(username)/audience_by_id/\(Utilities.getCurrentUsername())").setValue([Utilities.getCurrentUID(): Utilities.getCurrentUsername()])
		})
	}
	
	
	static func getDateTime() -> String {
		let currentDate = NSDate()
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "MMM dd, yyyy zzz HH:mm:ss"

		
		let date = dateFormatter.stringFromDate(currentDate)
		print("Date: \(date)")

		
		return date
	}
	
	static func getServerTime() -> String {
		let date = NSDate()
		let dateFormatter = NSDateFormatter()
		
		dateFormatter.dateFormat = "MMM dd, yyyy zzz HH:mm:ss"
		dateFormatter.timeZone = NSTimeZone(name: "MT")
		
		let stringDate = dateFormatter.stringFromDate(date)
		
		return stringDate
	}
	
	
	static func getGreenColor() -> UIColor{
		return UIColor(red: 1.0/255.0, green: 216.0/255.0, blue: 106.0/255.0, alpha: 1.0)
	}
	
	static func resetCurrentUser() {
		userDefaults.setValue("", forKey: "email")
		userDefaults.setValue("", forKey: "password")
		userDefaults.setValue("", forKey: "uid")
		userDefaults.setValue("", forKey: "username")
	}
}





















