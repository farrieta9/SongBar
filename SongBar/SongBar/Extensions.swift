//
//  Extensions.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/13/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit

extension UIColor {
	static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
		return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
	}
}

extension UIView {
	func addConstraintsWithFormat(format: String, views: UIView...) {
		var viewsDictionary = [String: UIView]()
		for (index, view) in views.enumerate() {
			let key = "v\(index)"
			view.translatesAutoresizingMaskIntoConstraints = false
			viewsDictionary[key] = view
		}
		
		addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
	}
}

let imageCache = NSCache()  // Rename to cachedImages
extension UIImageView {
	func loadImageUsingURLString(urlString: String) {
		let url = NSURL(string: urlString)
		
		image = nil
		image = UIImage(named: "default_profile.png")
		
		if let imageFromCache = imageCache.objectForKey(urlString) as? UIImage {
			self.image = imageFromCache
			return
		}
		
		if urlString == "" {
			return // has no image in firebase
		}
		
		NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) in
			if error != nil {
				print(error)
				return
			}
			dispatch_async(dispatch_get_main_queue(), {
				
				let imageToCache = UIImage(data: data!)
				
				imageCache.setObject(imageToCache!, forKey: urlString)
				
				self.image = imageToCache
			})
		}.resume()
	}
}

extension UIViewController {
	func hideKeyboardWhenTappedAround() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
		view.addGestureRecognizer(tap)
	}
	
	func dismissKeyboard() {
		view.endEditing(true)
	}
}

extension UIButton {
	func applyGraidentToButton() {
		let colors = [UIColor.rgb(60, green: 148, blue: 139).CGColor,
		              UIColor.rgb(225, green: 227, blue: 228).CGColor]
		
		let gradient: CAGradientLayer = CAGradientLayer()
		gradient.colors = colors
		gradient.frame = self.bounds
		self.clipsToBounds = true
		
		// Make gradient horizontal
		gradient.startPoint = CGPointMake(0.0, 0.5)
		gradient.endPoint = CGPointMake(1.0, 0.5)
		
		self.layer.insertSublayer(gradient, atIndex: 0)
	}
}


extension NSDate {
	
	func getElapsedInterval() -> String {
		
		var interval = NSCalendar.currentCalendar().components(.Year, fromDate: self, toDate: NSDate(), options: []).year
		
		if interval > 0 {
			return interval == 1 ? "\(interval)" + " " + "year" :
				"\(interval)" + "yr ago"
		}
		
		interval = NSCalendar.currentCalendar().components(.Month, fromDate: self, toDate: NSDate(), options: []).month
		if interval > 0 {
			return interval == 1 ? "\(interval)" + " " + "month" :
				"\(interval)" + "m"
		}
		
		interval = NSCalendar.currentCalendar().components(.Day, fromDate: self, toDate: NSDate(), options: []).day
		if interval > 0 {
			return interval == 1 ? "\(interval)" + " " + "day" :
				"\(interval)" + "d"
		}
		
		interval = NSCalendar.currentCalendar().components(.Hour, fromDate: self, toDate: NSDate(), options: []).hour
		if interval > 0 {
			return interval == 1 ? "\(interval)" + " " + "hour" :
				"\(interval)" + "h"
		}
		
		interval = NSCalendar.currentCalendar().components(.Minute, fromDate: self, toDate: NSDate(), options: []).minute
		if interval > 0 {
			return interval == 1 ? "\(interval)" + " " + "minute" :
				"\(interval)" + " min"
		}
		
		return "a moment ago"
	}
}