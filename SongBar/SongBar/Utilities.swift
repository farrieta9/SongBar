//
//  Utilities.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/17/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import Foundation
import UIKit

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
	
	static func getDateTime() -> String {
//		// Returns the current date and time
//		let dateFormatter = NSDateFormatter()
////		dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
//
//		// Comparing time.
//		dateFormatter.dateFormat = "HH:mm:ss zzz"
//		var dateAsString = "14:28:16 GMT"
//		let date1 = dateFormatter.dateFromString(dateAsString)!
//		
//		dateAsString = "19:53:12 GMT"
//		let date2 = dateFormatter.dateFromString(dateAsString)!
//		
//		if date1.earlierDate(date2) == date1 {
//			if date1.isEqualToDate(date2) {
//				print("Same time")
//			}
//			else {
//				print("\(date1) is earlier than \(date2)")
//			}
//		}
//		else {
//			print("\(date2) is earlier than \(date1)")
//		}
		
//		let components = NSDateComponents()
//		let calendar = NSCalendar.currentCalendar()
//		components.day = 5
//		components.month = 01
//		components.year = 2016
//		components.hour = 19
//		components.minute = 30
////		var newDate = calendar.dateFromComponents(components)
//		components.timeZone = NSTimeZone(abbreviation: "MDT")
//		let newDate = calendar.dateFromComponents(components)
//		print(newDate)
		
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





















