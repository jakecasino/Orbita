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
	case extraSmall
	case small
	case medium
	case large
	case extraLarge
}

enum origins {
	case top
	case middle
	case bottom
	case left
	case center
	case right
}

enum colors {
	case lighterGrey
	case lightGrey
	case mediumGrey
	case orbitaBlue
}

enum glyphs {
	case checkmark
	case play
	case send
	case skip
	case skipBack
	case microphone
	case close
	case more
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
	case .mediumGrey:
		return UIColor(named: "Medium Grey")!
	case .orbitaBlue:
		return UIColor(named: "Orbita Blue")!
	}
}

func spacing(_ size: sizes) -> CGFloat {
	switch size {
	case .extraSmall:
		return 4
	case .small:
		return 8
	case .medium:
		return 16
	case .large:
		return 24
	case .extraLarge:
		return 34
	}
}

func ALT_spacing(_ size: sizes) -> CGFloat {
	switch size {
	case .extraSmall:
		return 2
	case .small:
		return 6
	case .medium:
		return 12
	case .large:
		return 18
	case .extraLarge:
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
	case .microphone:
		return UIImage(named: "Microphone")!
	case .close:
		return UIImage(named: "close")!
	case .more:
		return UIImage(named: "More")!
	}
}

func cornerRadius(_ size: sizes) -> CGFloat {
	switch size {
	case .extraSmall:
		return 2
	case .small:
		return 6
	case .medium:
		return 12
	case .large:
		return 18
	case .extraLarge:
		return 24
	}
}

func roundedCorners(size: CGFloat) -> CGFloat {
	return size / 2
}

class Button: UIButton {
	var persistentBackgroundColor: UIColor!
	var persistentTintColor: UIColor!
	override var isHighlighted: Bool {
		didSet {
			if isHighlighted {
				if backgroundColor == UIColor.clear {
					for view in subviews {
						view.alpha = 0.6
					}
				} else {
					if subviews.count != 2 {
						addSubview(overlay(type: .dark))
					}
				}
			} else {
				if backgroundColor == UIColor.clear {
					for view in subviews {
						view.alpha = 1.0
					}
				} else {
					for subview in subviews {
						if let subview = subview as? overlay {
							subview.removeFromSuperview()
						}
					}
				}
			}
		}
	}
	
	convenience init(withGlyph glyph: UIImage, backgroundColor BACKGROUND_COLOR: UIColor, _ TINT_COLOR: UIColor?, cornerRadius: CGFloat?) {
		self.init(frame: CGRect.zero)
		persistentBackgroundColor = BACKGROUND_COLOR
		if let TINT_COLOR = TINT_COLOR {
			persistentTintColor = TINT_COLOR
		} else {
			persistentTintColor = UIColor.white
		}
		
		visualSetup(backgroundColor: persistentBackgroundColor, cornerRadius: cornerRadius, masksToBounds: true, alpha: nil)
		tintColor = persistentTintColor
		
		setImage(glyph, for: .normal)
		adjustsImageWhenHighlighted = false
		
	}
	
	typealias action = () -> ()
	func toggle(isSelected IS_SELECTED: action, isNotSelected IS_NOT_SELECTED: action) {
		if isSelected {
			isSelected = false
			IS_NOT_SELECTED()
		} else {
			isSelected = true
			IS_SELECTED()
		}
	}
	
	class overlay: UIView {
		var type: types!
		enum types {
			case dark
			case light
		}
		convenience init(type TYPE: types) {
			self.init(frame: CGRect.zero)
			type = TYPE
			
			let overlayColor: UIColor
			switch type! {
			case .dark:
				overlayColor = UIColor.black
			case .light:
				overlayColor = UIColor.white
			}
			
			visualSetup(backgroundColor: overlayColor, cornerRadius: nil, masksToBounds: nil, alpha: 0.15)
		}
		override func didMoveToSuperview() {
			if let superview = superview {
				setFrame(equalTo: superview.bounds)
			}
		}
	}
}

extension UIView {
	func translator(x: Any?, y: Any?, considersSafeAreaFrom main: UIView?) {
		func origin(from ORIGIN: Any) -> CGFloat {
			var safeArea: CGFloat = 0
			if let origin = ORIGIN as? CGFloat {
				return origin
			} else if let ORIGIN = ORIGIN as? origins {
				if let parent = superview {
					switch ORIGIN {
					case .top:
						return 0
					case .middle:
						if let main = main {
							safeArea += main.safeAreaInsets.bottom
						}
						return (origin(from: origins.bottom) - safeArea) / 2
					case .bottom:
						return parent.frame.height - frame.height
					case .left:
						return 0
					case .center:
						return origin(from: origins.right) / 2
					case .right:
						return parent.frame.width - frame.width
					}
				} else { return 0 }
			} else { return 0 }
		}
		
		let X: CGFloat
		let Y: CGFloat
		
		if let x = x { X = origin(from: x) }
		else { X = frame.origin.x }
		
		if let y = y { Y = origin(from: y) }
		else { Y = frame.origin.y }
		
		frame.origin = CGPoint(x: X, y: Y)
	}
	
	func move(x: Any?, y: Any?) {
		translator(x: x, y: y, considersSafeAreaFrom: nil)
	}
	
	func move(x: Any?, y: Any?, considerSafeAreaFrom main: UIViewController) {
		translator(x: x, y: y, considersSafeAreaFrom: main.view)
	}
	
	func resizeTo(width: CGFloat?, height: CGFloat?) {
		var WIDTH = frame.size.width
		var HEIGHT = frame.size.height
		
		if let width = width { WIDTH = width }
		if let height = height { HEIGHT = height }
		
		frame.size = CGSize(width: WIDTH, height: HEIGHT)
	}
	
	func setFrame(equalTo view: Any) {
		if let view = view as? UIView {
			frame = view.frame
		} else if let rect = view as? CGRect {
			frame.origin = rect.origin
			frame.size = rect.size
		}
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
	
	func convertToShadow(opacity: Float, offset: CGSize, cornerRadius: CGFloat, shadowRadius: CGFloat) {
		backgroundColor = UIColor.white
		layer.shadowColor = UIColor.black.cgColor
		layer.cornerRadius = cornerRadius
		layer.masksToBounds = false
		layer.shadowRadius = shadowRadius
		layer.shadowOffset = offset
		layer.shadowOpacity = opacity
	}
}
