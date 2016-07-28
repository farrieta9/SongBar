//
//  MusicPlayer.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/21/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

enum MusicStatus {
	case Play
	case Pause
}

class MusicPlayer {
	
	static var audioPlay: AVPlayer!
	static var musicStatus: MusicStatus = .Pause
	static var playView: UIView?
	static var titleLabel: UILabel?
	static var playButton: UIButton?
	
	static func playSong(urlString: String, title: String) {
		if let url = NSURL(string: urlString) {
			audioPlay = AVPlayer(URL: url)
			audioPlay.play()
			musicStatus = .Play
			playView?.hidden = false
			titleLabel?.text = title
			let image = UIImage(named: "pause")
			playButton?.setImage(image, forState: .Normal)
		}
	}
	
}
