//
//  CommentController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 8/1/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase

class CommentController: UITableViewController {
	
	private let cellId = "cell"
	lazy var commentKey: String = ""
	var tableData = [Comment]()
	
	lazy var inputContainerView: CommentInputContainerView = {
		let contentView = CommentInputContainerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
		return contentView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = "Comment"
		tableView.allowsSelection = false
		tableView.registerClass(CommentCell.self, forCellReuseIdentifier: cellId)
		tableView.separatorInset = UIEdgeInsetsZero
		fetchComments()
		inputContainerView.inputTextField.delegate = self
		inputContainerView.sendButton.addTarget(self, action: #selector(handleSend), forControlEvents: .TouchUpInside)
	}
	
	override var inputAccessoryView: UIView? {
		get {
			return inputContainerView
		}
	}
	
	override func canBecomeFirstResponder() -> Bool {
		return true
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableData.count
	}
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! CommentCell
		
		cell.setCellContent(tableData[indexPath.row].user!, comment: tableData[indexPath.row].comment, date: tableData[indexPath.row].timestamp)
		
		return cell
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 70
	}
	
	func handleSend() {
		let date = String(Int(NSDate().timeIntervalSince1970))
		
//		let comment = inputTextField.text!
		let comment = inputContainerView.inputTextField.text!
		let username = CurrentUser.username!
		FIRDatabase.database().reference().child("comments/\(commentKey)/comments").child(date).setValue(["comment": comment, "username": username])
		
		inputContainerView.inputTextField.text = ""
	}
	
	func fetchComments() {
		FIRDatabase.database().reference().child("comments/\(commentKey)").observeEventType(.Value, withBlock: { (snapshot) in
			
			
			guard let results = snapshot.value as? [String: AnyObject], comments = results["comments"] as? [String: [String: String]] else {
				return
			}
			
			self.tableData.removeAll()
			for (key, value) in comments.sort({$0.0.compare($1.0) == NSComparisonResult.OrderedAscending}) {
				
				if let com = value["comment"], username = value["username"] {
					
					if com.isEmpty {
						continue
					}
					
					FIRDatabase.database().reference().child("users_by_name/\(username)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
						
						guard let userResults = snapshot.value as? [String: String] else {
							return
						}
						
						if let fullname = userResults["fullname"], email = userResults["email"], uid = userResults["uid"] {
							
							var imageString = ""
							if let imageURL = userResults["imageURL"] {
								imageString = imageURL
							}
							
							let user = User(email: email, fullname: fullname, username: username, uid: uid, image: imageString)
							let comment = Comment(user: user, comment: com, timestamp: key)
							
							self.tableData.append(comment)
							
							self.tableData.sortInPlace({ (element1, element2) -> Bool in
								return element1.timestamp < element2.timestamp
							})
						}

						dispatch_async(dispatch_get_main_queue(), {
							self.tableView.reloadData()
						})
						
					}, withCancelBlock: nil)
				}
			}
		}, withCancelBlock: nil)
	}
}

extension CommentController: UITextFieldDelegate {
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		handleSend()
		return true
	}
}





