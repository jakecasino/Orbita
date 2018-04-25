//
//  RCAudioUpload.swift
//  Orbita
//
//  Created by Jake Casino on 4/17/18.
//

import UIKit
import AVFoundation

class RCAudioUpload: UIViewController, AVAudioRecorderDelegate, RCResponseCard {
	var RCHeaderTitle: String?
	var RCHeaderSendButton: RCAction?
	
	var recordingSession: AVAudioSession?
	var recorder: AVAudioRecorder?
	var captureButton: RCAction?
	var audioPlayer: AVAudioPlayer?
	var audioPlayerView: AudioPlayerView?
	
	var timerLabel: RCLabel?
	var timerCount = 0
	var timer_Seconds: String?
	var timer_Minutes = 0
	var timer = Timer()
	
	init(title: String) {
		super.init(nibName: nil, bundle: nil)
		RCHeaderTitle = title
		
		AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
			if hasPermission {
				self.recordingSession = AVAudioSession.sharedInstance()
			}
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func didMove(toParentViewController parent: UIViewController?) {
		view.frame = view.superview!.bounds
		
		let margin: CGFloat = 16
		
		let borderSize = view.frame.height - (margin * 2)
		let border = UIView(frame: CGRect(x: (view.frame.width - borderSize) / 2, y: margin, width: borderSize, height: borderSize))
		border.backgroundColor = UIColor(named: "Medium Grey")
		border.layer.cornerRadius = borderSize / 2
		view.addSubview(border)
		
		let borderCutoutSize = borderSize * (48 / 56)
		let borderCutout = UIView(frame: CGRect(x: (view.frame.width - borderCutoutSize) / 2, y: (view.frame.height - borderCutoutSize) / 2, width: borderCutoutSize, height: borderCutoutSize))
		borderCutout.backgroundColor = UIColor(named: "Lighter Grey")
		borderCutout.layer.cornerRadius = borderCutoutSize / 2
		view.addSubview(borderCutout)
		
		let captureButtonSize = borderCutoutSize * (44 / 48)
		captureButton = RCAction(glyph: .microphone, for: nil, size: captureButtonSize, customColor: UIColor.red, in: ChatViewController())
		captureButton!.frame.origin = CGPoint(x: (view.frame.width - captureButtonSize) / 2, y: (view.frame.height - captureButtonSize) / 2)
		captureButton!.addTarget(self, action: #selector(toggleRecordingSession(sender:)), for: .touchUpInside)
		view.addSubview(captureButton!)
	}
	
	@objc func toggleRecordingSession(sender: UIButton) {
		if recorder == nil {
			RCHeaderSendButton!.isEnabled = false
			
			let filename = getDirectory().appendingPathComponent("audio.m4a")
			let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
			
			do {
				recorder = try AVAudioRecorder(url: filename, settings: settings)
				recorder!.delegate = self
				recorder!.record()
				captureButton!.setImage(UIImage(named: "Stop"), for: .normal)
			} catch {
				// catch errors
			}
			
			let captureButtonFlash = UIButton(frame: captureButton!.frame)
			captureButtonFlash.layer.cornerRadius = captureButtonFlash.frame.width / 2
			captureButtonFlash.backgroundColor = UIColor.red
			view.insertSubview(captureButtonFlash, belowSubview: captureButton!)
			captureButton!.backgroundColor = UIColor.clear
			
			timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (Timer) in
				self.timerCount += 1
				if self.timerCount < 10 {
					self.timer_Seconds = "0\(self.timerCount.description)"
				} else if self.timerCount > 59 {
					self.timer_Seconds = "00"
					self.timerCount = 0
					self.timer_Minutes += 1
				} else {
					self.timer_Seconds = "\(self.timerCount.description)"
				}
				self.timerLabel!.text = "\(self.timer_Minutes):" + self.timer_Seconds!
				self.timerLabel!.sizeToFit()
				
				UIView.animate(withDuration: 0.9) {
					if captureButtonFlash.backgroundColor == UIColor.red {
						captureButtonFlash.backgroundColor = UIColor(named: "AudioRecordingFlash")
					} else {
						captureButtonFlash.backgroundColor = UIColor.red
					}
				}
			})
			timer.fire()
		} else {
			timer.invalidate()
			timerCount = 0
			timer_Seconds = nil
			timer_Minutes = 0
			
			UIView.animate(withDuration: 0.3, animations: {
				if self.captureButton!.backgroundColor != UIColor.red {
					self.captureButton!.backgroundColor = UIColor.red
				}
			}) { (complete) in
				for (index, subview) in self.view.subviews.enumerated() {
					if index == self.view.subviews.count - 3 {
						subview.removeFromSuperview()
					}
				}
			}
			
			recorder!.stop()
			recorder = nil
			captureButton!.setImage(UIImage(named: "Microphone"), for: .normal)
			
			let path = getDirectory().appendingPathComponent("audio.m4a")
			do {
				audioPlayer = try AVAudioPlayer(contentsOf: path)
				RCHeaderSendButton!.isEnabled = true
				audioPlayerView = AudioPlayerView(audioPlayer: audioPlayer!, in: self)
				view.addSubview(audioPlayerView!)
			} catch {
				// catch errors
			}
		}
	}
	
	func getDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentDirectory = paths[0]
		return documentDirectory
	}
	
	func dismissAudioPlayerView() {
		timerLabel!.text = "0:00"
		timerLabel!.sizeToFit()
		for subview in view.subviews {
			if let subview = subview as? AudioPlayerView {
				UIView.animate(withDuration: 0.3, animations: {
					subview.alpha = 0
				}) { (complete) in
					subview.removeFromSuperview()
				}
			}
		}
		RCHeaderSendButton!.isEnabled = false
	}
	
	class AudioPlayerView: UIView {
		var audioPlayer: AVAudioPlayer?
		var RCAudioUpload: RCAudioUpload?
		
		init(audioPlayer: AVAudioPlayer, in RCAudioUpload: RCAudioUpload) {
			super.init(frame: RCAudioUpload.view.bounds)
			self.audioPlayer = audioPlayer
			self.RCAudioUpload = RCAudioUpload
			
			self.backgroundColor = UIColor.clear
			UIView.animate(withDuration: 0.8, animations: {
				self.backgroundColor = UIColor(named: "Lighter Grey")
			}) { (complete) in
				let margin: CGFloat = 16
				let height = self.frame.height  - (margin * 2)
				let width = (self.frame.width - (margin * 3)) / 2
				let playButton = UIButton(frame: CGRect(x: margin, y: (self.frame.height - height) / 2, width: width, height: height))
				let trashButton = UIButton(frame: CGRect(x: (margin * 2) + width, y: (self.frame.height - height) / 2, width: width, height: height))
				playButton.layer.cornerRadius = 12
				trashButton.layer.cornerRadius = 12
				playButton.tintColor = UIColor(named: "Orbita Blue")
				trashButton.tintColor = UIColor.white
				playButton.setImage(UIImage(named: "Play"), for: .normal)
				trashButton.setImage(UIImage(named: "Trash"), for: .normal)
				playButton.backgroundColor = UIColor.white
				trashButton.backgroundColor = UIColor.red
				playButton.alpha = 0
				trashButton.alpha = 0
				playButton.addTarget(self, action: #selector(self.play(sender:)), for: .touchUpInside)
				trashButton.addTarget(self, action: #selector(self.dismiss(sender:)), for: .touchUpInside)
				self.addSubview(playButton)
				self.addSubview(trashButton)
				
				UIView.animate(withDuration: 0.15, animations: {
					playButton.alpha = 1
					trashButton.alpha = 1
				})
			}
		}
		
		@objc func play(sender: UIButton) {
			audioPlayer!.play()
		}
		
		@objc func dismiss(sender: UIButton) {
			RCAudioUpload!.dismissAudioPlayerView()
		}
		
		required init?(coder aDecoder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		class AudioPlayerButton: UIButton {
			override var isHighlighted: Bool {
				didSet {
					if isHighlighted {
						tintColor = UIColor.white
					}
				}
			}
		}
	}
}
