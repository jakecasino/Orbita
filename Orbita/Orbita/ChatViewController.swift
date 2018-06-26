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
	case audioFile
}

class ChatViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
	private let BUBBLE_TEXT = "cell0"
	private let BUBBLE_AUDIO = "cell1"
	var content = [RCChatBubble]()
	
	init(_ content: [RCChatBubble]) {
		super.init(nibName: nil, bundle: nil)
		self.content = content
		
		let layout = UICollectionViewFlowLayout()
		layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
		
		collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		collectionView!.backgroundColor = color(.lighterGrey)
		collectionView!.allowsSelection = false
		collectionView!.alwaysBounceVertical = true
		
		self.collectionView!.register(RCChatBubbleText.self, forCellWithReuseIdentifier: BUBBLE_TEXT)
		self.collectionView!.register(RCChatBubbleAudioFile.self, forCellWithReuseIdentifier: BUBBLE_AUDIO)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func didMove(toParentViewController parent: UIViewController?) {
		if let Main = parent as? MainViewController {
			Main.view.addSubview(collectionView!)
			Main.view.sendSubview(toBack: collectionView!)
			
			collectionView!.setFrame(equalTo: Main.view)
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
		case .audioFile:
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BUBBLE_AUDIO, for: indexPath) as! RCChatBubbleAudioFile
			cell.setupVisualLayout()
			return cell
		}
    }
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		switch content[indexPath.row].type! {
		case .incomingText, .outgoingText:
			let size = CGSize(width: view.frame.width, height: 1000.0)
			let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
			let estimatedFrame = NSString(string: content[indexPath.row].content as! String).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedStringKey: UILabel().Raleway(textStyle: .body, weight: .regular)], context: nil)
			return CGSize(width: collectionView.frame.width - (spacing(.small) * 2), height: estimatedFrame.height + (spacing(.medium) * 2))
		case .audioFile:
			return CGSize(width: collectionView.frame.width - (spacing(.small) * 2), height: 115)
		}
	}
}

class RCChatBubbleText: UICollectionViewCell {
	func setup(text: String, source: RCChatBubbleTextSources) {
		let size = CGSize(width: 250, height: 1000.0)
		let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
		let estimatedFrame = NSString(string: text).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedStringKey: UILabel().Raleway(textStyle: .body, weight: .regular)], context: nil)
		
		let label = UILabel(frame: CGRect.zero)
		label.lineBreakMode = .byWordWrapping
		label.numberOfLines = 0
		label.font = label.Raleway(textStyle: .body, weight: .regular)
		label.text = text
		
		switch source {
		case .incoming:
			label.resizeTo(width: estimatedFrame.width, height: estimatedFrame.height)
			label.moveTo(x: spacing(.medium), y: spacing(.medium))
			break
		case .outgoing:
			label.resizeTo(width: estimatedFrame.width, height: estimatedFrame.height)
			label.moveTo(x: frame.width - label.frame.width - spacing(.medium), y: spacing(.medium))
			label.textColor = UIColor.white
			break
		}
		
		RCSetupChatBubble(source: source, width: estimatedFrame.width + (spacing(.medium) * 2))
		addSubview(label)
	}
}

extension UICollectionViewCell {
	enum RCChatBubbleTextSources {
		case incoming
		case outgoing
	}
	func RCSetupChatBubble(source: RCChatBubbleTextSources, width: CGFloat) {
		let bubble = UIView(frame: bounds)
		bubble.resizeTo(width: width, height: nil)
		
		let BACKGROUND_COLOR: UIColor
		switch source {
		case .incoming:
			BACKGROUND_COLOR = UIColor.white
		case .outgoing:
			bubble.moveTo(x: bounds.width - width, y: nil)
			BACKGROUND_COLOR = color(.orbitaBlue)
		}
		
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
		playButton.moveTo(x: origins.center, y: scrubber.frame.origin.x + scrubber.frame.height + spacing(.large))
		
		skipBackButton.setImage(glyph(.skipBack), for: .normal)
		skipBackButton.moveTo(x: spacing(.large), y: playButton.frame.origin.y)
		
		skipButton.setImage(glyph(.skip), for: .normal)
		skipButton.moveTo(x: origins.right, y: playButton.frame.origin.y)
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
			tintColor = color(.orbitaBlue)
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
		moveTo(x: spacing(.medium), y: spacing(.large))
		if let superview = superview {
			resizeTo(width: superview.bounds.width - (spacing(.medium) * 2), height: 6)
			
			cap.resizeTo(width: bounds.width * 0.05, height: bounds.height)
			addSubview(cap)
		}
		
		// Design setup
		visualSetup(backgroundColor: color(.lighterGrey), cornerRadius: roundedCorners(size: frame.height), masksToBounds: true, alpha: nil)
		cap.visualSetup(backgroundColor: color(.orbitaBlue), cornerRadius: layer.cornerRadius, masksToBounds: nil, alpha: nil)
	}
}
