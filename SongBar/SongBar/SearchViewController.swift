//
//  SearchMusicViewController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/7/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase


class SearchViewController: UIViewController {
	
	var tableData = [SpotifyTrack]()
	var peopleData = [String]()
	var rootRef: FIRDatabaseReference!
	var selectedTag = 0

	@IBOutlet weak var searchOptionsSeg: UISegmentedControl!
	@IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

		rootRef = FIRDatabase.database().reference()

    }
	@IBAction func onSearchOptionIndexChange(sender: UISegmentedControl) {
		
		switch searchOptionsSeg.selectedSegmentIndex {
		case 0:
			print("Search for music")
			selectedTag = 0
		case 1:
			print("Search for people")
			selectedTag = 1
		default:
			break
		}
	}
}

extension SearchViewController: UISearchBarDelegate {
//	func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//		SpotifyAPI.search(searchText) {
//			(tracks) in dispatch_async(dispatch_get_main_queue()) {
//				self.tableData = tracks
//				self.tableView.reloadData()
//			}
//		}
//	}
	
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		print("search now")
		if selectedTag == 0 {
			print("searching for music")
			SpotifyAPI.search(searchBar.text!) {
				(tracks) in dispatch_async(dispatch_get_main_queue()) {
					self.tableData = tracks
					self.tableView.reloadData()
				}
			}
			return
		}
		if selectedTag == 1 {
			print("Searching for people")
			
//			ref.child("users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
			
//			FIRDatabase.database().reference().queryOrderedByKey().observeEventType(.ChildAdded, withBlock: {(snapshot) in
//			
//				print(snapshot)
//				if let postDict = snapshot.value as? [String: [String: String]] {
//					print(postDict)
//				} else {
//					print("failed")
//				}
//				
//			})
			
//			FIRDatabase.database().reference().queryOrderedByChild("users").observeSingleEventOfType(.Value, withBlock: {(snapshot) in
//				print(snapshot)
//				if let postDict = snapshot.value as? [String: AnyObject] {
//					print(postDict)
//					print(postDict["users"])
//				} else {
//					print("failed")
//				}
//
//			})

//			FIRDatabase.database().reference().child("users/users_by_name").queryOrderedByKey().observeSingleEventOfType(.Value, withBlock: {(snapshot) in
//				print(snapshot)
//			}) Works great!
			print(searchBar.text?.lowercaseString)
			FIRDatabase.database().reference().child("users/users_by_name").queryOrderedByKey().queryStartingAtValue(searchBar.text!.lowercaseString).observeSingleEventOfType(.Value, withBlock: {(snapshot) in
				print(snapshot)
				if let results = snapshot.value as? [String: [String: String]] {
					print(results)

					for person in results.keys {
						print(person)
						self.peopleData.append(person)
					}
					self.tableData = []
					self.tableView.reloadData()

				} else {
					print("failed")
				}
				
				
			})
			return
		}
	}
}


extension SearchViewController: UITableViewDataSource {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableData.count != 0 {
			return tableData.count
		} else {
			return peopleData.count
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! SearchMusicTableCell
		
		print("here i am")
		
		if self.tableData.count != 0 {
			cell.artist = tableData[indexPath.row].artist
			cell.song = tableData[indexPath.row].title
			
			// Download the image then loaded it
			let imageUrl = tableData[indexPath.row].imageUrl
			let url = NSURL(string: imageUrl)
			let session = NSURLSession.sharedSession().dataTaskWithURL(url!) {
				(data, response, error) in
				if data != nil {
					dispatch_async(dispatch_get_main_queue(), {
						cell.imageView?.image = UIImage(data: data!)
					})
				}
			}
			session.resume()
			
			return cell
		}
		
		cell.artist = peopleData[indexPath.row]
		print(peopleData[indexPath.row])
		print(cell.artist)
		return cell
		
		
	}
}

extension SearchViewController: UITableViewDelegate {
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let ref = rootRef.childByAutoId()
		let data = ["artist": tableData[indexPath.row].artist, "title": tableData[indexPath.row].title,
		            "imageURL": tableData[indexPath.row].imageUrl, "previewURL": tableData[indexPath.row].previewUrl]

		ref.setValue(data)
		view.endEditing(true)  // Hide keyboard
		if let uid = NSUserDefaults.standardUserDefaults().stringForKey("uid") {
			print(uid)
		}
	}
}








