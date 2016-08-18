//
//  ShareController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/19/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase

class ShareController: UIViewController {

	@IBOutlet weak var tableView: UITableView!
	
	var selectedRows = [Int]()
	var fansData = [User]()
	var track: SpotifyTrack!
	var inputContainerBottomAnchor: NSLayoutConstraint?
	var hideMusicPlayer: Bool = false
	
	lazy var inputContainerView: CommentInputContainerView = {
		let contentView = CommentInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
		return contentView
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()

		setUpView()
		fetchFans()
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		if MusicPlayer.playView?.hidden == false {
			hideMusicPlayer = true
			MusicPlayer.playView?.hidden = true
		}
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		if hideMusicPlayer == true {
			MusicPlayer.playView?.hidden = false
		}
	}
	
	func fetchFans() {
		
		guard let uid = CurrentUser.uid else {
			return
		}
		FIRDatabase.database().reference().child("users_by_id/\(uid)/Fans").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
			
			self.fansData.removeAll()
			
			guard let result = snapshot.value as? [String: [String: String]] else {
				return
			}
			
			for fansUid in result.keys {
				FIRDatabase.database().reference().child("users_by_id/\(fansUid)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
					
					guard let person = snapshot.value as? [String: AnyObject] else {
						return
					}
					
					var imageURL = ""
					if let imageURLAsString = person["imageURL"] as? String {
						imageURL = imageURLAsString
					}
					
					if let email = person["email"] as? String, fullname = person["fullname"] as? String, username = person["username"] as? String {
						let user = User(email: email, fullname: fullname, username: username, uid: fansUid, image: imageURL)
						self.fansData.append(user)
					}
					
					dispatch_async(dispatch_get_main_queue(), {
						self.tableView.reloadData()
					})
					
					}, withCancelBlock: nil)
			}
			}, withCancelBlock: nil)
	}
	
	func handleSend() {
		guard let currentUserUid = CurrentUser.uid, username = CurrentUser.username else {
			return // No signed in user
		}
		
		if selectedRows.count == 0 {
			return 
		}

		let date = String(Int(NSDate().timeIntervalSince1970))
		let comment = inputContainerView.inputTextField.text!
		
		let ref = FIRDatabase.database().reference().child("comments").childByAutoId()
		ref.child("initial").setValue(["date": date, "comment": comment, "username": username])
		ref.child("comments").child(date).setValue(["username": username, "comment": comment])
		
		let value = ["title": track.title, "artist": track.artist, "imageURL": track.imageUrl, "previewURL": track.previewUrl, "donor": username, "comment_reference": ref.key]
		
		for row in selectedRows {
			
			if let uid = fansData[row].uid {
				
				FIRDatabase.database().reference().child("users_by_id/\(uid)/received").child(date).setValue(value)
			}
		}
		
		FIRDatabase.database().reference().child("users_by_id/\(currentUserUid)/sent").child(date).setValue(value)
		FIRDatabase.database().reference().child("users_by_id/\(currentUserUid)/received").child(date).setValue(value)
		
		
		navigationController?.popViewControllerAnimated(true)
	}
	
	override var inputAccessoryView: UIView? {
		get {
			return inputContainerView
		}
	}
	
	override func canBecomeFirstResponder() -> Bool {
		return true
	}
	
	func setUpView() {
		tableView.dataSource = self
		tableView.delegate = self
		tableView.allowsMultipleSelection = true
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .Plain, target: self, action: #selector(self.handleSend))
		self.navigationItem.title = "Fans"
		inputContainerView.inputTextField.delegate = self
	}
}

extension ShareController: UITableViewDataSource {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return fansData.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ContentCell
		
		cell.titleLabel.text = fansData[indexPath.row].username
		cell.detailLabel.text = fansData[indexPath.row].fullname
		
		if let imageString = fansData[indexPath.row].imageString {
			cell.pictureView.loadImageUsingURLString(imageString)
		} else {
			cell.pictureView.image = UIImage(named: "default_profile.png")
		}
		
		return cell
	}
}


extension ShareController: UITableViewDelegate {
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = tableView.cellForRowAtIndexPath(indexPath) as! ContentCell
		
		cell.accessoryType = .Checkmark
		selectedRows.append(indexPath.row)
	}
	
	func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
		let cell = tableView.cellForRowAtIndexPath(indexPath) as! ContentCell
		cell.accessoryType = .None

		let index = selectedRows.indexOf(indexPath.row)
		if let i = index {
			selectedRows.removeAtIndex(i)
		}
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 74
	}
}


extension ShareController: UITextFieldDelegate {
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}








