//
//  FeedCell.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/19/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit
import Firebase

class FeedCell: UITableViewCell {

	
	@IBOutlet weak var donorLabel: UILabel!
	@IBOutlet weak var pictureView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var detailLabel: UILabel!
	@IBOutlet weak var commentView: UIView!
	@IBOutlet weak var commentLabel: UILabel!
	
	var track: Track?
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		
		pictureView.layer.borderColor = UIColor.blackColor().CGColor
		pictureView.layer.cornerRadius = 15
		pictureView.layer.masksToBounds = true
		
		commentView.backgroundColor = UIColor.whiteColor()

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func setCellContent(track: Track) {
		self.track = track
		
		titleLabel.text = track.title
		detailLabel.text = track.artist
		pictureView.loadImageUsingURLString(track.imageUrl)
		donorLabel.text = track.donor
		commentLabel.text = ""
		
		fetchInitialComment()
	}
	
	private func fetchInitialComment() {
		
		guard let commentReference = track?.commentReference, currentUsername = CurrentUser.username else {
			return
		}
		
		FIRDatabase.database().reference().child("comments/\(commentReference)").observeEventType(.Value, withBlock: { (snapshot) in
			
			guard let results = snapshot.value as? [String: AnyObject] else {
				return
			}
			
			if let initial = results["initial"] {
				if let username = initial["username"] as? String, comment = initial["comment"] as? String {
					
					var name = username
					if name == currentUsername {
						name = "You"
					}
					
					self.commentLabel.text = "\(name): \(comment)"
				}
			}
		}, withCancelBlock: nil)
	}
}
