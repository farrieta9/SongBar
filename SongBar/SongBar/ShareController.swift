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
	
	let textField: UITextField = {
		let tf = UITextField()
		tf.placeholder = "Add a thought..."
		tf.returnKeyType = .Done
		tf.translatesAutoresizingMaskIntoConstraints = false
		return tf
	}()
	
	let inputContainerView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()

		setUpView()
		setUpKeyboardObservers()
		fetchFans()
    }
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		
		NSNotificationCenter.defaultCenter().removeObserver(self)  // To prevent memory leak
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
	
	func setUpKeyboardObservers() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.handleKeyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.handleKeyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
	}
	
	func handleKeyboardWillShow(notification: NSNotification) {
		let keyboardFrame = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue()
		let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
		
		// Move inputContainerView up
		inputContainerBottomAnchor?.constant = -keyboardFrame!.height
		UIView.animateWithDuration(keyboardDuration!) {
			self.view.layoutIfNeeded()
		}
	}
	
	
	func handleKeyboardWillHide(notification: NSNotification) {
		let keyboardDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
		inputContainerBottomAnchor?.constant = -50
		UIView.animateWithDuration(keyboardDuration!) {
			self.view.layoutIfNeeded()
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
		
		let date = CurrentUser.getServerTime()
		let comment = textField.text!
		
		let ref = FIRDatabase.database().reference().child("comments").childByAutoId()
		ref.child(date).setValue([username: comment])
		
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
	
	func setUpView() {
		tableView.dataSource = self
		tableView.delegate = self
		textField.delegate = self
		tableView.allowsMultipleSelection = true
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .Plain, target: self, action: #selector(self.handleSend))
		self.navigationItem.title = "Fans"
		
		view.addSubview(inputContainerView)
		inputContainerView.addSubview(textField)
		
		inputContainerView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
		inputContainerBottomAnchor = inputContainerView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -50)
		inputContainerBottomAnchor?.active = true
		inputContainerView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
		inputContainerView.heightAnchor.constraintEqualToConstant(50).active = true
		
		textField.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
		textField.centerYAnchor.constraintEqualToAnchor(inputContainerView.centerYAnchor).active = true
		textField.widthAnchor.constraintEqualToAnchor(inputContainerView.widthAnchor, constant: -16).active = true
		textField.heightAnchor.constraintEqualToConstant(50).active = true
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








