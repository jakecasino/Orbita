//
//  ChatViewController.swift
//  Orbita
//
//  Created by Jake Casino on 4/27/18.
//

import UIKit

struct Message {
	let sender: String!
	let message: String!
}

class ChatViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
	private let reuseIdentifier = "Cell"
	
	init(withMessages messages: [Message]) {
		super.init(nibName: nil, bundle: nil)
		
		let layout = UICollectionViewFlowLayout()
		layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
		
		collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		collectionView!.backgroundColor = color(.lighterGrey)
		collectionView!.allowsSelection = false
		collectionView!.alwaysBounceVertical = true
		
		self.collectionView!.register(ChatBubble.self, forCellWithReuseIdentifier: reuseIdentifier)
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
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatBubble
		cell.setupVisualLayout()
		cell.moveTo(x: spacing(.medium), y: nil)
    
        return cell
    }
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		let size = collectionView.frame.width * 0.7
		return CGSize(width: size, height: 115)
	}
}

class ChatBubble: UICollectionViewCell {
	var scrubber = RCScrubberBar(frame: CGRect.zero)
	var playButton = RCButton(type: RCButton.types.glyph, size: CGSize(width: 44, height: 44))
	var skipButton = RCButton(type: RCButton.types.glyph, size: CGSize(width: 44, height: 44))
	var skipBackButton = RCButton(type: RCButton.types.glyph, size: CGSize(width: 44, height: 44))
	
	func setupVisualLayout() {
		backgroundColor = UIColor.white
		layer.cornerRadius = cornerRadius(.medium)
		
		addSubview(scrubber)
		
		playButton.setImage(glyph(.play), for: .normal)
		playButton.moveTo(x: (bounds.width - playButton.frame.width) / 2, y: scrubber.frame.origin.x + scrubber.frame.height + spacing(.large))
		addSubview(playButton)
		
		skipBackButton.setImage(glyph(.skipBack), for: .normal)
		skipBackButton.moveTo(x: (playButton.frame.origin.x - skipButton.frame.width) / 2, y: playButton.frame.origin.y)
		
		skipButton.setImage(glyph(.skip), for: .normal)
		skipButton.moveTo(x: playButton.frame.origin.x + playButton.frame.width + skipBackButton.frame.origin.x, y: playButton.frame.origin.y)
		
		addSubview(skipButton)
		addSubview(skipBackButton)
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
