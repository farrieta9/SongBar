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
	
	lazy var inputTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Add comment..."
		textField.translatesAutoresizingMaskIntoConstraints = false
		textField.delegate = self
		return textField
	}()
	
	lazy var inputContainerView: UIView = {
		let contentView = UIView()
		contentView.backgroundColor = UIColor.whiteColor()
		contentView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
		
		contentView.addSubview(self.inputTextField)
		
		let sendButton = UIButton(type: .System)
		sendButton.setTitle("Send", forState: .Normal)
		sendButton.translatesAutoresizingMaskIntoConstraints = false
		sendButton.titleLabel?.font = UIFont.boldSystemFontOfSize(16)
		
		sendButton.addTarget(self, action: #selector(handleSend), forControlEvents: .TouchUpInside)
		
		contentView.addSubview(sendButton)
		
		let seperatorView = UIView()
		seperatorView.backgroundColor = UIColor.rgb(220, green: 220, blue: 220)
		seperatorView.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(seperatorView)
		
		self.inputTextField.leftAnchor.constraintEqualToAnchor(contentView.leftAnchor, constant: 8).active = true
		self.inputTextField.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor).active = true
		self.inputTextField.rightAnchor.constraintEqualToAnchor(sendButton.leftAnchor).active = true
		self.inputTextField.heightAnchor.constraintEqualToAnchor(contentView.heightAnchor).active = true
		
		seperatorView.leftAnchor.constraintEqualToAnchor(contentView.leftAnchor).active = true
		seperatorView.topAnchor.constraintEqualToAnchor(contentView.topAnchor).active = true
		seperatorView.widthAnchor.constraintEqualToAnchor(contentView.widthAnchor).active = true
		seperatorView.heightAnchor.constraintEqualToConstant(1).active = true
		
		sendButton.rightAnchor.constraintEqualToAnchor(contentView.rightAnchor).active = true
		sendButton.centerYAnchor.constraintEqualToAnchor(contentView.centerYAnchor).active = true
		sendButton.widthAnchor.constraintEqualToConstant(80).active = true
		sendButton.heightAnchor.constraintEqualToAnchor(contentView.heightAnchor).active = true
		
		return contentView
	}()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = "Comment"
		tableView.registerClass(CommentCell.self, forCellReuseIdentifier: cellId)
		fetchComments()
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
		
		cell.setCellContent(tableData[indexPath.row].user!, comment: tableData[indexPath.row].comment)
		
		return cell
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 70
	}
	
	func handleSend() {
		print(inputTextField.text)
		inputTextField.text = ""
	}
	
	func fetchComments() {
		FIRDatabase.database().reference().child("comments/\(commentKey)").observeEventType(.Value, withBlock: { (snapshot) in
			
			guard let results = snapshot.value as? [String: AnyObject], comments = results["comments"] as? [String: [String: String]] else {
				return
			}
			
			self.tableData.removeAll()
			
			for (key, value) in comments {
				
				if let com = value["comment"], username = value["username"] {
					self.fetchCommentWithUserDetails(username, comment: com, date: key)
					
				}
			}
		}, withCancelBlock: nil)
	}
	
	private func fetchCommentWithUserDetails(username: String, comment: String, date: String) {
		FIRDatabase.database().reference().child("users_by_name/\(username)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
			
			guard let userResults = snapshot.value as? [String: String] else {
				return
			}
			
			if let fullname = userResults["fullname"], imageURL = userResults["imageURL"], email = userResults["email"], uid = userResults["uid"] {
				let user = User(email: email, fullname: fullname, username: username, uid: uid, image: imageURL)
				let comment = Comment(user: user, comment: comment, timestamp: date)
				self.tableData.append(comment)
			}
			dispatch_async(dispatch_get_main_queue(), {
				self.tableView.reloadData()
			})
			
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





