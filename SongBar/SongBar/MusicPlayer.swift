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
	
	static var hidden = true
	static var audioPlay: AVPlayer!
	static var musicStatus: MusicStatus = .Pause
	static var title: String = ""
}
