//
//  ChatToolbarViewController.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit

class ChatToolbarDelegate: UIViewController {
	var setupIncomplete = true
	
	var microphone: Button!
	let microphoneSize_small: CGFloat = 44
	let microphoneSize_regular: CGFloat = 76
	
	var more: Button!
	
	var speakerGrills = [UIView]()
	let grillWidth: CGFloat = 4
	let grillHeight: CGFloat = spacing(.extraSmall)
	let grillSpacing = ALT_spacing(.small)
	
	override func viewDidLoad() {
		let numberOfGrills: Int
		let estimatedNumberOfGrills = Int((((view.bounds.width - microphoneSize_small) / 2) - ALT_spacing(.extraLarge)) / (grillWidth + grillSpacing)) * 2
		if (estimatedNumberOfGrills % 2) == 0 {
			numberOfGrills = estimatedNumberOfGrills
		} else {
			numberOfGrills = estimatedNumberOfGrills - 1
		}
		for _ in 1...numberOfGrills {
			let grill = UIView(frame: CGRect.zero)
			grill.resizeTo(width: grillWidth, height: grillHeight)
			grill.visualSetup(backgroundColor: color(.orbitaBlue), cornerRadius: roundedCorners(size: grillWidth), masksToBounds: nil, alpha: nil)
			speakerGrills.append(grill)
		}
	}
	
	override func viewDidLayoutSubviews() {
		if let main = parent as? MainViewController {
			if setupIncomplete {
				let	secondaryButtonSize: CGFloat = 34
				
				view.resizeTo(width: constraint(.deviceWidth), height: microphoneSize_regular + main.view.safeAreaInsets.bottom + (spacing(.medium) * 2))
				view.move(x: nil, y: origins.bottom)
				view.visualSetup(backgroundColor: UIColor.white, cornerRadius: nil, masksToBounds: nil, alpha: nil)
				
				microphone = Button(withGlyph: glyph(.microphone), backgroundColor: color(.orbitaBlue), nil, cornerRadius: roundedCorners(size: microphoneSize_regular))
				microphone.resizeTo(width: microphoneSize_regular, height: microphoneSize_regular)
				view.addSubview(microphone)
				microphone.move(x: origins.center, y: (view.bounds.height - main.view.safeAreaInsets.bottom - microphoneSize_regular) / 2)
				microphone.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(microphoneTapped(_:))))
				
				more = Button(withGlyph: glyph(.more), backgroundColor: UIColor.clear, color(.mediumGrey), cornerRadius: nil)
				more.resizeTo(width: secondaryButtonSize, height: secondaryButtonSize)
				view.addSubview(more)
				more.move(x: view.bounds.width - secondaryButtonSize - spacing(.extraLarge), y: (view.bounds.height - main.view.safeAreaInsets.bottom - secondaryButtonSize) / 2)
				more.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShowResponseCard(_:))))
				setupIncomplete = false
			}
			main.chat.collectionView!.resizeTo(width: nil, height: main.view.bounds.height - view.frame.height)
		}
	}
	
	@objc func microphoneTapped(_ sender: Any) {
		/* if let parent = parent {
			view.subviews.forEach({
				if let view = $0 as? SpeakingAnimation {
					view.removeFromSuperview()
				}
			})
			var ticks = [UIView]()
			let tickWidth: CGFloat = 4
			let tickSpacing: CGFloat = 8
			
			let numberOfTicks: Int = Int((view.bounds.width - (spacing(.large) * 2)) / (tickWidth + tickSpacing))
			for _ in 1...numberOfTicks {
				let tick = UIView(frame: CGRect.zero)
				tick.resizeTo(width: tickWidth, height: nil)
				tick.visualSetup(backgroundColor: color(.orbitaBlue), cornerRadius: roundedCorners(size: tickWidth), masksToBounds: nil, alpha: nil)
				ticks.append(tick)
			}
			
			let speakingAnimation = SpeakingAnimation(arrangedSubviews: ticks)
			speakingAnimation.axis = .horizontal
			speakingAnimation.alignment = .fill
			speakingAnimation.distribution = .fillEqually
			speakingAnimation.spacing = tickSpacing
			speakingAnimation.ticks = ticks
			view.addSubview(speakingAnimation)
			speakingAnimation.constrain(to: parent.view)
		} */
		
		func resizeMicrophone(to size: CGFloat) {
			self.microphone.resizeTo(width: size, height: size)
			self.microphone.layer.cornerRadius = roundedCorners(size: size)
			self.microphone.move(x: origins.center, y: origins.middle, considerSafeAreaFrom: parent!)
		}
		
		enum loops {
			case a
			case b
		}
		
		func startGrillAnimation(loop: loops, grill: UIView, delay: TimeInterval) {
			switch loop {
			case .a:
				UIView.animate(withDuration: 0.5, delay: delay, options: .curveLinear, animations: {
					grill.resizeTo(width: nil, height: ALT_spacing(.extraLarge))
					grill.move(x: nil, y: origins.middle, considerSafeAreaFrom: self.parent!)
				}) { (_) in
					if self.microphone.isSelected {
						startGrillAnimation(loop: .b, grill: grill, delay: 0)
					}
				}
				break
			case .b:
				UIView.animate(withDuration: 0.5, delay: delay, options: .curveLinear, animations: {
					grill.resizeTo(width: nil, height: self.grillHeight)
					grill.move(x: nil, y: origins.middle, considerSafeAreaFrom: self.parent!)
				}) { (_) in
					if self.microphone.isSelected {
						startGrillAnimation(loop: .a, grill: grill, delay: 0)
					}
				}
			}
		}
		
		if microphone.isSelected {
			microphone.isSelected = false
			more.isHidden = false
			UIView.animate(withDuration: 2) {
				self.more.alpha = 1
			}
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
				resizeMicrophone(to: self.microphoneSize_regular)
				let inset: CGFloat = 0
				self.microphone.imageEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
				self.microphone.backgroundColor = self.microphone.persistentBackgroundColor
				self.microphone.tintColor = self.microphone.persistentTintColor
				for grill in self.speakerGrills {
					grill.resizeTo(width: self.grillWidth, height: self.grillHeight)
					grill.move(x: origins.center, y: origins.middle, considerSafeAreaFrom: self.parent!)
				}
			}) { (_) in
				self.speakerGrills.forEach({ $0.removeFromSuperview() })
			}
		} else {
			microphone.isSelected = true
			for grill in speakerGrills {
				view.insertSubview(grill, belowSubview: microphone)
				grill.move(x: origins.center, y: origins.middle, considerSafeAreaFrom: parent!)
				
				let delay = Double(arc4random()) / Double(UINT32_MAX)
				startGrillAnimation(loop: .a, grill: grill, delay: delay)
			}
			
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
				resizeMicrophone(to: self.microphoneSize_small)
				let inset = spacing(.small)
				self.microphone.imageEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
				self.microphone.backgroundColor = self.microphone.persistentTintColor
				self.microphone.tintColor = self.microphone.persistentBackgroundColor
				self.more.alpha = 0
				
				for (index, grill) in self.speakerGrills.enumerated() {
					if index < (self.speakerGrills.count / 2) {
						let x = ((self.view.bounds.width - self.microphoneSize_small) / 2) - ((self.grillWidth + self.grillSpacing) * CGFloat(index + 1))
						grill.move(x: x, y: nil)
					} else {
						let x = ((self.view.bounds.width + self.microphoneSize_small) / 2) + ((self.grillWidth + self.grillSpacing) * CGFloat((index - (self.speakerGrills.count / 2)) + 1))
						grill.move(x: x, y: nil)
					}
				}
			}) { (_) in
				self.more.isHidden = true
			}
		}
	}
	
	@objc func ShowResponseCard(_ sender: Any) {
		if let main = parent as? MainViewController {
			
			let alertView = UIAlertController(title: "Response Cards", message: "Which one did you want to see?", preferredStyle: .actionSheet)
			let showSingleSelectionList = UIAlertAction(title: "Single Selection List", style: .default) { (action) in
				let list = ["Lorem", "Ipsum", "Dolor", "Sit Amet", "Consectetur", "Adipiscing", "Elit", "Mauris mollis", "Nisi id tortor", "Blandit", "Nec vestibulum", "Ligula", "Tincidunt"]
				
				let Body = RCList(list: list, canSelectMultipleItems: false)
				let Content = RCContent(RCBody: Body, as: .list, in: main)
				main.showResponseCard(RCContent: Content)
			}
			let showMultipleSelectionList = UIAlertAction(title: "Multiple Selection List", style: .default) { (action) in
				let list = ["Lorem", "Ipsum", "Dolor", "Sit Amet", "Consectetur", "Adipiscing", "Elit", "Mauris mollis", "Nisi id tortor", "Blandit", "Nec vestibulum", "Ligula", "Tincidunt"]
				
				let Body = RCList(list: list, canSelectMultipleItems: true)
				let Content = RCContent(RCBody: Body, as: .list, in: main)
				main.showResponseCard(RCContent: Content)
			}
			let showDiscreteScale = UIAlertAction(title: "Discrete Scale", style: .default) { (action) in
				let Body = RCScale(title: "Pain Level", range: [1,5])
				let Content = RCContent(RCBody: Body, as: .scale, in: main)
				main.showResponseCard(RCContent: Content)
			}
			let showContinuousScale = UIAlertAction(title: "Continuous Scale", style: .default) { (action) in
				let Body = RCScale(title: "Current Mood", range: ["Sad", "Happy"])
				let Content = RCContent(RCBody: Body, as: .scale, in: main)
				main.showResponseCard(RCContent: Content)
			}
			let showImageUpload = UIAlertAction(title: "Image Upload", style: .default) { (action) in
				let Body = RCVisualUpload(title: "Cut", type: RCVisualUpload.mediaTypes.image, enableLive: false)
				let Content = RCContent(RCBody: Body, as: .visualUpload, in: main)
				main.showResponseCard(RCContent: Content)
			}
			let showAudioUpload = UIAlertAction(title: "Audio Upload", style: .default) { (action) in
				let Body = RCAudioUpload(title: "Speech Test")
				let Content = RCContent(RCBody: Body, as: .audioUpload, in: main)
				main.showResponseCard(RCContent: Content)
			}
			let showDatePicker = UIAlertAction(title: "Date Picker", style: .default) { (action) in
				let Body = RCDatePickerController(HeaderTitle: "Birthday", pickerStyle: .date)
				let Content = RCContent(RCBody: Body, as: .datePicker, in: main)
				main.showResponseCard(RCContent: Content)
			}
			alertView.addAction(showSingleSelectionList)
			alertView.addAction(showMultipleSelectionList)
			alertView.addAction(showDiscreteScale)
			alertView.addAction(showContinuousScale)
			alertView.addAction(showImageUpload)
			alertView.addAction(showAudioUpload)
			alertView.addAction(showDatePicker)
			present(alertView, animated: true, completion: nil)
		}
	}
	
	class SpeakingAnimation: UIStackView {
		var ticks = [UIView]()
		deinit {
			ticks.removeAll()
			subviews.forEach { $0.removeFromSuperview() }
		}
		func constrain(to main: UIView) {
			if let superview = superview {
				let tickHeight: CGFloat = 28
				let originY = main.bounds.height - (superview.bounds.height - tickHeight)
				
				translatesAutoresizingMaskIntoConstraints = false
				NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: main, attribute: NSLayoutAttribute.top, multiplier: 1, constant: originY).isActive = true
				NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: main, attribute: NSLayoutAttribute.left, multiplier: 1, constant: ALT_spacing(.extraLarge)).isActive = true
				NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: main, attribute: NSLayoutAttribute.right, multiplier: 1, constant: (ALT_spacing(.extraLarge)) * -1).isActive = true
				heightAnchor.constraint(equalToConstant: tickHeight).isActive = true
			}
		}
	}
}
