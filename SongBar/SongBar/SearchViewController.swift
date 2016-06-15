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
			
			FIRDatabase.database().reference().queryOrderedByKey().observeEventType(.Value, withBlock: {(snapshot) in
				
				print(snapshot.value!["users"])
				let users = snapshot.value!["users"]
				print(users)
				
				
				
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
		return tableData.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! SearchMusicTableCell
		
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








