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

	@IBOutlet weak var pictureView: UIImageView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var detailLabel: UILabel!
	@IBOutlet weak var commentView: UIView!
	@IBOutlet weak var commentLabel: UILabel!
	@IBOutlet weak var donorLabel: UILabel!
	
	var track: Track?
	
    override func awakeFromNib() {
        super.awakeFromNib()
		pictureView.layer.borderColor = UIColor.blackColor().CGColor
		pictureView.layer.cornerRadius = 15
		pictureView.layer.masksToBounds = true
		
		commentView.backgroundColor = UIColor.whiteColor()
		donorLabel.font = UIFont.boldSystemFontOfSize(13)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

		self.selectionStyle = .None
    }
	
	func setCellContent(track: Track) {
		self.track = track
		
		titleLabel.text = track.title
		detailLabel.text = track.artist
		pictureView.loadImageUsingURLString(track.imageUrl)
		donorLabel.text = "\(track.donor)   "
		commentLabel.text = ""
		fetchInitialComment()
	}
	
	private func fetchInitialComment() {
		
		guard let commentReference = track?.commentReference else {
			return
		}
		
		FIRDatabase.database().reference().child("comments/\(commentReference)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
			
			guard let results = snapshot.value as? [String: AnyObject] else {
				return
			}
			
			if let initial = results["initial"] {
				if let comment = initial["comment"] as? String {
					
					
					if comment != "" {
						self.commentLabel.text = "\(comment)"
					}
					
				}
			}
		}, withCancelBlock: nil)
	}
}
