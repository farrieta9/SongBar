//
//  CommentCell.swift
//  SongBar
//
//  Created by Francisco Arrieta on 8/1/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
	
	let pictureView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.layer.cornerRadius = 20
		imageView.layer.masksToBounds = true
		return imageView
	}()
	
	let usernameLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let commentLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 0
		return label
		
	}()
	
	let timestampLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "4d"
		label.enabled = false
		label.font = UIFont.systemFontOfSize(14)
		return label
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
		
		addSubview(pictureView)
		addSubview(usernameLabel)
		addSubview(commentLabel)
		addSubview(timestampLabel)
		
		setUpViews()
	}
	
	private func setUpViews() {
		self.preservesSuperviewLayoutMargins = false
		self.separatorInset = UIEdgeInsetsZero
		self.layoutMargins = UIEdgeInsetsZero
		
		pictureView.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 16).active = true
		pictureView.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
		pictureView.widthAnchor.constraintEqualToConstant(40).active = true
		pictureView.heightAnchor.constraintEqualToConstant(40).active = true
		
		usernameLabel.leftAnchor.constraintEqualToAnchor(pictureView.rightAnchor, constant: 8).active = true
		usernameLabel.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor, constant: -12).active = true
		usernameLabel.widthAnchor.constraintEqualToConstant(100).active = true
		usernameLabel.heightAnchor.constraintEqualToConstant(30).active = true
		
		commentLabel.leftAnchor.constraintEqualToAnchor(pictureView.rightAnchor, constant: 8).active = true
		commentLabel.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active = true
		commentLabel.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor, constant: 8).active = true
		commentLabel.heightAnchor.constraintEqualToConstant(30).active = true
		
		timestampLabel.rightAnchor.constraintEqualToAnchor(self.rightAnchor, constant: -8).active = true
		timestampLabel.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor, constant: -16).active = true
		timestampLabel.widthAnchor.constraintLessThanOrEqualToConstant(50).active = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setCellContent(user: User, comment: String, date: String) {
		if let image = user.imageString {
			pictureView.loadImageUsingURLString(image)
		}
		
		usernameLabel.text = user.username
		commentLabel.text = comment
		
		if let dateAsDouble = Double(date) {
			let timestamp = NSDate(timeIntervalSince1970: dateAsDouble)
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "MM/dd"
			timestampLabel.text = dateFormatter.stringFromDate(timestamp)
		}
	}
}












