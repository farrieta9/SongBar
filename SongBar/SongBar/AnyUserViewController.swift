//
//  AnyUserViewController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/25/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit

class AnyUserViewController: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
}

extension AnyUserViewController: UITableViewDataSource {
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("headerCell", forIndexPath: indexPath) as! UserHeaderTableViewCell
		
		cell.actionName = "Follow"
		return cell
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 150
	}
	
	
}
