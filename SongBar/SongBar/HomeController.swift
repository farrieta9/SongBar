//
//  HomeController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/13/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

		setUpViews()
		getLoggedInUser()
    }
	
	func setUpViews() {
		
	}
	
	private func getLoggedInUser() {
		if FIRAuth.auth()?.currentUser?.uid == nil {
			self.dismissViewControllerAnimated(true, completion: nil) // Back to the login in screen
		} else {
			let uid = FIRAuth.auth()?.currentUser?.uid
			FIRDatabase.database().reference().child("users_by_id").child(uid!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
				if let result = snapshot.value as? [String: AnyObject] {
					CurrentUser.username = result["username"] as? String
					CurrentUser.fullname = result["fullname"] as? String
				}
			})
		}
	}

}
