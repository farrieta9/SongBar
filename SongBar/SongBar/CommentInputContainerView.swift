//
//  CommentInputContainerView.swift
//  SongBar
//
//  Created by Francisco Arrieta on 8/17/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit

class CommentInputContainerView: UIView {
	
	lazy var inputTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder = "Add comment..."
		textField.translatesAutoresizingMaskIntoConstraints = false
		return textField
	}()
	
	let sendButton: UIButton = {
		let button = UIButton(type: .System)
		button.setTitle("Send", forState: .Normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.titleLabel?.font = UIFont.boldSystemFontOfSize(16)
		return button
	}()
	
	let seperatorView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.rgb(220, green: 220, blue: 220)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.backgroundColor = UIColor.whiteColor()
		
		addSubview(inputTextField)
		addSubview(sendButton)
		addSubview(seperatorView)
		
		inputTextField.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 8).active = true
		inputTextField.centerYAnchor.constraintEqualToAnchor(centerYAnchor).active = true
		inputTextField.rightAnchor.constraintEqualToAnchor(sendButton.leftAnchor).active = true
		inputTextField.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active = true
		
		sendButton.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
		sendButton.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
		sendButton.widthAnchor.constraintEqualToConstant(80).active = true
		sendButton.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active = true
		
		seperatorView.leftAnchor.constraintEqualToAnchor(self.leftAnchor).active = true
		seperatorView.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
		seperatorView.widthAnchor.constraintEqualToAnchor(self.widthAnchor).active = true
		seperatorView.heightAnchor.constraintEqualToConstant(1).active = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
