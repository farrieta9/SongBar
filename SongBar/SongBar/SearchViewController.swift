//
//  SearchMusicViewController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/7/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation


class SearchViewController: UIViewController {
	
	var tableData = [SpotifyTrack]()
	var peopleData = [String]()
	var rootRef: FIRDatabaseReference!
	var selectedRow = 0
	var timer: NSTimer? = nil
	var selectedIndexPath: NSIndexPath? = nil
	var indicator = UIActivityIndicatorView()
	var searchContent: SearchContentType = .Music
	var searchBar: UISearchBar!
	var audioPlay : AVPlayer!
	
	
	enum SearchContentType {
		case Music
		case People
	}
	
	@IBOutlet weak var searchOptionsSeg: UISegmentedControl!
	@IBOutlet weak var tableView: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		activityIndicator()
		createSearchBar()
		rootRef = FIRDatabase.database().reference()
		audioPlay = AVPlayer()
    }
	
	func createSearchBar() {
		searchBar = UISearchBar()
		searchBar.showsCancelButton = false
		searchBar.placeholder = "Enter for music here"
		searchBar.delegate = self
		self.navigationItem.titleView = searchBar
	}
	
	func activityIndicator() {
		indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
		indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
		indicator.center = self.view.center
		indicator.clipsToBounds = true
		self.view.addSubview(indicator)
	}
	
	@IBAction func onSearchOptionIndexChange(sender: UISegmentedControl) {
		
		switch searchOptionsSeg.selectedSegmentIndex {
		case 0:
			searchContent = .Music
			searchBar.placeholder = "Enter for music here"
		case 1:
			searchContent = .People
			searchBar.placeholder = "Enter for people here"
		default:
			break
		}
		
		clearTable()
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "anyUserVC" {
			let userVC = segue.destinationViewController as! AnyUserViewController
			userVC.username = peopleData[selectedRow]
			return
		}
		
		if segue.identifier	== "audienceVC" {
			let vc = segue.destinationViewController as! AudienceViewController
			print("Show audience")
			vc.track = tableData[selectedRow]
		}
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
		searchBar.showsCancelButton = true
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
		searchBar.showsCancelButton = false
	}
	
	func searchBarCancelButtonClicked(searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		searchBar.text = ""
		searchBar.showsCancelButton = false
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
			cell.title = tableData[indexPath.row].title
			cell.subTitle = tableData[indexPath.row].artist
			
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
			cell.albumImageView.image = UIImage(named: "default_profile.png")
			cell.title = peopleData[indexPath.row]
			cell.subTitle = ""  // Load the persons first and last name here
			
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
		selectedRow = indexPath.row
		searchBar.resignFirstResponder()
		switch searchContent {
		case .Music:
			performSegueWithIdentifier("audienceVC", sender: self)
		case .People:
			performSegueWithIdentifier("anyUserVC", sender: self)
		}
	}
	
	func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
		let stopAction = UITableViewRowAction(style: .Normal, title: "Stop") { action, index in
			self.audioPlay.pause()
		}
		let shareAction = UITableViewRowAction(style: .Normal, title: "Share") { action, index in
			self.performSegueWithIdentifier("audienceVC", sender: self)
		}
		
		stopAction.backgroundColor = UIColor.lightGrayColor()
		shareAction.backgroundColor = Utilities.getColor(46, green: 129, blue: 183)
		return [shareAction, stopAction]
	}
	
	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// the cells you would like the actions to appear needs to be editable
//		let cell = tableView.cellForRowAtIndexPath(indexPath)
		switch searchContent {
		case .Music:
			return true
		default:
			return false
		}
	}
	
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		// you need to implement this method too or you can't swipe to display the actions
	}
	
	func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
		// Stop playing the audio when row is selected
		self.audioPlay.pause()
	}
	
	func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
		switch searchContent {
		case .Music:
			let url = NSURL(string: self.tableData[indexPath.row].previewUrl)
			self.audioPlay = AVPlayer(URL: url!)
			self.audioPlay.play()
		default:
			return
		}
	}
}




