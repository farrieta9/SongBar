//
//  SearchController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/16/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase

class SearchController: UIViewController {


	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var segmentControl: UISegmentedControl!
	
	var searchBar: UISearchBar!
	var indicator = UIActivityIndicatorView()
	var timer: NSTimer? = nil
	var peopleData = [User]()
	var spotifyData = [SpotifyTrack]()
	var searchContent: SearchContentType = .Music
	var selectedIndexPath: NSIndexPath?
	
	@IBAction func onSegmentConrol(sender: UISegmentedControl) {
		
		switch segmentControl.selectedSegmentIndex {
		case 0:
			searchContent = .Music
			searchBar.placeholder = "Enter for music here"
		case 1:
			searchContent = .People
			searchBar.placeholder = "Enter for people here"
		default:
			break
		}
		
		dispatch_async(dispatch_get_main_queue()) { 
			self.tableView.reloadData()
		}
	}
	
	enum SearchContentType {
		case Music
		case People
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		setUpView()
    }
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "userControllerID" {
			let vc = segue.destinationViewController as! UserController
			guard let indexPath = selectedIndexPath else {
				return  // Have not selected a cell
			}
			let selectedUser = peopleData[indexPath.row]
			vc.displayedUser = selectedUser
		}
	}
	
	func setUpView() {
		tableView.delegate = self
		tableView.dataSource = self
		createSearchBarInNavigationBar()
		activityIndicator()
		segmentControl.setTitle("Music", forSegmentAtIndex: 0)
		segmentControl.setTitle("People", forSegmentAtIndex: 1)
	}
	
	func activityIndicator() {
		indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
		indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
		indicator.center = self.view.center
		indicator.clipsToBounds = true
		self.view.addSubview(indicator)
	}
	
	func createSearchBarInNavigationBar() {
		searchBar = UISearchBar()
		searchBar.showsCancelButton = false
		searchBar.placeholder = "Search for music here"
		searchBar.delegate = self
		searchBar.autocorrectionType = .No
		searchBar.autocapitalizationType = .None
		self.navigationItem.titleView = searchBar
	}
	
	private func searchForMusic(searchText: String) -> Void {
		SpotifyAPI.search(searchText) {
			(tracks) in dispatch_async(dispatch_get_main_queue()) {
				self.spotifyData = tracks
				self.tableView.reloadData()
			}
		}
	}
	
	private func searchForPeople(searchText: String) {
		FIRDatabase.database().reference().child("users_by_name").queryOrderedByKey().queryStartingAtValue(searchText.lowercaseString).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
		
			self.peopleData.removeAll()
			if let result = snapshot.value as? [String: [String: String]] {
				
				let signedInUser = CurrentUser.username

				for person in result.values {
					if signedInUser != person["username"] {
						
						guard let email = person["email"], fullname = person["fullname"], username = person["username"], uid = person["uid"] else {
							return // Person is missing one of these variables
						}
						
						let user = User(email: email, fullname: fullname, username: username, uid: uid)
						if let imageString = person["imageURL"] {
							user.imageString = imageString
						}
						
						self.peopleData.append(user)
					}
				}
				dispatch_async(dispatch_get_main_queue()) {
					self.tableView.reloadData()
				}
			}
			
			}, withCancelBlock: nil)
	}
	
	
	func clearTable() -> Void {
		peopleData.removeAll()
		spotifyData.removeAll()
		dispatch_async(dispatch_get_main_queue()) {
			self.tableView.reloadData()
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
		
		switch searchContent {
		case .Music:
			searchForMusic(text)
		case .People:
			searchForPeople(text)
		}
	}
}

extension SearchController: UITableViewDataSource {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch searchContent {
		case .Music:
			return spotifyData.count
		case .People:
			return peopleData.count
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ContentCell
		
		switch searchContent {
		case .Music:
			cell.titleLabel.text = spotifyData[indexPath.row].title
			cell.detailLabel.text = spotifyData[indexPath.row].artist
			cell.pictureView.loadImageUsingURLString(spotifyData[indexPath.row].imageUrl)
		case .People:
			cell.titleLabel.text = peopleData[indexPath.row].username
			cell.detailLabel.text = peopleData[indexPath.row].fullname
			
			if let imageString = peopleData[indexPath.row].imageString {
				cell.pictureView.loadImageUsingURLString(imageString)
			}
			
		}
		return cell
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 76
	}
	
	
	func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
		selectedIndexPath = indexPath
		return indexPath
	}
}

extension SearchController: UITableViewDelegate {
	
}

extension SearchController: UISearchBarDelegate {
	
	func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
		indicator.startAnimating()
		indicator.backgroundColor = UIColor.whiteColor()
		timer?.invalidate()
		timer = NSTimer.scheduledTimerWithTimeInterval(0.75, target: self, selector: #selector(self.searchBarTextDidPause(_:)), userInfo: searchBar.text, repeats: false)
		
		return true
	}

	func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
		searchBar.showsCancelButton = true
	}
	
	func searchBarCancelButtonClicked(searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		searchBar.showsCancelButton = false
		searchBar.text = ""
	}
	
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		searchBar.showsCancelButton = true
	}
}
