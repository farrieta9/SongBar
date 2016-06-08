//
//  SearchMusicViewController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/7/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit

class SearchMusicViewController: UIViewController {
	
	var tableData = [SpotifyTrack]()

	@IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

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








