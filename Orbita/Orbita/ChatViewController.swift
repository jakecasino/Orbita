//
//  ViewController.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit

class ChatViewController: UIViewController {
	var ChatToolbarViewController: ChatToolbarViewController?
	var ResponseCardViewController: ResponseCardViewController?
	@IBOutlet weak var ResponseCard: UIView!
	@IBOutlet weak var ChatToolbar: UIView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let view = segue.destination as? ResponseCardViewController {
			ResponseCardViewController = view
			ResponseCardViewController?.ChatViewController = self
		}
		if let view = segue.destination as? ChatToolbarViewController {
			ChatToolbarViewController = view
			ChatToolbarViewController?.ResponseCardViewController = ResponseCardViewController
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		initialize()
	}
	
	func initialize() {
		generate("Chat Toolbar")
		generate("Touch Interactions")
		ResponseCard.alpha = 0
	}

	func generate(_ object: String) {
		switch object {
		case "Chat Toolbar":
			ChatToolbar.frame.size = CGSize(width: view.frame.width, height: 108 + view.safeAreaInsets.bottom)
			ChatToolbar.frame.origin = CGPoint(x: 0, y: view.frame.height - ChatToolbar.frame.height)
			return
		case "Touch Interactions":
			ResponseCard.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(ResponseCardWasDragged(gesture:))))
		default:
			return
		}
	}
	
	func remove(_ object: String) {
		switch object {
		case "Response Card":
			UIView.animate(withDuration: 0.3) {
				self.ResponseCard.alpha = 0
				self.ResponseCard.frame.origin.y = self.view.frame.height
			}
			return
		default:
			return
		}
	}
	
	@objc private func ResponseCardWasDragged(gesture: UIPanGestureRecognizer) {
		if gesture.state == .changed {
			let translation = gesture.translation(in: self.view)
			let newPosition = (gesture.view?.frame.origin.y)! + translation.y
			let minimumHeight = ResponseCardViewController?.get("Minimum Stop for Card") as! CGFloat + 24
			if newPosition > view.safeAreaInsets.top {
				if newPosition < minimumHeight {
					gesture.view?.frame.origin = CGPoint(x: (gesture.view?.frame.origin.x)!, y: newPosition)
					gesture.view?.frame.size = CGSize(width: (gesture.view?.frame.width)!, height: (gesture.view?.frame.height)! - translation.y)
					gesture.setTranslation(CGPoint.zero, in: self.view)
				}
			}
		}
		if gesture.state == .ended {
			UIView.animate(withDuration: 0.3) {
				self.ResponseCardViewController?.ResponseCard("Window State Did Change")
			}
		}
	}

}

