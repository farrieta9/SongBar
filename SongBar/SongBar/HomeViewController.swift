//
//  HomeViewController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/7/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase



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


class HomeViewController: UIViewController {
	
	var rootRef: FIRDatabaseReference!
	var collectionData: Dictionary<String, AnyObject> = [:]

	@IBOutlet weak var collectionView: UICollectionView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		rootRef = FIRDatabase.database().reference()
		
//		let firebase = FirebaseAPI()
//		let data = firebase.retrieveData()
//		print(data)
//		print(firebase.data)
//		print(retrieveData())
		
		
		dispatch_async(dispatch_get_main_queue()){
			self.rootRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
				let postDict = snapshot.value as! [String : AnyObject]
				// ...
				self.collectionData = postDict
				print(postDict)
				self.collectionView.reloadData()
			})
		}
		
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

extension HomeViewController: UICollectionViewDataSource{
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return collectionData.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! HomeCollectionCell
		
		cell.song = String(indexPath.row)
		
		cell.backgroundColor = UIColor.greenColor()
		
		return cell
	}
}

extension HomeViewController: UICollectionViewDelegate {
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		print("Selected cell: \(indexPath.row)")
	}
}