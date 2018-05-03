//
//  MainViewController.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit

class MainViewController: UIViewController {
	var ChatToolbarDelegate: ChatToolbarDelegate?
	var ResponseCard: RCResponseCard?
	var RCViewController: RCDelegate?
	
	@IBOutlet weak var ChatToolbar: UIView!
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let view = segue.destination as? ChatToolbarDelegate {
			ChatToolbarDelegate = view
		}
	}
	
	override func viewDidLoad() {
		
		// Resize Chat Toolbar
		ChatToolbar.frame.size = CGSize(width: view.frame.width, height: 108 + view.safeAreaInsets.bottom)
		ChatToolbar.frame.origin = CGPoint(x: 0, y: view.frame.height - ChatToolbar.frame.height)
		
		let chat = ChatViewController(withMessages: [])
		addChildViewController(chat)
		chat.didMove(toParentViewController: self)
	}
	
	func showResponseCard(RCContent: RCContent) {
		func show() {
			ResponseCard = RCResponseCard(RCContent: RCContent, in: self)
			UIView.animate(withDuration: 0.3) {
			self.ResponseCard!.alpha = 1
			self.ResponseCard!.frame = CGRect(x: self.ResponseCard!.frame.origin.x, y: self.RCViewController!.cardConstraint(.originYwhenMinimized), width: self.ResponseCard!.frame.width, height: self.ResponseCard!.frame.height)
			self.ResponseCard!.shadow!.frame = self.ResponseCard!.frame
			}
		}
		
		// Remove any existing RCResponseCards
		if ResponseCard != nil {
			ResponseCard!.dismiss {
				show()
			}
		} else {
			show()
		}
		
	}
	
	@objc func responseCardWasDragged(gesture: UIPanGestureRecognizer) {
		if gesture.state == .changed {
			let translation = gesture.translation(in: self.view)
			let newPosition = gesture.view!.frame.origin.y + translation.y
			let minimumStop = RCViewController!.cardConstraint(.originYwhenMinimized) + 24
			if newPosition > RCViewController!.cardConstraint(.originYwhenMaximized) {
				if newPosition < minimumStop {
					let newFrame = CGRect(x: gesture.view!.frame.origin.x, y: newPosition, width: gesture.view!.frame.width, height: gesture.view!.frame.height - translation.y)
					ResponseCard!.frame = newFrame
					self.ResponseCard!.shadow!.frame = self.ResponseCard!.frame
					gesture.setTranslation(CGPoint.zero, in: self.view)
					
					if let RCFooter = ResponseCard!.RCContent!.RCFooter {
						RCFooter.frame.origin = CGPoint(x: RCFooter.frame.origin.x, y: ResponseCard!.frame.height - RCFooter.frame.height)
						RCFooter.shadow!.frame.origin = RCFooter.frame.origin
					}
				}
			}
		}
		if gesture.state == .ended {
			self.RCViewController!.RCResponseCardViewDidChange()
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
