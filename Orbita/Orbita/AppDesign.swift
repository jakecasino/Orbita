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
