//
//  ResponseCard.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit
class ResponseCardHeaderViewController: UIViewController {
	@IBOutlet weak var HeaderTitle: UILabel!
	
	func initialize(title: String) {
		HeaderTitle.text = title
	}
}
class ResponseCardViewController: UIViewController {
	var MainViewController: ChatViewController?
	var WindowState: String?
	var WindowRegularHeight: CGFloat?
	var Header: ResponseCardHeaderViewController?
	@IBOutlet weak var ContentView: UIView!
	
	@IBAction func Action(_ sender: Any) {
		ResponseCard("Dismiss")
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let view = segue.destination as? ResponseCardHeaderViewController {
			Header = view
		}
	}
	
	override func viewDidLoad() {
		initialize()
	}
	
	func initialize() {
		WindowRegularHeight = 300
		ResponseCard("Minimize Window")
		ResponseCard("Toggle Content Interaction")
	}
	
	func get(_ object: String) -> Any? {
		switch object {
		case "Minimum Stop for Card":
			let margin: CGFloat = 16
			return (MainViewController?.view.frame.height)! - (MainViewController?.ChatToolbar.frame.height)! - margin - WindowRegularHeight!
		case "Maximum Stop for Card":
			let margin: CGFloat = 16
			return (MainViewController?.view.safeAreaInsets.top)! + margin
		case "Maximum Height for Card":
			return (MainViewController?.view.frame.height)! - (get("Maximum Stop for Card") as! CGFloat) - (MainViewController?.ChatToolbar.frame.height)! - 16
		default:
			return nil
		}
	}
	
	func ResponseCard(_ action: String) {
		switch action {
		case "Maximize Window":
			MainViewController?.ResponseCard.frame = CGRect(x: (MainViewController?.ResponseCard.frame.origin.x)!, y: get("Maximum Stop for Card") as! CGFloat, width: (MainViewController?.ResponseCard.frame.width)!, height: get("Maximum Height for Card") as! CGFloat)
			WindowState = "maximized"
			return
		case "Minimize Window":
			MainViewController?.ResponseCard.frame = CGRect(x: (MainViewController?.ResponseCard.frame.origin.x)!, y: get("Minimum Stop for Card") as! CGFloat, width: (MainViewController?.ResponseCard.frame.width)!, height: WindowRegularHeight!)
			WindowState = "regular"
			return
		case "Toggle Content Interaction":
			switch WindowState {
			case "regular":
				ContentView.isUserInteractionEnabled = false
				return
			case "maximized":
				ContentView.isUserInteractionEnabled = true
				return
			default:
				return
			}
		case "Window State Did Change":
			let upperThreshold = WindowRegularHeight! * 1.4
			if (MainViewController?.ResponseCard.frame.height)! > upperThreshold {
				ResponseCard("Maximize Window")
			} else {
				ResponseCard("Minimize Window")
			}
			ResponseCard("Toggle Content Interaction")
			return
		case "Dismiss":
			MainViewController?.remove("Response Card")
			return
		default:
			return
		}
	}

}
