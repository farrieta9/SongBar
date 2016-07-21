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
			return // has not image in firebase
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


extension UIViewController{
	func addToolBar(){
		let toolBar = UIToolbar()
		toolBar.barStyle = UIBarStyle.Default
		toolBar.translucent = true
		toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
		
		var items = [UIBarButtonItem]()
		
//		let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(UIViewController.donePressed))
//		let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(UIViewController.cancelPressed))
		let playButton = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: #selector(self.handlePlay))
		let titleItem = UIBarButtonItem(title: "The quick brown fox jumps over the lazy dog", style: .Plain, target: nil, action: nil)
		let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
		let stopButton = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: #selector(self.handleStop))
		
		
		items.append(playButton)
		items.append(titleItem)
		items.append(flexSpace)
		items.append(stopButton)
		
//		toolBar.setItems([cancelButton, flexSpace, doneButton], animated: false)
		toolBar.setItems(items, animated: false)
		toolBar.userInteractionEnabled = true
//		toolBar.sizeToFit()
//		toolBar.center.x = self.view.frame.width / 2
//		print(self.navigationController?.navigationBar.frame.height)
//		toolBar.center.y = view.frame.height - 70
		toolBar.translatesAutoresizingMaskIntoConstraints = false
//		toolBar.rightAnchor.constraintEqualToAnchor(self.view.rightAnchor).active = true
//		toolBar.centerYAnchor.constraintEqualToAnchor(self.view.centerYAnchor).active = true
//		toolBar.widthAnchor.constraintEqualToConstant(100).active = true
//		toolBar.heightAnchor.constraintEqualToConstant(300).active = true
		self.view.addSubview(toolBar)
		
//		toolBar.addConstraint(NSLayoutConstraint.constraintsWithVisualFormat("H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": toolBar]))
//		toolBar.addConstraint(NSLayoutConstraint.constraintsWithVisualFormat("", options: NSLayoutFormatOptions, metrics: nil, views: ["v0": toolBar]))
		
//		NSLayoutConstraint(item: toolBar, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0).active = true
//		NSLayoutConstraint(item: toolBar, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0).active = true
		
		let horizontalConstraint = toolBar.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor)
//		let verticalConstraint = toolBar.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor)
//		let verticalConstraint = toolBar.centerYAnchor.constraintEqualToAnchor(view.bottomAnchor)
		let verticalConstraint = toolBar.centerYAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -70)
//		let bottomConstraint = NSLayoutConstraint(item: toolBar, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
//		let verticalConstraint = NSLayoutConstraint(item: toolBar, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 100)
		

//		let widthConstraint = toolBar.widthAnchor.constraintEqualToAnchor(nil, constant: view.frame.width)
		let widthConstraint = toolBar.widthAnchor.constraintEqualToAnchor(view.widthAnchor)
		let heightConstraint = toolBar.heightAnchor.constraintEqualToAnchor(nil, constant: 45)
		NSLayoutConstraint.activateConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])

	}
	
	func handleStop() {
		print("handleStop()")
	}
	
	func handlePlay() {
		print("handlePlay")
	}

	func donePressed(){
		print(123)
	}
	func cancelPressed(){
		print(456)
	}
}
//

//extension UIViewController {
//	func addToolBar() {
//		let toolbar = UIToolbar()
//		toolbar.barStyle = .Default
//		toolbar.translucent = true
//	}
//}











