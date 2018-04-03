//
//  ResponseCard.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit

class ResponseCardViewController: UIViewController {
	var header: ResponseCardHeader?
	var isMaximized: Bool?
	var minimumHeight: CGFloat?
	
	var ChatViewController: ChatViewController?
	var ResponseCardListCollectionViewController: ResponseCardListCollectionViewController?
	
	@IBOutlet weak var Body: UIView!
	
	override func viewDidLoad() {
		initialize()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let view = segue.destination as? ResponseCardListCollectionViewController {
			ResponseCardListCollectionViewController = view
		}
	}
	
	func initialize() {
		minimumHeight = 300
		ResponseCard("Minimize Window")
		ResponseCard("Toggle Content Interaction")
	}
	
	func get(_ object: String) -> Any? {
		switch object {
		case "Minimum Stop for Card":
			let margin: CGFloat = 16
			return (ChatViewController?.view.frame.height)! - (ChatViewController?.ChatToolbar.frame.height)! - margin - minimumHeight!
		case "Maximum Stop for Card":
			let margin: CGFloat = 16
			return (ChatViewController?.view.safeAreaInsets.top)! + margin
		case "Maximum Height for Card":
			return (ChatViewController?.view.frame.height)! - (get("Maximum Stop for Card") as! CGFloat) - (ChatViewController?.ChatToolbar.frame.height)! - 16
		default:
			return nil
		}
	}
	
	func showResponseCard(header: ResponseCardHeader, footer: ResponseCardFooter?, minimumHeight: CGFloat) {
		let margin: CGFloat = 16
		let ChatViewFrame = ChatViewController?.view.frame
		let ResponseCard = ChatViewController?.ResponseCard
		ResponseCard?.frame = CGRect(x: margin, y: (ChatViewFrame?.height)!, width: (ChatViewFrame?.width)! - (margin * 2), height: minimumHeight)
		UIView.animate(withDuration: 0.3) {
			self.ChatViewController?.ResponseCard.alpha = 1
			self.ChatViewController?.ResponseCard.frame.origin.y = (self.ChatViewController?.view.frame.height)! - (self.ChatViewController?.ResponseCard.frame.height)! - (self.ChatViewController?.ChatToolbar.frame.height)! - margin
		}
		
		func createHeader() {
			header.title.frame = CGRect(x: 16, y: 12, width: header.title.frame.width, height: header.title.frame.height)
			let shadow = UIView(frame: CGRect(x: 0, y: 0, width: (ResponseCard?.frame.width)!, height: header.title.frame.height + 24))
			shadow.backgroundColor = UIColor.white
			shadow.layer.shadowPath = UIBezierPath(rect: shadow.bounds).cgPath
			shadow.layer.shadowColor = UIColor.black.cgColor
			shadow.layer.shadowOpacity = 0.5
			shadow.layer.masksToBounds = false
			shadow.layer.shadowOffset = CGSize(width: 0, height: -4)
			ResponseCard?.addSubview(shadow)
			ResponseCard?.addSubview(header.title)
		}
		
		createHeader()
		
		Body.frame = CGRect(x: 0, y: header.title.frame.height + 24, width: (ResponseCard?.frame.width)!, height: (ResponseCard?.frame.height)!)
		ResponseCardListCollectionViewController?.collectionView.reloadData()
	}
	
	func ResponseCard(_ action: String) {
		switch action {
		case "Maximize Window":
			var ResponseCard = ChatViewController?.ResponseCard.frame
			ResponseCard = CGRect(x: (ResponseCard?.origin.x)!, y: get("Maximum Stop for Card") as! CGFloat, width: (ResponseCard?.width)!, height: get("Maximum Height for Card") as! CGFloat)
			isMaximized = true
			return
		case "Minimize Window":
			ChatViewController?.ResponseCard.frame = CGRect(x: (ChatViewController?.ResponseCard.frame.origin.x)!, y: get("Minimum Stop for Card") as! CGFloat, width: (ChatViewController?.ResponseCard.frame.width)!, height: minimumHeight!)
			isMaximized = false
			return
		case "Toggle Content Interaction":
			if isMaximized! {
				Body.isUserInteractionEnabled = true
			} else {
				Body.isUserInteractionEnabled = false
			}
		case "Window State Did Change":
			let upperThreshold = minimumHeight! * 1.4
			if (ChatViewController?.ResponseCard.frame.height)! > upperThreshold {
				ResponseCard("Maximize Window")
			} else {
				ResponseCard("Minimize Window")
			}
			ResponseCard("Toggle Content Interaction")
			return
		case "Dismiss":
			ChatViewController?.remove("Response Card")
			return
		default:
			return
		}
	}

}
