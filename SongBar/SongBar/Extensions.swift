//
//  Extensions.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/9/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit


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

let imageCache = NSCache()
extension UIImageView {
	func loadImageUsingCacheWithURLString(urlString: String) {
		
//		image = nil
		if let cachedImage = imageCache.objectForKey(urlString) as? UIImage {
			self.image = cachedImage
			return
		}
		let url = NSURL(string: urlString)
			NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, response, error) in
			if error != nil {
				print(error)
				return
			}
			
			dispatch_async(dispatch_get_main_queue(), {
				
				if let downloadedImage = UIImage(data: data!) {
					imageCache.setObject(downloadedImage, forKey: urlString)
					self.image = downloadedImage
				}
			})
		}.resume()
	}
}