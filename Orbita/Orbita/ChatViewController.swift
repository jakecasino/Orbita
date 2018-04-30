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
		collectionView!.backgroundColor = UIColor(named: "Lighter Grey")
		collectionView!.allowsSelection = false
		collectionView!.alwaysBounceVertical = true
		
		self.collectionView!.register(ChatBubble.self, forCellWithReuseIdentifier: reuseIdentifier)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func didMove(toParentViewController parent: UIViewController?) {
		if let main = parent as? MainViewController {
			main.view.addSubview(collectionView!)
			main.view.sendSubview(toBack: collectionView!)
			collectionView!.frame = main.view.frame
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
		
		cell.frame.origin = CGPoint(x: spacing(.medium), y: cell.frame.origin.y)
    
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
		layer.cornerRadius = 12
		
		addSubview(scrubber)
		
		playButton.setImage(glyph(.play), for: .normal)
		playButton.frame.origin = CGPoint(x: (bounds.width - playButton.frame.width) / 2, y: scrubber.frame.origin.x + scrubber.frame.height + spacing(.large))
		addSubview(playButton)
		
		skipBackButton.setImage(glyph(.skipBack), for: .normal)
		skipBackButton.frame.origin = CGPoint(x: (playButton.frame.origin.x - skipButton.frame.width) / 2, y: playButton.frame.origin.y)
		
		skipButton.setImage(glyph(.skip), for: .normal)
		skipButton.frame.origin = CGPoint(x: playButton.frame.origin.x + playButton.frame.width + skipBackButton.frame.origin.x, y: playButton.frame.origin.y)
		
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
		frame.size = size
		
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
		frame.origin = CGPoint(x: spacing(.medium), y: spacing(.large))
		if let superview = superview {
			frame.size = CGSize(width: superview.bounds.width - (spacing(.medium) * 2), height: 6)
			
			cap.frame.size = CGSize(width: (bounds.width * 0.05), height: bounds.height)
			addSubview(cap)
		}
		
		// Design setup
		backgroundColor = color(.lighterGrey)
		layer.cornerRadius = frame.height / 2
		layer.masksToBounds = true
		
		cap.backgroundColor = color(.orbitaBlue)
		cap.layer.cornerRadius = layer.cornerRadius
	}
}
