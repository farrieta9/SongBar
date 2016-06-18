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
			selectedTag = 0
		case 1:
			selectedTag = 1
		default:
			selectedTag = 0
		}
		tableData = []
		peopleData = []
		self.tableView.reloadData()
	}
	
	func clearTable() -> Void {
		tableData = []
		peopleData = []
		tableView.reloadData()
	}
	
	func searchForPeople(searchText: String) -> Void {
		self.peopleData = []
		FIRDatabase.database().reference().child("users/users_by_name").queryOrderedByKey().queryStartingAtValue(searchText.lowercaseString).observeSingleEventOfType(.Value, withBlock: {(snapshot) in
		
			if let searchResults = snapshot.value as? [String: [String: String]] {
				for person in searchResults.keys {
					self.peopleData.append(person)
				}
				
				self.tableData = []
				self.tableView.reloadData()
			} else {
				print(snapshot)
				return  // snapshot may be null. Nothing found
			}
		})
	}
	
	func searchForMusic(searchText: String) -> Void {
		SpotifyAPI.search(searchText) {
			(tracks) in dispatch_async(dispatch_get_main_queue()) {
				self.tableData = tracks
				self.tableView.reloadData()
			}
		}
	}
}

extension SearchViewController: UISearchBarDelegate {
	func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
		print(searchText)
		if searchText.characters.count == 0 {
			self.clearTable()
			return
		}
		if selectedTag == 0 {
			searchForMusic(searchText)
			return
		}
		
		if selectedTag == 1 {
			searchForPeople(searchText)
			return
		}
	}
	
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		if selectedTag == 0 {
			searchForMusic(searchBar.text!)
			return
		}
		if selectedTag == 1 {
			searchForPeople(searchBar.text!)
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
		
		if self.tableData.count != 0 {
			cell.artist = tableData[indexPath.row].artist
			cell.song = tableData[indexPath.row].title
			cell.username = ""
			
			// Download the image then loaded it
			let imageUrl = tableData[indexPath.row].imageUrl
			let url = NSURL(string: imageUrl)
			let session = NSURLSession.sharedSession().dataTaskWithURL(url!) {
				(data, response, error) in
				if data != nil {
					dispatch_async(dispatch_get_main_queue(), {
						cell.albumImageView.image = UIImage(data: data!)
					})
				}
			}
			session.resume()
		} else {
			cell.artist = ""
			cell.username = peopleData[indexPath.row]
			cell.song = ""
			cell.albumImageView.image = UIImage(named: "default_profile.png")
			
		}
		
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








