//
//  SearchMusicViewController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/7/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase


class SearchMusicViewController: UIViewController {
	
	var tableData = [SpotifyTrack]()
	var rootRef: FIRDatabaseReference!

	@IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

		rootRef = FIRDatabase.database().reference()

    }
}

extension SearchMusicViewController: UISearchBarDelegate {
	func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
		SpotifyAPI.search(searchText) {
			(tracks) in dispatch_async(dispatch_get_main_queue()) {
				self.tableData = tracks
				self.tableView.reloadData()
			}
		}
	}
}


extension SearchMusicViewController: UITableViewDataSource {
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

extension SearchMusicViewController: UITableViewDelegate {
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let ref = rootRef.childByAutoId()
		let data = ["artist": tableData[indexPath.row].artist, "title": tableData[indexPath.row].title,
		            "imageURL": tableData[indexPath.row].imageUrl, "previewURL": tableData[indexPath.row].previewUrl]

		ref.setValue(data)
		view.endEditing(true)  // Hide keyboard
	}
}








