//
//  ChatToolbarViewController.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit

class ChatToolbarDelegate: UIViewController {
	var setupIncomplete = true
	
	var toolbar: Toolbar!
	var micButton: MicButton!
	var more: Button!
	
	var speakerGrills = [UIView]()
	let grillWidth: CGFloat = 4
	let grillHeight: CGFloat = spacing(.extraSmall)
	let grillSpacing = ALT_spacing(.small)
	
	override func viewDidLoad() {
		let numberOfGrills: Int
		let estimatedNumberOfGrills = Int((((view.bounds.width - MicButton.sizes.minimized) / 2) - ALT_spacing(.extraLarge)) / (grillWidth + grillSpacing)) * 2
		if (estimatedNumberOfGrills % 2) == 0 {
			numberOfGrills = estimatedNumberOfGrills
		} else {
			numberOfGrills = estimatedNumberOfGrills - 1
		}
		for _ in 1...numberOfGrills {
			let grill = UIView(frame: CGRect.zero)
			grill.resizeTo(width: grillWidth, height: grillHeight)
			grill.visualSetup(backgroundColor: UIColor.orbitaBlue, cornerRadius: roundedCorners(size: grillWidth), masksToBounds: nil, alpha: nil)
			speakerGrills.append(grill)
		}
	}
	
	override func viewDidLayoutSubviews() {
		if let main = parent as? MainViewController {
			if setupIncomplete {
				let	secondaryButtonSize: CGFloat = 34
				
				view.resizeTo(width: constraint(.deviceWidth), height: (MicButton.sizes.maximized + (spacing(.medium) * 2)), considersSafeAreaFrom: parent!.view, safeAreaInsets: [.bottom])
				view.move(x: nil, y: origins.bottom)
				view.visualSetup(backgroundColor: UIColor.white, cornerRadius: nil, masksToBounds: nil, alpha: nil)
				
				toolbar = Toolbar(frame: CGRect.zero)
				view.addSubview(toolbar)
				
				micButton = MicButton(link: parent!)
				micButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(microphoneTapped(_:))))
				micButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(microphoneTapped(_:))))
				toolbar.addSubview(micButton)
				
				more = Button(withGlyph: glyph(.more), backgroundColor: UIColor.clear, UIColor.whiteC, cornerRadius: nil)
				more.resizeTo(width: secondaryButtonSize, height: secondaryButtonSize)
				toolbar.addSubview(more)
				more.move(x: view.bounds.width - secondaryButtonSize - spacing(.extraLarge), y: (view.bounds.height - main.view.safeAreaInsets.bottom - secondaryButtonSize) / 2)
				more.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShowResponseCard(_:))))
				setupIncomplete = false
			}
			main.conversationThread.collectionView!.resizeTo(width: nil, height: main.view.bounds.height - view.frame.height)
		}
	}
	
	@objc func microphoneTapped(_ sender: UIGestureRecognizer) {
		if sender.state == .began {
			if !micButton.isSelected {
				toggleListeningMode()
			} else {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
					self.toggleListeningMode()
					sender.isEnabled = false
					sender.isEnabled = true
				}
			}
		} else if sender.state == .ended {
			toggleListeningMode()
		}
	}
	
	func toggleListeningMode() {
		enum loops {
			case a
			case b
		}
		func startGrillAnimation(loop: loops, grill: UIView, delay: TimeInterval) {
			switch loop {
			case .a:
				UIView.animate(withDuration: 0.6, delay: delay, options: .curveLinear, animations: {
					grill.resizeTo(width: nil, height: ALT_spacing(.extraLarge))
					grill.move(x: nil, y: origins.middle, considerSafeAreaFrom: self.parent!.view, safeAreaInsets: [.bottom])
				}) { (_) in
					if self.micButton.isSelected {
						startGrillAnimation(loop: .b, grill: grill, delay: 0)
					}
				}
				break
			case .b:
				UIView.animate(withDuration: 0.6, delay: delay, options: .curveLinear, animations: {
					grill.resizeTo(width: nil, height: self.grillHeight)
					grill.move(x: nil, y: origins.middle, considerSafeAreaFrom: self.parent!.view, safeAreaInsets: [.bottom])
				}) { (_) in
					if self.micButton.isSelected {
						startGrillAnimation(loop: .a, grill: grill, delay: 0)
					}
				}
			}
		}
		micButton.toggle()
		switch micButton.isSelected {
		case true:
			for grill in speakerGrills {
				toolbar.insertSubview(grill, belowSubview: micButton)
				grill.move(x: origins.center, y: origins.middle, considerSafeAreaFrom: parent!.view, safeAreaInsets: [.bottom])
				
				let delay = Double(arc4random()) / Double(UINT32_MAX)
				startGrillAnimation(loop: .a, grill: grill, delay: delay)
			}
			UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseInOut], animations: {
				self.view.resizeTo(width: nil, height: 196)
				self.view.move(x: nil, y: origins.bottom)
				if let parent = self.parent as? MainViewController {
					parent.conversationThread.sizeToFitConversation()
				}
				self.toolbar.move(x: nil, y: origins.bottom)
			}, completion: { (_) in
				let sentence = demo.dictation.components(separatedBy: " ")
				let dictationView = UILabel(frame: CGRect.zero)
				self.view.addSubview(dictationView)
				dictationView.resizeTo(width: self.view.bounds.width - (spacing(.large) * 2), height: 100)
				dictationView.move(x: origins.center, y: origins.top)
				dictationView.numberOfLines = 0
				dictationView.textAlignment = .center
				dictationView.text = ""
				
				for (delay, word) in sentence.enumerated() {
					DispatchQueue.main.asyncAfter(deadline: .now() + (Double(delay) * 0.3)) {
						dictationView.text! += (word + " ")
					}
				}
			})
			UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
				self.more.alpha = 0
				
				for (index, grill) in self.speakerGrills.enumerated() {
					if index < (self.speakerGrills.count / 2) {
						let x = ((self.view.bounds.width - MicButton.sizes.minimized) / 2) - ((self.grillWidth + self.grillSpacing) * CGFloat(index + 1))
						grill.move(x: x, y: nil)
					} else {
						let x = ((self.view.bounds.width + MicButton.sizes.minimized) / 2) + ((self.grillWidth + self.grillSpacing) * CGFloat((index - (self.speakerGrills.count / 2)) + 1))
						grill.move(x: x, y: nil)
					}
				}
			}) { (_) in
				self.more.isHidden = true
			}
		case false:
			more.isHidden = false
			view.subviews.forEach { (view) in
				if view is UILabel { view.removeFromSuperview() }
			}
			UIView.animate(withDuration: 0.15) {
				self.view.setFrame(equalTo: self.toolbar)
				self.view.move(x: nil, y: origins.bottom)
				self.toolbar.move(x: nil, y: origins.bottom)
			}
			UIView.animate(withDuration: 0.6) {
				self.more.alpha = 1
			}
			UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: .curveEaseInOut, animations: {
				for grill in self.speakerGrills {
					grill.resizeTo(width: self.grillWidth, height: self.grillHeight)
					grill.move(x: origins.center, y: origins.middle, considerSafeAreaFrom: self.parent!.view, safeAreaInsets: [.bottom])
				}
			}) { (_) in
				self.speakerGrills.forEach({ $0.removeFromSuperview() })
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
	
	class Toolbar: UIView {
		override func didMoveToSuperview() {
			if let superview = superview {
				setFrame(equalTo: superview.bounds)
				visualSetup(backgroundColor: UIColor.white, cornerRadius: nil, masksToBounds: nil, alpha: nil)
			}
		}
	}
	
	class MicButton: Button {
		var parent: UIViewController!
		class var size: sizes { return sizes() }
		class sizes {
			class var minimized: CGFloat { return 44 }
			class var maximized: CGFloat { return 76 }
		}
		
		deinit {
			parent = nil
		}
		
		convenience init(link PARENT: UIViewController) {
			self.init(withGlyph: glyph(.microphone), backgroundColor: UIColor.orbitaBlue, nil, cornerRadius: roundedCorners(size: sizes.maximized))
			resizeTo(width: sizes.maximized, height: sizes.maximized)
			parent = PARENT
		}
		
		override func didMoveToSuperview() {
			move(x: origins.center, y: origins.middle, considerSafeAreaFrom: parent.view, safeAreaInsets: [.bottom])
		}
		
		func toggle() {
			func resizeMicrophone(to size: CGFloat) {
				resizeTo(width: size, height: size)
				layer.cornerRadius = roundedCorners(size: size)
				move(x: origins.center, y: origins.middle, considerSafeAreaFrom: parent.view, safeAreaInsets: [.bottom])
			}
			
			switch isSelected {
			case true:
				UIImpactFeedbackGenerator(style: .medium).impactOccurred()
				isSelected = false
				UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
					resizeMicrophone(to: MicButton.sizes.maximized)
					let inset: CGFloat = 0
					self.imageEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
					self.backgroundColor = self.persistentBackgroundColor
					self.tintColor = self.persistentTintColor
				})
			case false:
				UIImpactFeedbackGenerator(style: .light).impactOccurred()
				isSelected = true
				
				UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
					resizeMicrophone(to: MicButton.sizes.minimized)
					let inset = spacing(.small)
					self.imageEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
					self.backgroundColor = self.persistentTintColor
					self.tintColor = self.persistentBackgroundColor
				})
			}
		}
	}
}

/*
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
	
	func createStack() {
		if let parent = parent {
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
		}
	}
}
*/
