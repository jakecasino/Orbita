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
		view.backgroundColor = UIColor(named: "Light Grey")
		
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

