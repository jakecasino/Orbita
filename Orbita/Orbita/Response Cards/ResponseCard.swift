//
//  ResponseCard.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit

class ResponseCardViewController: UIViewController {
	var shadow: UIView?
	var header: ResponseCardHeader?
	var isMaximized: Bool?
	var minimumHeight: CGFloat?
	var Body: UIView?
	
	var ChatViewController: ChatViewController?
	// var ResponseCardListCollectionViewController: ResponseCardListCollectionViewController?
	
	override func viewDidLoad() {
		initialize()
	}
	
	func initialize() {
		minimumHeight = 300
		minimizeCard()
	}
	
	func showResponseCard(headerComponents: ResponseCardHeader, footer: ResponseCardFooter?, minimumHeight: CGFloat) {
		
		let margin: CGFloat = 16
		let ChatViewFrame = ChatViewController?.view.frame
		let ResponseCard = ChatViewController?.ResponseCard
		
		if shadow != nil {
			self.shadow!.frame = ResponseCard!.frame
		} else {
			shadow = UIView(frame: ResponseCard!.frame)
			shadow!.layer.shadowPath = UIBezierPath(roundedRect: shadow!.bounds, cornerRadius: 12).cgPath
			shadow!.layer.shadowColor = UIColor.black.cgColor
			shadow!.layer.cornerRadius = 24
			shadow!.layer.shadowOpacity = 0.15
			shadow!.layer.masksToBounds = false
			shadow!.layer.shadowOffset = CGSize(width: 0, height: 0)
			ChatViewController?.view.insertSubview(shadow!, belowSubview: ChatViewController!.ResponseCard)
		}
		
		ResponseCard?.frame = CGRect(x: margin, y: (ChatViewFrame?.height)!, width: (ChatViewFrame?.width)! - (margin * 2), height: minimumHeight)
		UIView.animate(withDuration: 0.3) {
			self.ChatViewController?.ResponseCard.alpha = 1
			self.ChatViewController?.ResponseCard.frame.origin.y = (self.ChatViewController?.view.frame.height)! - (self.ChatViewController?.ResponseCard.frame.height)! - (self.ChatViewController?.ChatToolbar.frame.height)! - margin
			self.shadow!.frame = ResponseCard!.frame
		}
		
		let header = headerComponents.createFrame(in: self)
		
		Body = UIView(frame: CGRect(x: 0, y: header.frame.height, width: ResponseCard!.frame.width, height: (ResponseCard!.frame.height - header.frame.height)))
		view.addSubview(Body!)
		
		let ResponseCardBodyViewController = ResponseCardListCollectionViewController()
		ResponseCardBodyViewController.willMove(toParentViewController: self)
		Body?.addSubview(ResponseCardBodyViewController.view)
		addChildViewController(ResponseCardBodyViewController)
		ResponseCardBodyViewController.didMove(toParentViewController: self)
		ResponseCardBodyViewController.view.frame = CGRect(x: 0, y: 0, width: Body!.frame.width, height: Body!.frame.height)
		ResponseCardBodyViewController.collectionView?.frame = ResponseCardBodyViewController.view.frame
		
		view.addSubview(headerComponents.createShadow(in: self))
		view.addSubview(header)
	}
	
	func responseCardHeightDidChange() {
		let upperThreshold = ChatViewController!.view.frame.height * 0.3
		if ChatViewController!.ResponseCard.frame.origin.x < upperThreshold {
			maximizeCard()
		} else {
			minimizeCard()
		}
	}
	
	func maximizeCard() {
		let topMargin: CGFloat = 8
		let maximumStop = ChatViewController!.view.safeAreaInsets.top + topMargin
		let maximumHeight = ChatViewController!.view.frame.height - maximumStop - ChatViewController!.ChatToolbar.frame.height - topMargin
		ChatViewController?.ResponseCard.frame = CGRect(x: ChatViewController!.ResponseCard.frame.origin.x, y: maximumStop, width: ChatViewController!.ResponseCard.frame.width, height: maximumHeight)
		isMaximized = true
		shadow!.frame = ChatViewController!.ResponseCard.frame
	}
	
	func minimizeCard() {
		ChatViewController?.ResponseCard.frame = CGRect(x: (ChatViewController?.ResponseCard.frame.origin.x)!, y: ChatViewController!.view.frame.height - minimumHeight!, width: (ChatViewController?.ResponseCard.frame.width)!, height: minimumHeight!)
		isMaximized = false
	}
	
	func ResponseCard(_ action: String) {
		switch action {
		case "Dismiss":
			ChatViewController?.remove("Response Card")
			return
		default:
			return
		}
	}

}
