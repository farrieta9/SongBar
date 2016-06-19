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
	var timer: NSTimer? = nil
	var selectedIndexPath: NSIndexPath? = nil
	var indicator = UIActivityIndicatorView()
	var searchContent: SearchContentType = .Music
	
	enum SearchContentType {
		case Music
		case People
	}

	@IBOutlet weak var searchOptionsSeg: UISegmentedControl!
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
		searchBar.delegate = self
		
		activityIndicator()
		
		
		rootRef = FIRDatabase.database().reference()

    }
	
	func activityIndicator() {
		indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
		indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
		indicator.center = self.view.center
		self.view.addSubview(indicator)
	}
	
	@IBAction func onSearchOptionIndexChange(sender: UISegmentedControl) {
		
		switch searchOptionsSeg.selectedSegmentIndex {
		case 0:
			searchContent = .Music
		case 1:
			searchContent = .People
		default:
			break
		}
		
		clearTable()
	}
	
	func clearTable() -> Void {
		tableData = []
		peopleData = []
		tableView.reloadData()
	}
	
	func searchForPeople(searchText: String) -> Void {
		self.peopleData = []
		FIRDatabase.database().reference().child("users/users_by_name").queryOrderedByKey().queryStartingAtValue(searchText.lowercaseString).observeSingleEventOfType(.Value, withBlock: {(snapshot) in
		
			if let searchResults = snapshot.value as? [String: AnyObject] {
				
				let currentUsername = Utilities.getCurrentUsername()
				for person in searchResults.keys {
					if currentUsername != person {
						self.peopleData.append(person)  // Do not include the current user in the search results
					}
				}

				self.tableView.reloadData()
			} else {
				print(snapshot)
				print("Error")
				return  // snapshot may be null. Nothing found, or internet may be slow
			}
		})
	}
	
	func addSelectedRowAsFriend(row: Int) {
		let selectedUser = peopleData[row]
		let currentUsername = Utilities.getCurrentUsername()

		// Get the uid of the selected user
		FIRDatabase.database().reference().child("users/users_by_name/\(selectedUser)").observeSingleEventOfType(.Value, withBlock: {(snapshot) in
			if let uid = snapshot.value!["uid"] as? String {
				print(uid)

				// Add the data
				FIRDatabase.database().reference().child("users/users_by_name/\(currentUsername)").child("friends_by_id").child(selectedUser).setValue([uid: selectedUser])
				
				// Audience is your followers
				FIRDatabase.database().reference().child("users/users_by_name/\(selectedUser)").child("audience_by_id").child(currentUsername).setValue([Utilities.getCurrentUID(): currentUsername])
				
				let cell = self.tableView.cellForRowAtIndexPath(self.selectedIndexPath!) as! SearchMusicTableCell
				let color = cell.getGreenColor()
				cell.actionButton.backgroundColor = color
				
			} else {
				print(snapshot)
				print("addSelectedRowAsFriend() failed")
			}
		})
	}
	
	func shareSongWithAudience(row: Int) {
		
		print("share \(tableData[row]) song with everyone")
		let track = tableData[row]
		
		// Store all songs I have shared
		FIRDatabase.database().reference().child("users/users_by_name/\(Utilities.getCurrentUsername())/songs_for_audience").childByAutoId().setValue(["title": track.title, "artist": track.artist, "imageURL": track.imageUrl, "previewURL": track.previewUrl])
		
		// Send song to to all who are my audience
		// Get all friends of current user
		FIRDatabase.database().reference().child("users/users_by_name/\(Utilities.getCurrentUsername())/friends_by_id").observeSingleEventOfType(.Value, withBlock: {(snapshot) in
			if snapshot.value is NSNull {
				print("shareSongWithAudience(). No one you follow.")
				return
			} else {
				guard let results = snapshot.value as? [String: [String: String]] else {
					print("shareSongWithAudience(). Failed gettings friends")
					return
				}
				for person in results.keys {
					FIRDatabase.database().reference().child("users/users_by_name/\(person)/received").childByAutoId().setValue(["title": track.title, "artist": track.artist, "imageURL": track.imageUrl, "previewURL": track.previewUrl, "host": Utilities.getCurrentUsername()])
				}
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
	
	func searchBarTextDidPause(timer: NSTimer) {
		// Custom method
		guard let text = searchBar.text else {
			print("searchBarTextDidPause() failed")
			return
		}
		
		indicator.stopAnimating()
		indicator.hidesWhenStopped = true
		
		if text.characters.count == 0 {
			clearTable()
			return
		}
		
		switch searchOptionsSeg.selectedSegmentIndex {
		case 0:
			searchForMusic(text)
		case 1:
			searchForPeople(text)
		default:
			break
		}
	}

}

extension SearchViewController: UISearchBarDelegate {
	func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
		
		print(searchText)
	}
	
	func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		
		clearTable()
		indicator.startAnimating()
		indicator.backgroundColor = UIColor.whiteColor()
		print("started typing \(searchBar.text)")
		timer?.invalidate()
		timer = NSTimer.scheduledTimerWithTimeInterval(0.75, target: self, selector: (#selector(SearchViewController.searchBarTextDidPause(_:))), userInfo: searchBar.text, repeats: false)
		
		return true
	}
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
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
			cell.actionButton.hidden = true
			
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
			cell.actionButtonName = "+  Follow"
			cell.actionButton.hidden = false
			
		}
		
		return cell
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		switch searchOptionsSeg.selectedSegmentIndex {
		case 0:
			return 80
		case 1:
			return 50
		default:
			return 80
		}
	}
}

extension SearchViewController: UITableViewDelegate {
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		selectedIndexPath = indexPath
		searchBar.resignFirstResponder()
		switch searchContent {
		case .Music:
			shareSongWithAudience(indexPath.row)
		case .People:
			addSelectedRowAsFriend(indexPath.row)
		}
	}
}




