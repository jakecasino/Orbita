//
//  ChatViewController.swift
//  Orbita
//
//  Created by Jake Casino on 4/27/18.
//

import UIKit

struct RCChatBubble {
	let sender: String!
	let type: RCChatBubbleTypes!
	let content: Any!
}

enum RCChatBubbleTypes {
	case incomingText
	case outgoingText
	case chatbotThinking
	case audioFile
}

class ConversationThreadViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
	private let BUBBLE_TEXT = "cell0"
	private let BUBBLE_CHATBOT_THINKING = "cell1"
	private let BUBBLE_AUDIO = "cell2"
	var content = [RCChatBubble]()
	
	init(_ content: [RCChatBubble]) {
		super.init(nibName: nil, bundle: nil)
		self.content = content
		
		let layout = UICollectionViewFlowLayout()
		layout.sectionInset = UIEdgeInsets(top: spacing(.medium), left: spacing(.medium), bottom: spacing(.medium), right: spacing(.medium))
		layout.minimumLineSpacing = spacing(.extraSmall)
		
		collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		collectionView!.backgroundColor = UIColor.whiteF2
		collectionView!.allowsSelection = false
		collectionView!.alwaysBounceVertical = true
		
		self.collectionView!.register(RCChatBubbleText.self, forCellWithReuseIdentifier: BUBBLE_TEXT)
		self.collectionView!.register(RCChatBubbleChatbotThinking.self, forCellWithReuseIdentifier: BUBBLE_CHATBOT_THINKING)
		self.collectionView!.register(RCChatBubbleAudioFile.self, forCellWithReuseIdentifier: BUBBLE_AUDIO)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func didMove(toParentViewController parent: UIViewController?) {
		if let main = parent as? MainViewController {
			main.view.addSubview(collectionView!)
			main.view.sendSubview(toBack: collectionView!)
			collectionView!.setFrame(equalTo: main.view)
			sizeToFitConversation()
		}
	}
	
	func sizeToFitConversation() {
		if let parent = parent as? MainViewController {
			collectionView!.resizeTo(width: nil, height: parent.view.bounds.height - parent.chatToolbar.view.frame.height)
			if collectionView!.contentSize.height > collectionView!.bounds.size.height {
				collectionView!.setContentOffset(CGPoint(x: 0, y: (collectionView!.contentSize.height - collectionView!.bounds.size.height)), animated: true)
			}
		}
	}

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return content.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		switch content[indexPath.row].type! {
		case .incomingText:
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BUBBLE_TEXT, for: indexPath) as! RCChatBubbleText
			cell.setup(text: content[indexPath.row].content as! String, source: .incoming)
			return cell
		case .outgoingText:
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BUBBLE_TEXT, for: indexPath) as! RCChatBubbleText
			cell.setup(text: content[indexPath.row].content as! String, source: .outgoing)
			return cell
		case .chatbotThinking:
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BUBBLE_CHATBOT_THINKING, for: indexPath) as! RCChatBubbleChatbotThinking
			cell.setup()
			return cell
		case .audioFile:
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BUBBLE_AUDIO, for: indexPath) as! RCChatBubbleAudioFile
			cell.setupVisualLayout()
			return cell
		}
    }
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = collectionView.frame.width - (spacing(.medium) * 2)
		var height: CGFloat
		
		func findBubbleHeight(fromText TEXT: String?) -> CGFloat {
			let text: String
			if let TEXT = TEXT {
				text = TEXT
			} else { text = " " }
			
			let size = CGSize(width: 250, height: 1000.0)
			let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
			let estimatedFrame = NSString(string: text).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedStringKey: UILabel().Raleway(textStyle: .body, weight: .regular)], context: nil)
			return estimatedFrame.height + (spacing(.medium) * 2)
		}
		
		switch content[indexPath.row].type! {
		case .incomingText, .outgoingText:
			height = findBubbleHeight(fromText: (content[indexPath.row].content as! String))
		case .chatbotThinking:
			height = findBubbleHeight(fromText: nil)
		case .audioFile:
			height = 115
		}
		
		return CGSize(width: width, height: height)
	}
	
	override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		if let parent = parent as? MainViewController {
			if parent.chatToolbar.micButton.isSelected {
				parent.chatToolbar.toggleListeningMode()
			}
		}
	}
}

class RCChatBubbleText: UICollectionViewCell {
	func setup(text: String, source: RCChatBubbleTextSources) {
		let size = CGSize(width: 250, height: 1000.0)
		let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
		let estimatedFrame = NSString(string: text).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedStringKey: UILabel().Raleway(textStyle: .body, weight: .regular)], context: nil)
		
		let label = UILabel(frame: CGRect.zero)
		label.resizeTo(width: estimatedFrame.width, height: estimatedFrame.height)
		label.lineBreakMode = .byWordWrapping
		label.numberOfLines = 0
		label.font = label.Raleway(textStyle: .body, weight: .regular)
		label.text = text
		
		switch source {
		case .incoming:
			label.move(x: spacing(.medium), y: spacing(.medium))
			RCSetupChatBubble(width: estimatedFrame.width + (spacing(.medium) * 2), BACKGROUND_COLOR: UIColor.white, alignedRight: false)
			break
		case .outgoing:
			label.move(x: frame.width - label.frame.width - spacing(.medium), y: spacing(.medium))
			label.textColor = UIColor.white
			label.textAlignment = .right
			RCSetupChatBubble(width: estimatedFrame.width + (spacing(.medium) * 2), BACKGROUND_COLOR: UIColor.orbitaBlue, alignedRight: true)
			break
		}
		
		addSubview(label)
	}
}

class RCChatBubbleChatbotThinking: UICollectionViewCell {
	var thinkingDots = [UIView]()
	func setup() {
		
		let numberOfDots = 5
		let dotSize: CGFloat = 5
		let dotSpacing: CGFloat = 10
		let dotPadding = (bounds.height - dotSize) / 2
		let width = (dotSize * CGFloat(numberOfDots)) + ((CGFloat(numberOfDots) - 1) * dotSpacing) + (dotPadding * 2)
		RCSetupChatBubble(width: width, BACKGROUND_COLOR: UIColor.whiteD, alignedRight: false)
		
		
		for index in 0...(numberOfDots - 1) {
			let dot = UIView(frame: CGRect.zero)
			dot.resizeTo(width: dotSize, height: dotSize)
			dot.move(x: dotPadding + (CGFloat(index) * (dotSize + dotSpacing)), y: (bounds.height - dotSize) / 2)
			dot.visualSetup(backgroundColor: UIColor.white, cornerRadius: dotSize / 2, masksToBounds: nil, alpha: nil)
			thinkingDots.append(dot)
			addSubview(dot)
		}
		
		startAnimating()
	}
	
	func startAnimating() {
		
		enum directions {
			case scaleUp
			case scaleDown
		}
		func move(_ direction: directions, index: Int, delay: TimeInterval) {
			switch direction {
			case .scaleUp:
				UIView.animate(withDuration: 0.5, delay: delay, options: .curveLinear, animations: {
					self.thinkingDots[index].transform = CGAffineTransform(scaleX: 2, y: 2)
					//self.thinkingDots[index].backgroundColor = UIColor.white
				}) { (_) in
					move(.scaleDown, index: index, delay: 0)
				}
				break
			case .scaleDown:
				UIView.animate(withDuration: 0.5, delay: delay, options: .curveLinear, animations: {
					self.thinkingDots[index].transform = CGAffineTransform(scaleX: 1, y: 1)
					//self.thinkingDots[index].backgroundColor = color(.orbitaBlue)
				}) { (_) in
					move(.scaleUp, index: index, delay: 0)
				}
				break
			}
		}
		
		move(.scaleUp, index: 0, delay: 0)
		move(.scaleUp, index: 1, delay: 0.67)
		move(.scaleUp, index: 2, delay: 1.42)
		move(.scaleUp, index: 3, delay: 0.86)
		move(.scaleUp, index: 4, delay: 0.23)
		
	}
}

extension UICollectionViewCell {
	enum RCChatBubbleTextSources {
		case incoming
		case outgoing
	}
	func RCSetupChatBubble(width: CGFloat, BACKGROUND_COLOR: UIColor, alignedRight: Bool) {
		let bubble = UIView(frame: bounds)
		bubble.resizeTo(width: width, height: nil)
		if alignedRight { bubble.move(x: bounds.width - width, y: nil) }
		bubble.visualSetup(backgroundColor: BACKGROUND_COLOR, cornerRadius: cornerRadius(.large), masksToBounds: true, alpha: nil)
		addSubview(bubble)
	}
}

class RCChatBubbleAudioFile: UICollectionViewCell {
	var scrubber = RCScrubberBar(frame: CGRect.zero)
	var playButton = RCButton(type: RCButton.types.glyph, size: CGSize(width: 44, height: 44))
	var skipButton = RCButton(type: RCButton.types.glyph, size: CGSize(width: 44, height: 44))
	var skipBackButton = RCButton(type: RCButton.types.glyph, size: CGSize(width: 44, height: 44))
	
	func setupVisualLayout() {
		backgroundColor = UIColor.white
		layer.cornerRadius = cornerRadius(.medium)
		
		addSubview(scrubber)
		addSubview(playButton)
		addSubview(skipButton)
		addSubview(skipBackButton)
		
		playButton.setImage(glyph(.play), for: .normal)
		playButton.move(x: origins.center, y: scrubber.frame.origin.x + scrubber.frame.height + spacing(.large))
		
		skipBackButton.setImage(glyph(.skipBack), for: .normal)
		skipBackButton.move(x: spacing(.large), y: playButton.frame.origin.y)
		
		skipButton.setImage(glyph(.skip), for: .normal)
		skipButton.move(x: origins.right, y: playButton.frame.origin.y)
	}
}

class RCButton: UIButton {
	enum types {
		case glyph
	}
	
	init(type: types, size: CGSize) {
		super.init(frame: CGRect.zero)
		setSize(equalTo: size)
		
		switch type {
		case .glyph:
			tintColor = UIColor.orbitaBlue
			break
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

class RCScrubberBar: UIView {
	var cap = UIView(frame: CGRect.zero)
	
	override func didMoveToSuperview() {
		// Frame setup
		move(x: spacing(.medium), y: spacing(.large))
		if let superview = superview {
			resizeTo(width: superview.bounds.width - (spacing(.medium) * 2), height: 6)
			
			cap.resizeTo(width: bounds.width * 0.05, height: bounds.height)
			addSubview(cap)
		}
		
		// Design setup
		visualSetup(backgroundColor: UIColor.whiteF2, cornerRadius: roundedCorners(size: frame.height), masksToBounds: true, alpha: nil)
		cap.visualSetup(backgroundColor: UIColor.orbitaBlue, cornerRadius: layer.cornerRadius, masksToBounds: nil, alpha: nil)
	}
}
