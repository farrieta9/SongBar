//
//  HomeViewController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/7/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase


class HomeViewController: UIViewController {
	
	var rootRef: FIRDatabaseReference!
	var collectionData = [(String, String, String)]()
	@IBOutlet weak var collectionView: UICollectionView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		print(FIRAuth.auth()?.currentUser)
		collectionView.backgroundColor = UIColor.clearColor()
		rootRef = FIRDatabase.database().reference()
		dispatch_async(dispatch_get_main_queue()){
			self.rootRef.queryOrderedByKey().observeEventType(.ChildAdded, withBlock: { (snapshot) in
				let postDict = snapshot.value as! [String : String]
				let title = postDict["title"]! as String
				let artist = postDict["artist"]! as String
				let imageURL = postDict["imageURL"]! as String
				self.collectionData.insert((artist, title, imageURL), atIndex: 0)
				self.collectionView.reloadData()
			})
		}
		
	}
	
	func getColor(red: Float, green: Float, blue: Float) -> UIColor {
		let r: CGFloat = CGFloat(red) / 255.0
		let g: CGFloat = CGFloat(green) / 255.0
		let b: CGFloat = CGFloat(blue) / 255.0
		return UIColor(red: r, green: g, blue: b, alpha: 1.0)
	}
}

extension HomeViewController: UICollectionViewDataSource{
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return collectionData.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! HomeCollectionCell
		
		cell.artist = collectionData[indexPath.row].0
		cell.song = collectionData[indexPath.row].1
		cell.backgroundColor = getColor(242, green: 226, blue: 205)
		
		let imageURL = collectionData[indexPath.row].2
		let url = NSURL(string: imageURL)
		let session = NSURLSession.sharedSession().dataTaskWithURL(url!) {
			(data, response, error) in
			if data != nil {
				dispatch_async(dispatch_get_main_queue(), {
					cell.albumImageView?.image = UIImage(data: data!)
				})
			}
		}
		session.resume()
		return cell
	}
}

extension HomeViewController: UICollectionViewDelegate {
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		print("Selected cell: \(indexPath.row)")
	}
}