//
//  MainViewController.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit

class MainViewController: UIViewController {
	var chat: ChatViewController!
	var ChatToolbar: ChatToolbarDelegate!
	var ResponseCard: RCResponseCard?
	
	override func viewDidLoad() {
		ChatToolbar = ChatToolbarDelegate(nibName: nil, bundle: nil)
		addChildViewController(ChatToolbar)
		view.addSubview(ChatToolbar.view)
		ChatToolbar.didMove(toParentViewController: self)
		
		chat = ChatViewController(Demo().ChatExample1())
		addChildViewController(chat)
		chat.didMove(toParentViewController: self)
	}
	
	func showResponseCard(RCContent: RCContent) {
		func show() {
			ResponseCard = RCResponseCard(content: RCContent, in: self)
			UIView.animate(withDuration: 0.3) { self.ResponseCard!.alpha = 1 }
			ResponseCard!.delegate.changeState(to: .minimized)
		}
		if let ResponseCard = ResponseCard {
			ResponseCard.dismiss {
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
			let minimumStop = ResponseCard!.delegate.cardConstraint(.OriginY_Minimized) + 24
			if newPosition > ResponseCard!.delegate.cardConstraint(.OriginY_Maximized) {
				if newPosition < minimumStop {
					ResponseCard!.resizeTo(width: nil, height: gesture.view!.frame.height - translation.y)
					ResponseCard!.move(x: nil, y: newPosition)
					ResponseCard!.shadow!.setFrame(equalTo: ResponseCard!)
					
					gesture.setTranslation(CGPoint.zero, in: self.view)
					
					if let RCFooter = ResponseCard!.content!.footer {
						RCFooter.move(x: nil, y: origins.bottom)
						RCFooter.shadow!.setOrigin(equalTo: RCFooter)
					}
				}
			}
		}
		if gesture.state == .ended {
			ResponseCard!.delegate.RCResponseCardViewDidChange()
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
