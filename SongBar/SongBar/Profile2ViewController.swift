//
//  Profile2ViewController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/18/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit

class Profile2ViewController: UIViewController {
	
	
	@IBOutlet weak var tableView: UITableView!
	private let tableHeaderHeight: CGFloat = 100.0
	private let tableHeaderCutAway: CGFloat = 0.0
	
	private var headerView: ProfileHeaderView!
	private var headerMaskLayer: CAShapeLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
		
		headerView = tableView.tableHeaderView as! ProfileHeaderView
		tableView.tableHeaderView = nil  // Clear out the default header
		tableView.addSubview(headerView) // Add header
		
		tableView.contentInset = UIEdgeInsets(top: tableHeaderHeight, left: 0, bottom: 0, right: 0)
		tableView.contentOffset = CGPoint(x: 0, y: -tableHeaderHeight)
		
		headerMaskLayer = CAShapeLayer()
		headerMaskLayer.fillColor = UIColor.blackColor().CGColor
		
		headerView.layer.mask = headerMaskLayer
		
		updateHeaderView()

		
    }
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		updateHeaderView()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		updateHeaderView()
	}
	@IBAction func onContentChange(sender: UISegmentedControl) {
		
	}
	
	func updateHeaderView() {
		let effectiveHeight = tableHeaderHeight - tableHeaderCutAway / 2
		var headerRect = CGRect(x: 0, y: -effectiveHeight, width: tableView.bounds.width, height: tableHeaderHeight)
		
		if tableView.contentOffset.y < -effectiveHeight {
			headerRect.origin.y = tableView.contentOffset.y
			headerRect.size.height = -tableView.contentOffset.y + tableHeaderCutAway / 2
		}
		
		headerView.frame = headerRect
		
		// Cut away
		
		let path = UIBezierPath()
		path.moveToPoint(CGPoint(x: 0, y: 0))
		path.addLineToPoint(CGPoint(x: headerRect.width, y: 0))
		path.addLineToPoint(CGPoint(x: headerRect.width, y: headerRect.height))
		
		path.addLineToPoint(CGPoint(x: 0, y:headerRect.height - tableHeaderCutAway))
		
		headerMaskLayer?.path = path.CGPath // Maybe remove the ? and !
	}
}


extension Profile2ViewController: UITableViewDataSource	{
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 2
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 1
		} else{
			return 20
		}
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		if indexPath.section == 1 {
			let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
			cell.textLabel?.text = "\(indexPath.row)"
			return cell
		} else {
			let cell = tableView.dequeueReusableCellWithIdentifier("headerCell") as! ProfileHeaderTableViewCell
//			let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! SearchMusicTableCell
			cell.username = "some user"
			
			return cell
		}
	}
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		switch indexPath.section {
		case 0:
			return 175
		case 1:
			return 50
		default:
			return 50
		}
	}
}

extension Profile2ViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(scrollView: UIScrollView) {
		updateHeaderView()
	}
}


//extension Profile2ViewController: UITableViewDelegate {
//	
//}