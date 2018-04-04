//
//  ResponseCard.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit

class ResponseCardViewController: UIViewController {
	
	enum Constraints {
		case margin
		case maximumHeight
		case xOrigin
		case yOrigin
		case yOriginWhenMinimized
		case yOriginWhenMaximized
		case width
		case deviceHeight
		case deviceWidth
	}
	enum ResponseCardTemplates {
		case listWithSingleSelection
	}
	
	var header: UIView?
	var shadow: UIView?
	var isMaximized: Bool?
	var minimumHeight: CGFloat?
	var Body: UIView?
	var BodyTemplate: ResponseCardTemplates?
	var BodyViewController: Any?
	
	var ChatViewController: ChatViewController?
	
	override func viewDidLoad() {
		initialize()
	}
	
	func initialize() {
		minimumHeight = 300
		createResponseCardShadow()
		minimizeCard()
	}
	
	func showResponseCard(headerComponents: ResponseCardHeader, bodyTemplate: ResponseCardTemplates, footer: ResponseCardFooter?, minimumHeight: CGFloat) {
		header = headerComponents.createFrame(in: self)
		Body = UIView(frame: CGRect(x: 0, y: header!.frame.height, width: ChatViewController!.ResponseCard.frame.width, height: (ChatViewController!.ResponseCard.frame.height - header!.frame.height)))
		BodyTemplate = bodyTemplate
		self.minimumHeight = minimumHeight
		
		ChatViewController!.ResponseCard.frame = CGRect(x: get(.margin), y: get(.deviceHeight), width: get(.deviceWidth) - (get(.margin) * 2), height: minimumHeight)
		
		UIView.animate(withDuration: 0.3) {
			self.ChatViewController?.ResponseCard.alpha = 1
			self.ChatViewController?.ResponseCard.frame.origin.y = (self.ChatViewController?.view.frame.height)! - (self.ChatViewController?.ResponseCard.frame.height)! - (self.ChatViewController?.ChatToolbar.frame.height)! - self.get(.margin)
			self.shadow!.frame = self.ChatViewController!.ResponseCard.frame
		}
		
		view.addSubview(Body!)
		generateBody()
		view.addSubview(headerComponents.createShadow(in: self))
		view.addSubview(header!)
	}
	
	func responseCardHeightDidChange() {
		let upperThreshold = get(.deviceHeight) * 0.3
		if get(.yOrigin) < upperThreshold {
			maximizeCard()
		} else {
			minimizeCard()
		}
	}
	
	func generateBody() {
		switch BodyTemplate! {
		case .listWithSingleSelection:
			BodyViewController = ResponseCardListCollectionViewController() as ResponseCardListCollectionViewController
			(BodyViewController as! ResponseCardListCollectionViewController).willMove(toParentViewController: self)
			Body?.addSubview((BodyViewController as! ResponseCardListCollectionViewController).view)
			addChildViewController(BodyViewController as! ResponseCardListCollectionViewController)
			(BodyViewController as! ResponseCardListCollectionViewController).didMove(toParentViewController: self)
			(BodyViewController as! ResponseCardListCollectionViewController).view.frame = CGRect(x: 0, y: 0, width: Body!.frame.width, height: Body!.frame.height)
			(BodyViewController as! ResponseCardListCollectionViewController).collectionView?.frame = (BodyViewController as! ResponseCardListCollectionViewController).view.frame
			(BodyViewController as! ResponseCardListCollectionViewController).collectionView?.reloadData()
			break
		}
	}
	
	func createResponseCardShadow() {
		if shadow != nil {
			self.shadow!.frame = ChatViewController!.ResponseCard.frame
		} else {
			shadow = UIView(frame: ChatViewController!.ResponseCard.frame)
			shadow!.layer.shadowPath = UIBezierPath(roundedRect: shadow!.bounds, cornerRadius: 12).cgPath
			shadow!.layer.shadowColor = UIColor.black.cgColor
			shadow!.layer.cornerRadius = 24
			shadow!.layer.shadowOpacity = 0.15
			shadow!.layer.masksToBounds = false
			shadow!.layer.shadowOffset = CGSize(width: 0, height: 0)
			ChatViewController?.view.insertSubview(shadow!, belowSubview: ChatViewController!.ResponseCard)
		}
	}
	
	func get(_ constraint: Constraints) -> CGFloat {
		let marginTop: CGFloat = 8
		switch constraint {
		case .margin:
			return 16
		case .maximumHeight:
			return get(.deviceHeight) - get(.yOriginWhenMaximized) - ChatViewController!.ChatToolbar.frame.height - marginTop
		case .xOrigin:
			return ChatViewController!.ResponseCard.frame.origin.x
		case .yOrigin:
			return ChatViewController!.ResponseCard.frame.origin.y
		case .yOriginWhenMinimized:
			return get(.deviceHeight) - minimumHeight! - ChatViewController!.ChatToolbar.frame.height - get(.margin)
		case .yOriginWhenMaximized:
			return ChatViewController!.view.safeAreaInsets.top + marginTop
		case .width:
			return ChatViewController!.ResponseCard.frame.width
		case .deviceHeight:
			return ChatViewController!.view.frame.height
		case .deviceWidth:
			return ChatViewController!.view.frame.width
		}
	}
	
	func maximizeCard() {
		ChatViewController?.ResponseCard.frame = CGRect(x: get(.xOrigin), y: get(.yOriginWhenMaximized), width: get(.width), height: get(.maximumHeight))
		isMaximized = true
		shadow!.frame = ChatViewController!.ResponseCard.frame
	}
	
	func minimizeCard() {
		ChatViewController?.ResponseCard.frame = CGRect(x: get(.xOrigin), y: get(.yOriginWhenMinimized), width: get(.width), height: minimumHeight!)
		isMaximized = false
		shadow!.frame = ChatViewController!.ResponseCard.frame
	}
}
