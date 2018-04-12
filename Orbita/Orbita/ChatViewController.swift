//
//  ViewController.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit

class ChatViewController: UIViewController {
	var ChatToolbarViewController: ChatToolbarViewController?
	var RCResponseCard: RCResponseCardView?
	var RCViewController: RCResponseCardViewController?
	
	@IBOutlet weak var ChatToolbar: UIView!
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let view = segue.destination as? ChatToolbarViewController {
			ChatToolbarViewController = view
			ChatToolbarViewController!.ChatViewController = self
		}
	}
	
	override func viewDidLoad() {
		// Set background color for ChatView
		view.backgroundColor = UIColor(named: "Lighter Grey")
		
		// Resize Chat Toolbar
		ChatToolbar.frame.size = CGSize(width: view.frame.width, height: 108 + view.safeAreaInsets.bottom)
		ChatToolbar.frame.origin = CGPoint(x: 0, y: view.frame.height - ChatToolbar.frame.height)
	}
	
	func showResponseCard(RCContent: RCContent) {
		func show() {
			RCResponseCard = RCResponseCardView(RCContent: RCContent, in: self)
			UIView.animate(withDuration: 0.3) {
			self.RCResponseCard!.alpha = 1
			self.RCResponseCard!.frame = CGRect(x: self.RCResponseCard!.frame.origin.x, y: self.RCViewController!.constraint(for: .originYwhenMinimized), width: self.RCResponseCard!.frame.width, height: self.RCResponseCard!.frame.height)
			self.RCResponseCard!.shadow!.frame = self.RCResponseCard!.frame
			}
		}
		
		// Remove any existing RCResponseCards
		if RCResponseCard != nil {
			RCResponseCard!.dismiss {
				show()
			}
		} else {
			show()
		}
		
	}
	
	@objc func RCResponseCardWasDragged(gesture: UIPanGestureRecognizer) {
		if gesture.state == .changed {
			let translation = gesture.translation(in: self.view)
			let newPosition = gesture.view!.frame.origin.y + translation.y
			let minimumStop = RCViewController!.constraint(for: .originYwhenMinimized) + 24
			if newPosition > RCViewController!.constraint(for: .originYwhenMaximized) {
				if newPosition < minimumStop {
					let newFrame = CGRect(x: gesture.view!.frame.origin.x, y: newPosition, width: gesture.view!.frame.width, height: gesture.view!.frame.height - translation.y)
					RCResponseCard!.frame = newFrame
					self.RCResponseCard!.shadow!.frame = self.RCResponseCard!.frame
					gesture.setTranslation(CGPoint.zero, in: self.view)
					
					if let RCFooter = RCResponseCard!.RCContent!.RCFooter {
						RCFooter.frame.origin = CGPoint(x: RCFooter.frame.origin.x, y: RCResponseCard!.frame.height - RCFooter.frame.height)
						RCFooter.shadow!.frame.origin = RCFooter.frame.origin
					}
				}
			}
		}
		if gesture.state == .ended {
			UIView.animate(withDuration: 0.3) {
				self.RCViewController!.RCResponseCardViewDidChange()
			}
		}
	}

}

extension UIButton {
	convenience init(for component: RCBarComponent.Forms, action: actions, size: CGFloat) {
		self.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
		
		switch component {
		case .header:
			tintColor = UIColor.white
			backgroundColor = UIColor(named: "Orbita Blue")
			layer.cornerRadius = size / 2
			switch action {
			case .send:
				setImage(UIImage(named: "Send"), for: .normal)
			}
			break
		case .footer:
			break
		}
	}
}
extension UILabel {
	func Raleway(textStyle: UIFontTextStyle, weight: UIFont.Weight) -> UIFont {
		adjustsFontForContentSizeCategory = true
		return UIFontMetrics.default.scaledFont(for: UIFont(Raleway: textStyle, weight: weight)!)
	}
}

extension UIFont {
	convenience init?(Raleway textStyle: UIFontTextStyle, weight: UIFont.Weight) {
		let font: String
		switch weight {
		case .bold:
			font = "Raleway-Bold"
			break
		default:
			font = "Raleway-Regular"
			break
		}
		self.init(name: font, size: (UIFont.preferredFont(forTextStyle: textStyle).pointSize) * 1.1)
	}
}
