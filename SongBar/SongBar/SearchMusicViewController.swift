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
//	var myRootRef = Firebase(url: "https://song-bar.firebaseio.com")  var rootRef = FIRDatabase.database().reference()
//	var rootRef = FIRDatabase.database().reference()
	var rootRef: FIRDatabaseReference!

	@IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
		
		rootRef = FIRDatabase.database().reference()
//		rootRef.setValue("Test data2")
//		rootRef.child("Key1").child("subkey1").setValue("value1")
		
		

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
		print(tableData[indexPath.row].previewUrl)
		print(tableData[indexPath.row].artist)
		print(tableData[indexPath.row].imageUrl)
		print(tableData[indexPath.row].title)
		
		
		//		let name = realmUserData[0].userName
		//		let rootRef = Firebase(url: "https://sstock.firebaseio.com/")
		//		let data = ["sender": name, "recipient": recipient, "stock": stock]
		//		let ref = rootRef.childByAutoId()
		//		ref.setValue(data)
//		rootRef.child("Key1").child("subkey1").setValue("value1")
		let ref = rootRef.childByAutoId()
		let data = ["artist": tableData[indexPath.row].artist, "title": tableData[indexPath.row].title,
		            "imageURL": tableData[indexPath.row].imageUrl, "previewURL": tableData[indexPath.row].previewUrl]
//
//		let data = ["sender": name, "recipient": recipient, "stock": stock]
		
//		let name = realmUserData[0].userName
//		let rootRef = Firebase(url: "https://sstock.firebaseio.com/")
//		let data = ["sender": name, "recipient": recipient, "stock": stock]
//		let ref = rootRef.childByAutoId()
//		ref.setValue(data)
//		rootRef.child("key1").child("subkey1").setValue("value1")
		
		ref.setValue(data)
		
	}
}








