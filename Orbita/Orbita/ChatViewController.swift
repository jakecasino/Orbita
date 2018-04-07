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
	var RCResponseCardShadow: RCResponseCardViewShadow?
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
	
	func showResponseCard(RCHeader: RCHeader, RCBody: RCBody, footer: RCFooter?) {
		dismissResponseCard()
		
		// Initialize RCViewController
		self.RCViewController = RCResponseCardViewController(with: RCBody.RCBodyTemplate!)
		self.RCViewController!.ChatViewController = self
		
		// Initialize RCResponseCard
		guard RCViewController != nil else { return }
		RCResponseCard = RCResponseCardView(frame: CGRect(x: RCViewController!.constraint(for: .marginLeft, in: self), y: view.frame.height, width: RCViewController!.constraint(for: .width, in: self), height: RCViewController!.minimumHeight!))
		RCResponseCard!.backgroundColor = UIColor(named: "Light Grey")
		RCResponseCard!.layer.cornerRadius = 12
		RCResponseCard!.layer.masksToBounds = true
		view.insertSubview(RCResponseCard!, belowSubview: ChatToolbar)
		
		RCResponseCard!.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(RCResponseCardWasDragged(gesture:))))
		RCResponseCard!.RCHeader = RCHeader
		RCResponseCard!.RCBodyView = RCBody
		
		// Create shadow for RCResponseCard
		RCResponseCardShadow = RCResponseCardViewShadow(frame: RCResponseCard!.frame)
		RCResponseCardShadow!.backgroundColor = UIColor.white
		RCResponseCardShadow!.layer.shadowColor = UIColor.black.cgColor
		RCResponseCardShadow!.layer.cornerRadius = RCResponseCard!.layer.cornerRadius
		RCResponseCardShadow!.layer.shadowOpacity = 0.15
		RCResponseCardShadow!.layer.shadowRadius = 2
		RCResponseCardShadow!.layer.masksToBounds = false
		RCResponseCardShadow!.layer.shadowOffset = CGSize.zero
		view.insertSubview(RCResponseCardShadow!, belowSubview: RCResponseCard!)
		
		// Connect RCViewController to ChatViewController and RCResponseCard
		guard RCResponseCard != nil else { return }
		RCViewController!.willMove(toParentViewController: self)
		RCResponseCard!.addSubview(RCViewController!.view)
		addChildViewController(RCViewController!)
		RCViewController!.didMove(toParentViewController: self)
		RCResponseCard!.alpha = 0
		
		// Add RCBody
		RCBody.addRCBody(to: RCResponseCard!, in: RCViewController!)
		
		// Add RCHeader
		RCViewController!.view.addSubview(RCHeader.shadow!)
		RCViewController!.view.addSubview(RCHeader)
		
		// Display RCResponseCard
		UIView.animate(withDuration: 0.3) {
			self.RCResponseCard!.alpha = 1
			self.RCResponseCard!.frame = CGRect(x: self.RCResponseCard!.frame.origin.x, y: self.RCViewController!.constraint(for: .originYwhenMinimized, in: self), width: self.RCResponseCard!.frame.width, height: self.RCResponseCard!.frame.height)
			self.RCResponseCardShadow!.frame = self.RCResponseCard!.frame
		}
	}
	
	func dismissResponseCard() {
		if RCResponseCard != nil {
			UIView.animate(withDuration: 0.3, animations: {
				self.RCResponseCard!.alpha = 0
				self.RCResponseCardShadow!.alpha = 0
			}) { (finished: Bool) in
				for view in self.view.subviews {
					if let RCResponseCardView = view as? RCResponseCardView {
						RCResponseCardView.removeFromSuperview()
						self.RCResponseCard = nil
					}
					if let RCResponseCardViewShadow = view as? RCResponseCardViewShadow {
						RCResponseCardViewShadow.removeFromSuperview()
						self.RCResponseCardShadow = nil
					}
				}
				for childViewController in self.childViewControllers {
					if let RCResponseCardViewController = childViewController as? RCResponseCardViewController {
						RCResponseCardViewController.removeFromParentViewController()
						self.RCViewController = nil
					}
				}
			}
		}
	}
	
	@objc private func RCResponseCardWasDragged(gesture: UIPanGestureRecognizer) {
		if gesture.state == .changed {
			let translation = gesture.translation(in: self.view)
			let newPosition = gesture.view!.frame.origin.y + translation.y
			let minimumStop = RCViewController!.constraint(for: .originYwhenMinimized, in: self) + 24
			if newPosition > RCViewController!.constraint(for: .originYwhenMaximized, in: self) {
				if newPosition < minimumStop {
					let newFrame = CGRect(x: gesture.view!.frame.origin.x, y: newPosition, width: gesture.view!.frame.width, height: gesture.view!.frame.height - translation.y)
					RCResponseCard!.frame = newFrame
					self.RCResponseCardShadow!.frame = self.RCResponseCard!.frame
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

