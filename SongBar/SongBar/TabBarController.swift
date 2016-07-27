//
//  CustomTabBarController.swift
//  SongBar
//
//  Created by Francisco Arrieta on 7/26/16.
//  Copyright © 2016 lil9porkchop. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

	let stopButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		let image = UIImage(named: "delete.png")
		button.setImage(image, forState: .Normal)
		return button
	}()
	
	let playerView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.redColor()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.hidden = false
		view.backgroundColor = UIColor.rgb(225, green: 227, blue: 228)
		return view
	}()
	
	let titleLabel: UILabel = {
		let label = UILabel()
		label.text = "123"
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .Center
		label.font = UIFont.systemFontOfSize(15)
		return label
	}()
	
	let detailLabel: UILabel = {
		let label = UILabel()
		label.text = "Detail"
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .Center
		label.font = UIFont.systemFontOfSize(15)
		return label
	}()
	
	let playButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		let image = UIImage(named: "pause.png")
		button.setImage(image, forState: .Normal)
		return button
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		MusicPlayer.playView = playerView
		MusicPlayer.titleLabel = titleLabel
		
		view.addSubview(playerView)
		playerView.addSubview(stopButton)
		playerView.addSubview(titleLabel)
		playerView.addSubview(detailLabel)
		playerView.addSubview(playButton)
		
		// Need x, y, width, and height
		playerView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
		playerView.centerYAnchor.constraintEqualToAnchor(view.bottomAnchor, constant: -74).active = true
		playerView.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
		playerView.heightAnchor.constraintEqualToConstant(50).active = true
	
		// Need x, y, width, and height
		stopButton.centerXAnchor.constraintEqualToAnchor(playerView.rightAnchor, constant: -32).active = true
		stopButton.centerYAnchor.constraintEqualToAnchor(playerView.centerYAnchor, constant: 0).active = true
		stopButton.widthAnchor.constraintEqualToConstant(50).active = true
		stopButton.heightAnchor.constraintEqualToConstant(50).active = true
		
		
		// Need x, y, width, and height
		titleLabel.centerXAnchor.constraintEqualToAnchor(playerView.centerXAnchor).active = true
		titleLabel.centerYAnchor.constraintEqualToAnchor(playerView.centerYAnchor, constant: -8).active = true
		titleLabel.widthAnchor.constraintEqualToAnchor(playerView.widthAnchor, constant: -150).active = true
		titleLabel.heightAnchor.constraintEqualToConstant(30).active = true
		
		// Need x, y, width, and height
		detailLabel.centerXAnchor.constraintEqualToAnchor(playerView.centerXAnchor).active = true
		detailLabel.centerYAnchor.constraintEqualToAnchor(playerView.centerYAnchor, constant: 8).active = true
		detailLabel.widthAnchor.constraintEqualToAnchor(playerView.widthAnchor, constant: -150).active = true
		detailLabel.heightAnchor.constraintEqualToConstant(30).active = true
		
		// Need x, y, width, and height
		playButton.centerXAnchor.constraintEqualToAnchor(playerView.leftAnchor, constant: 36).active = true
		playButton.centerYAnchor.constraintEqualToAnchor(playerView.centerYAnchor).active = true
		playButton.widthAnchor.constraintEqualToConstant(50).active = true
		playButton.heightAnchor.constraintEqualToConstant(50).active = true
		
		// Adding targets
		stopButton.addTarget(self, action: #selector(self.onStopButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
		playButton.addTarget(self, action: #selector(self.onPlayButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
	
	
	func onStopButton(sender: UIButton) {
		guard let audioPlayer = MusicPlayer.audioPlay else {
			return
		}
		
		playerView.hidden = true
		audioPlayer.pause()
	}
	
	func onPlayButton(sender: UIButton) {
		guard let audioPlayer = MusicPlayer.audioPlay else {
			return
		}
		
		switch MusicPlayer.musicStatus {
		case .Pause:
			MusicPlayer.musicStatus = .Play
			let image = UIImage(named: "pause")
			sender.setImage(image, forState: .Normal)
			audioPlayer.play()
			
		case .Play:
			MusicPlayer.musicStatus = .Pause
			let image = UIImage(named: "play")
			sender.setImage(image, forState: .Normal)
			audioPlayer.pause()
		}
		
	}
}
