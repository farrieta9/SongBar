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
		button.setTitle("Stop", forState: .Normal)
		button.setTitleColor(UIColor.blueColor(), forState: .Normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	let playerView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.redColor()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.hidden = false
		return view
	}()

	let titleLabel: UILabel = {
		let label = UILabel()
		label.text = "123"
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .Center
		return label
	}()
	
	let playButton: UIButton = {
		let button = UIButton()
		button.setTitle("Pause", forState: .Normal)
		button.setTitleColor(UIColor.blueColor(), forState: .Normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		MusicPlayer.playView = playerView
		MusicPlayer.titleLabel = titleLabel
		
		view.addSubview(playerView)
		playerView.addSubview(stopButton)
		playerView.addSubview(titleLabel)
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
		titleLabel.centerYAnchor.constraintEqualToAnchor(playerView.centerYAnchor).active = true
		titleLabel.widthAnchor.constraintEqualToAnchor(playerView.widthAnchor, constant: -10).active = true
		titleLabel.heightAnchor.constraintEqualToConstant(30).active = true
		
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
			sender.setTitle("Pause", forState: .Normal)
			audioPlayer.play()
			
		case .Play:
			MusicPlayer.musicStatus = .Pause
			sender.setTitle("Play", forState: .Normal)
			audioPlayer.pause()
		}
	}
}
