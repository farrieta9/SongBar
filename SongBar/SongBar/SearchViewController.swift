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
//			
//			FIRDatabase.database().reference().child("users").queryOrderedByValue().queryEqualToValue("simmy").observeSingleEventOfType(.Value, withBlock: {(snapshot) in
//				print(snapshot)
//			})
			
//			var ref = new Firebase("https://dinosaur-facts.firebaseio.com/dinosaurs");
//			ref.orderByChild("height").on("child_added", function(snapshot) {
//				console.log(snapshot.key() + " was " + snapshot.val().height + " meters tall");
//				});
			
//			var scoresRef = new Firebase("https://dinosaur-facts.firebaseio.com/scores");
//			scoresRef.orderByValue().on("value", function(snapshot) {
//				snapshot.forEach(function(data) {
//					console.log("The " + data.key() + " dinosaur's score is " + data.val());
//					});
//				});
			
//			FIRDatabase.database().reference().child("users").queryOrderedByChild("username").observeSingleEventOfType(.Value, withBlock: {(snapshot) in
//				print(snapshot)
//			})
//			FIRDatabase.database().reference().queryOrderedByChild("users").queryStartingAtValue("simmy").observeSingleEventOfType(.Value, withBlock: {(snapshot) in
//				print(snapshot)
//			})
//			FIRDatabase.database().reference().child("users").queryOrderedByChild("lil9porkchop").observeSingleEventOfType(.ChildAdded, withBlock: {(snapshot) in
//				print(snapshot)
//			})
//			FIRDatabase.database().reference().child("users").queryOrderedByKey().observeSingleEventOfType(.Value, withBlock: {(snapshot) in
//			
//				print(snapshot)
//			})
			FIRDatabase.database().reference().child("users/users_by_name").queryOrderedByKey().observeSingleEventOfType(.Value, withBlock: {(snapshot) in
				print(snapshot)
			})
			return
		}
	}
}

//rootRef.queryOrderedByKey().observeEventType(.ChildAdded, withBlock: {
//	(snapshot) in
//	print(snapshot)
//	if let newChat = snapshot.value as? [String: String]{
//		guard var recipient = newChat["recipient"],
//			var sender = newChat["sender"],
//			let stock = newChat["stock"]
//			else{
//				return
//		}
//		if sender == self.title {
//			sender = "You recommended: " + stock + " to " + recipient
//			recipient = ""
//			self.tableData.insert((recipient, sender, stock), atIndex: 0)
//			
//		} else  if recipient == self.title {
//			sender = sender + " recommends: " + stock
//			recipient = ""
//			self.tableData.insert((sender, recipient, stock), atIndex: 0)
//		}
//		
//	}
//	dispatch_async(dispatch_get_main_queue()){
//		self.tableView.reloadData()
//	}
//})


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








