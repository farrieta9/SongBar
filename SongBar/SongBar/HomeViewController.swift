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
	var collectionData = [(String, String, String, String, String)]() // artist, song, imageURL, previewURL, host
	@IBOutlet weak var collectionView: UICollectionView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		print(FIRAuth.auth()?.currentUser)
		collectionView.backgroundColor = UIColor.clearColor()
		rootRef = FIRDatabase.database().reference()

		// Only show songs that have been received.
		FIRDatabase.database().reference().child("users/users_by_name/\(Utilities.getCurrentUsername())/received").observeEventType(.Value, withBlock: {(snapshot) in
			self.collectionData.removeAll()
			
			if snapshot.value is NSNull {
				print("Have not received any songs")
				// Add a message suggesting them to share a song
				return
			} else {
				guard let results = snapshot.value as? [String: [String: String]] else {
					print("HomeViewController.viewDidLoad() failed")
					return
				}
				for item in results {
					// Guard just in case of anything bugs
					guard let artist = item.1["artist"],
					let title = item.1["title"],
					let imageURL = item.1["imageURL"],
					let previewURL = item.1["previewURL"],
					let host = item.1["host"] else {
						print("HomeViewController.viewDidLoad() failed while parsing data ")
						return
					}
//					let data = (artist, title, imageURL, previewURL, host)
					self.collectionData.insert((artist, title, imageURL, previewURL, host), atIndex: self.collectionData.endIndex)
				}
				dispatch_async(dispatch_get_main_queue()) { [unowned self] in
					self.collectionView.reloadData()
				}
			}
			
		})
		Utilities.getServerTime()
		
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