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
		return label
		
	}()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
		
		addSubview(pictureView)
		addSubview(usernameLabel)
		addSubview(commentLabel)
		
		
		setUpViews()
	}
	
	private func setUpViews() {
		pictureView.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 8).active = true
		pictureView.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active = true
		pictureView.widthAnchor.constraintEqualToConstant(40).active = true
		pictureView.heightAnchor.constraintEqualToConstant(40).active = true
		
		usernameLabel.leftAnchor.constraintEqualToAnchor(pictureView.rightAnchor, constant: 8).active = true
		usernameLabel.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor, constant: -8).active = true
		usernameLabel.widthAnchor.constraintEqualToConstant(100).active = true
		usernameLabel.heightAnchor.constraintEqualToConstant(30).active = true
		
		commentLabel.leftAnchor.constraintEqualToAnchor(pictureView.rightAnchor, constant: 8).active = true
		commentLabel.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor, constant: 8).active = true
		commentLabel.widthAnchor.constraintEqualToConstant(100).active = true
		commentLabel.heightAnchor.constraintEqualToConstant(30).active = true
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setCellContent(imageString: String, username: String, comment: String) {
		pictureView.loadImageUsingURLString(imageString)
		usernameLabel.text = username
		commentLabel.text = comment
	}
}
