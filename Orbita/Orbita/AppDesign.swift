//
//  AppDesign.swift
//  Orbita
//
//  Created by Jake Casino on 4/28/18.
//

import UIKit

enum constraints {
	case deviceWidth
	case deviceHeight
	case contentSpacing
	case contentWidth
}

enum sizes {
	case small
	case medium
	case large
}

enum colors {
	case lighterGrey
	case lightGrey
	case orbitaBlue
}

enum glyphs {
	case checkmark
	case play
	case send
	case skip
	case skipBack
}

func constraint(_ object: constraints) -> CGFloat {
	switch object {
	case .deviceWidth:
		return UIScreen.main.bounds.width
	case .deviceHeight:
		return UIScreen.main.bounds.height
	case .contentSpacing:
		return spacing(.medium)
	case .contentWidth:
		return constraint(.deviceWidth) - (constraint(.contentSpacing) * 2)
	}
}

func color(_ color: colors) -> UIColor {
	switch color {
	case .lighterGrey:
		return UIColor(named: "Lighter Grey")!
	case .lightGrey:
		return UIColor(named: "Light Grey")!
	case .orbitaBlue:
		return UIColor(named: "Orbita Blue")!
	}
}

func spacing(_ size: sizes) -> CGFloat {
	switch size {
	case .small:
		return 8
	case .medium:
		return 16
	case .large:
		return 24
	}
}

func glyph(_ glyph: glyphs) -> UIImage {
	switch glyph {
	case .checkmark:
		return UIImage(named: "Checkmark")!
	case .play:
		return UIImage(named: "Play")!
	case .send:
		return UIImage(named: "Send")!
	case .skip:
		return UIImage(named: "Skip")!
	case .skipBack:
		return UIImage(named: "Skip Back")!
	}
}

func cornerRadius(_ size: sizes) -> CGFloat {
	switch size {
	case .small:
		return 6
	case .medium:
		return 12
	case .large:
		return 18
	}
}

func roundedCorners(size: CGFloat) -> CGFloat {
	return size / 2
}


extension UIView {
	
	func moveTo(x: CGFloat?, y: CGFloat?) {
		var ELECT_X = frame.origin.x
		var ELECT_Y = frame.origin.y
		
		if let x = x { ELECT_X = x }
		if let y = y { ELECT_Y = y }
		
		frame.origin = CGPoint(x: ELECT_X, y: ELECT_Y)
	}
	
	func resizeTo(width: CGFloat?, height: CGFloat?) {
		var ELECT_WIDTH = frame.size.width
		var ELECT_HEIGHT = frame.size.height
		
		if let width = width { ELECT_WIDTH = width }
		if let height = height { ELECT_HEIGHT = height }
		
		frame.size = CGSize(width: ELECT_WIDTH, height: ELECT_HEIGHT)
	}
	
	func setFrame(equalTo view: UIView) {
		frame = view.frame
	}
	
	func setOrigin(equalTo view: UIView) {
		frame.origin = view.frame.origin
	}
	
	func setSize(equalTo view: Any) {
		if let view = view as? UIView {
			frame.size = view.frame.size
		} else if let size = view as? CGSize {
			frame.size = size
		} else if let rect = view as? CGRect {
			frame.size = rect.size
		}
	}
	
	func visualSetup(backgroundColor: UIColor?, cornerRadius: CGFloat?, masksToBounds: Bool?, alpha: CGFloat?) {
		if let color = backgroundColor { self.backgroundColor = color }
		if let radius = cornerRadius { self.layer.cornerRadius = radius }
		if let masksToBounds = masksToBounds { self.layer.masksToBounds = masksToBounds }
		if let alpha = alpha { self.alpha = alpha }
	}
	
	func createShadow(opacity: Float, offset: CGSize, cornerRadius: CGFloat, shadowRadius: CGFloat) {
		backgroundColor = UIColor.white
		layer.shadowColor = UIColor.black.cgColor
		layer.cornerRadius = cornerRadius
		layer.masksToBounds = false
		layer.shadowRadius = shadowRadius
		layer.shadowOffset = offset
		layer.shadowOpacity = opacity
	}
}
