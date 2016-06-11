//
//  FirebaseAPI.swift
//  SongBar
//
//  Created by Francisco Arrieta on 6/10/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import Foundation
import Firebase

class FirebaseAPI {
	// http://stackoverflow.com/questions/37316179/retrieve-data-from-new-firebase
	lazy var rootRef = FIRDatabase.database().reference()  // delays the instantiation of the database reference until its needed, which wont be until viewDidLoad on your initial view controller.
	var data: Dictionary<String, AnyObject> = [:]
	
	func retrieveData() -> Dictionary<String, AnyObject> {
		rootRef.observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
			let postDict = snapshot.value as! [String : AnyObject]
			// ...
//			print(postDict)
			self.data = postDict
		})
		
		return self.data
	}
	
	
}