//
//  SettingsLauncher.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/9/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit

class Setting: NSObject {
	let name: String
	
	init(title: String) {
		self.name = title
	}
}

class SettingsLauncher: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	let blackView = UIView()
	let cellId = "cellId"
	
	let collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		cv.backgroundColor = UIColor.whiteColor()
		return cv
	}()
	
	let settings: [Setting] = {
		return [Setting(title: "Take a picture"), Setting(title: "Upload from library"), Setting(title: "Settings"), Setting(title: "Sign Out")]
	}()
	
	let cellHeight: CGFloat = 50
	
	var profileController: ProfileViewController?
	
	override init() {
		super.init()
		
		collectionView.dataSource = self
		collectionView.delegate	= self
		
		collectionView.registerClass(SettingsCell.self, forCellWithReuseIdentifier: cellId)
		
	}
	
	func showSettings() {
		if let window = UIApplication.sharedApplication().keyWindow {
			blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
			
			blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissSettings))
			)
			window.addSubview(blackView)
			window.addSubview(collectionView)
			
			let height: CGFloat = CGFloat(settings.count) * cellHeight
			let y = window.frame.height - height
			collectionView.frame = CGRectMake(0, window.frame.height, window.frame.width, height)
			
			blackView.frame = window.frame
			blackView.alpha = 0
			
			
			UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseInOut, animations: { 
				self.blackView.alpha = 1
				
				self.collectionView.frame = CGRectMake(0, y, self.collectionView.frame.width, self.collectionView.frame.height)
				}, completion: nil)
		}
	}
	
	func dismissSettings() {
		UIView.animateWithDuration(0.5) {
			self.blackView.alpha = 0
			if let window = UIApplication.sharedApplication().keyWindow {
				self.collectionView.frame = CGRectMake(0, window.frame.height, self.collectionView.frame.width, self.collectionView.frame.height)
			}
		}
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath) as! SettingsCell
		
		let setting = settings[indexPath.item]
		cell.setting = setting
		
		
		return cell
	}
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return settings.count
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		return CGSizeMake(collectionView.frame.width, cellHeight)
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
		return 0
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .CurveEaseOut, animations: { 
			self.blackView.alpha = 0
			if let window = UIApplication.sharedApplication().keyWindow {
				self.collectionView.frame = CGRectMake(0, window.frame.height, self.collectionView.frame.width, self.collectionView.frame.height)
			}
		}) { (completed: Bool) in
//			self.profileController
			let setting = self.settings[indexPath.item]
			if setting.name == "Upload from library" {
				self.profileController?.launchImagePicker(.PhotoLibrary)
				return
			}
			
			if setting.name == "Sign Out" {
				self.profileController?.signOut()
				
			}
			
			
		}
	}
}












