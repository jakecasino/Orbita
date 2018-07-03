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

extension UIColor {
	class var whiteF2: UIColor { return UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1) }
	class var whiteD: UIColor { return UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1) }
	class var whiteC: UIColor { return UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1) }
	class var orbitaBlue: UIColor { return UIColor(red: 0/255, green: 174/255, blue: 239/255, alpha: 1) }
	
	func brighten(by adjustmentPercentage: CGFloat) -> UIColor {
		return adjustBrightness({ (currentValue) in
			let leftover = rgb.maxValue - currentValue
			let incrementValue = (CGFloat(leftover) * adjustmentPercentage).rounded(.towardZero)
			return (currentValue + incrementValue)
		})
	}
	
	func darken(by adjustmentPercentage: CGFloat) -> UIColor {
		return adjustBrightness({ (currentValue) in
			let incrementValue = (currentValue * adjustmentPercentage).rounded(.towardZero)
			return (currentValue - incrementValue)
		})
	}
	
	private typealias lightenOrDarkenAction = (CGFloat) -> (CGFloat)
	private func adjustBrightness(_ lightenOrDarken: lightenOrDarkenAction) -> UIColor {
		let currentValues = fetchCurrentRGBValues()
		var newValue = [CGFloat]()
		
		currentValues.forEach { (currentValue) in
			newValue.append(lightenOrDarken(currentValue) / rgb.maxValue)
		}
		
		return UIColor(red: newValue[0], green: newValue[1], blue: newValue[2], alpha: 1)
	}
	
	private func fetchCurrentRGBValues() -> [CGFloat] {
		func getRGBValue() -> (red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat)? {
			var fRed : CGFloat = 0
			var fGreen : CGFloat = 0
			var fBlue : CGFloat = 0
			var fAlpha: CGFloat = 0
			if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
				func revert(_ value: CGFloat) -> CGFloat {
					return value * rgb.maxValue
				}
				let iRed = revert(fRed)
				let iGreen = revert(fGreen)
				let iBlue = revert(fBlue)
				let iAlpha = revert(fAlpha)
				
				return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
			} else {
				// Could not extract RGBA components:
				return nil
			}
		}
		
		var currentValues = [CGFloat]()
		_ = getRGBValue()
		currentValues.append(getRGBValue()!.red)
		currentValues.append(getRGBValue()!.green)
		currentValues.append(getRGBValue()!.blue)
		return currentValues
	}
	
	private class rgb {
		class var maxValue: CGFloat { return 255 }
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
					backgroundColor = persistentBackgroundColor.darken(by: 0.15)
					tintColor = persistentTintColor.darken(by: 0.15)
				}
			} else {
				if backgroundColor == UIColor.clear {
					for view in subviews {
						view.alpha = 1.0
					}
				} else {
					backgroundColor = persistentBackgroundColor
					tintColor = persistentTintColor
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
}

extension UIView {
	enum safeAreaInsetConsiderations {
		case top
		case bottom
		case left
		case right
	}
	
	func move(x: Any?, y: Any?) {
		translator(x: x, y: y, considersSafeAreaFrom: nil, safeAreaInsets: [])
	}
	
	func move(x: Any?, y: Any?, considerSafeAreaFrom view: UIView, safeAreaInsets considerations: [safeAreaInsetConsiderations]) {
		translator(x: x, y: y, considersSafeAreaFrom: view, safeAreaInsets: considerations)
	}
	
	func translator(x: Any?, y: Any?, considersSafeAreaFrom view: UIView?, safeAreaInsets considerations: [safeAreaInsetConsiderations]) {
		func origin(from ORIGIN: Any) -> CGFloat {
			var safeArea: CGFloat = 0
			func considerSafeAreaForTopAndBottom() {
				if let view = view {
					considerations.forEach { (consideration) in
						if consideration == .top { safeArea += view.safeAreaInsets.top }
						if consideration == .bottom { safeArea += view.safeAreaInsets.bottom }
					}
				}
			}
			func considerSafeAreaForLeftAndRight() {
				if let view = view {
					considerations.forEach { (consideration) in
						if consideration == .left { safeArea += view.safeAreaInsets.left }
						if consideration == .right { safeArea += view.safeAreaInsets.right }
					}
				}
			}
			if let origin = ORIGIN as? CGFloat {
				return origin
			} else if let ORIGIN = ORIGIN as? origins {
				if let parent = superview {
					switch ORIGIN {
					case .top:
						considerSafeAreaForTopAndBottom()
						return 0 + safeArea
					case .middle:
						considerSafeAreaForTopAndBottom()
						return origin(from: origins.bottom) / 2
					case .bottom:
						considerSafeAreaForTopAndBottom()
						return parent.frame.height - frame.height - safeArea
					case .left:
						considerSafeAreaForLeftAndRight()
						return 0 + safeArea
					case .center:
						considerSafeAreaForLeftAndRight()
						return origin(from: origins.right) / 2
					case .right:
						considerSafeAreaForLeftAndRight()
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
	
	func resizeTo(width: CGFloat?, height: CGFloat?) {
		resizer(width: width, height: height, considersSafeAreaFrom: nil, safeAreaInsets: [])
	}
	
	func resizeTo(width: CGFloat?, height: CGFloat?, considersSafeAreaFrom view: UIView, safeAreaInsets considerations: [safeAreaInsetConsiderations]) {
		resizer(width: width, height: height, considersSafeAreaFrom: view, safeAreaInsets: considerations)
	}
	
	func resizer(width: CGFloat?, height: CGFloat?, considersSafeAreaFrom view: UIView?, safeAreaInsets considerations: [safeAreaInsetConsiderations]) {
		var WIDTH = frame.size.width
		var HEIGHT = frame.size.height
		
		if let width = width {
			var safeArea: CGFloat = 0
			if let view = view {
				considerations.forEach { (consideration) in
					if consideration == .left { safeArea += view.safeAreaInsets.left }
					if consideration == .right { safeArea += view.safeAreaInsets.right }
				}
			}
			WIDTH = width + safeArea
		}
		if let height = height {
			var safeArea: CGFloat = 0
			if let view = view {
				considerations.forEach { (consideration) in
					if consideration == .top { safeArea += view.safeAreaInsets.top }
					if consideration == .bottom { safeArea += view.safeAreaInsets.bottom }
				}
			}
			HEIGHT = height + safeArea
		}
		
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
