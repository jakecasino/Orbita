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
		ChatToolbar.resizeTo(width: view.bounds.width, height: 108 + view.safeAreaInsets.bottom)
		ChatToolbar.moveTo(x: 0, y: view.bounds.height - ChatToolbar.frame.height)
		
		let chat = ChatViewController(withMessages: [])
		addChildViewController(chat)
		chat.didMove(toParentViewController: self)
	}
	
	func showResponseCard(RCContent: RCContent) {
		ResponseCard = RCResponseCard(RCContent: RCContent, in: self)
		UIView.animate(withDuration: 0.3) { self.ResponseCard!.alpha = 1 }
		self.RCViewController!.RCResponseCardChangeState(to: .minimized)
	}
	
	@objc func responseCardWasDragged(gesture: UIPanGestureRecognizer) {
		if gesture.state == .changed {
			let translation = gesture.translation(in: self.view)
			let newPosition = gesture.view!.frame.origin.y + translation.y
			let minimumStop = RCViewController!.cardConstraint(.originYwhenMinimized) + 24
			if newPosition > RCViewController!.cardConstraint(.originYwhenMaximized) {
				if newPosition < minimumStop {
					ResponseCard!.resizeTo(width: nil, height: gesture.view!.frame.height - translation.y)
					ResponseCard!.moveTo(x: nil, y: newPosition)
					ResponseCard!.shadow!.setFrame(equalTo: ResponseCard!)
					
					gesture.setTranslation(CGPoint.zero, in: self.view)
					
					if let RCFooter = ResponseCard!.RCContent!.RCFooter {
						RCFooter.moveTo(x: nil, y: ResponseCard!.frame.height - RCFooter.frame.height)
						RCFooter.shadow!.setOrigin(equalTo: RCFooter)
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
