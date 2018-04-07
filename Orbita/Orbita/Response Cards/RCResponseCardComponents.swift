//
//  ResponseCardComponents.swift
//  Orbita
//
//  Created by Jake Casino on 4/3/18.
//

import UIKit

class RCHeader: UIView {
	var shadow: UIView?
	
	enum RCHeaderTextStyles {
		case title
		case subtitle
	}
	
	convenience init(title: String, in ChatViewController: ChatViewController) {
		self.init(frame: CGRect(x: 0, y: 0, width: ChatViewController.RCViewController!.constraint(for: .width, in: ChatViewController), height: 0))
		
		let RCHeaderTitle = createRCHeaderUILabel(text: title, type: .title)
		createRCHeaderUIView(RCHeaderTitle: RCHeaderTitle, RCHeaderSubtitle: nil, RCHeaderAction: nil, in: ChatViewController)
	}
	
	convenience init(title: String, subtitle: String, in ChatViewController: ChatViewController) {
		self.init(frame: CGRect(x: 0, y: 0, width: ChatViewController.RCViewController!.constraint(for: .width, in: ChatViewController), height: 0))
		
		let RCHeaderTitle = createRCHeaderUILabel(text: title, type: .title)
		let RCHeaderSubtitle = createRCHeaderUILabel(text: subtitle, type: .subtitle)
		createRCHeaderUIView(RCHeaderTitle: RCHeaderTitle, RCHeaderSubtitle: RCHeaderSubtitle, RCHeaderAction: nil, in: ChatViewController)
	}
	
	convenience init(title: String, button: String, in ChatViewController: ChatViewController) {
		self.init(frame: CGRect(x: 0, y: 0, width: ChatViewController.RCViewController!.constraint(for: .width, in: ChatViewController), height: 0))
		
		let RCHeaderTitle = createRCHeaderUILabel(text: title, type: .title)
		
		let RCHeaderActionButtonSize: CGFloat = 30
		let RCHeaderAction = UIButton(frame: CGRect(x: 0, y: 0, width: RCHeaderActionButtonSize, height: RCHeaderActionButtonSize))
		RCHeaderAction.setImage(UIImage(named: "Send"), for: .normal)
		RCHeaderAction.tintColor = UIColor.white
		RCHeaderAction.backgroundColor = UIColor(named: "Orbita Blue")
		RCHeaderAction.layer.cornerRadius = RCHeaderActionButtonSize / 2
		
		createRCHeaderUIView(RCHeaderTitle: RCHeaderTitle, RCHeaderSubtitle: nil, RCHeaderAction: RCHeaderAction, in: ChatViewController)
	}
	
	deinit {
		shadow = nil
	}
	
	func createRCHeaderUIView(RCHeaderTitle: UILabel, RCHeaderSubtitle: UILabel?, RCHeaderAction: UIButton?, in ChatViewController: ChatViewController) {
		
		// Create main UIView frame
		let padding: CGFloat = 16
		let height = padding + RCHeaderTitle.frame.height + padding
		frame.size = CGSize(width: frame.width, height: height)
		backgroundColor = UIColor.white
		
		// Add RCHeaderComponents
		RCHeaderTitle.frame.origin = CGPoint(x: padding, y: padding)
		addSubview(RCHeaderTitle)
		
		if let RCHeaderSubtitle = RCHeaderSubtitle {
			let x = frame.width - padding - RCHeaderSubtitle.frame.width
			RCHeaderSubtitle.frame.origin = CGPoint(x: x, y: padding)
			addSubview(RCHeaderSubtitle)
		}
		
		if let RCHeaderAction = RCHeaderAction {
			let x = frame.width - padding - RCHeaderAction.frame.width
			let y = (frame.height - RCHeaderAction.frame.height) / 2
			RCHeaderAction.frame.origin = CGPoint(x: x, y: y)
			addSubview(RCHeaderAction)
		}
		
		shadow = UIView(frame: frame)
		shadow!.layer.shadowPath = UIBezierPath(rect: shadow!.bounds).cgPath
		shadow!.layer.shadowColor = UIColor.black.cgColor
		shadow!.layer.shadowOpacity = 0.5
		shadow!.layer.masksToBounds = false
		shadow!.layer.shadowOffset = CGSize(width: 0, height: -4)
	}
	
	func createRCHeaderUILabel(text: String, type: RCHeaderTextStyles) -> UILabel {
		let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
		label.text = text.uppercased()
		label.textColor = UIColor.black
		
		switch type {
		case .title:
			label.font = UIFont.boldSystemFont(ofSize: 12.0)
		case .subtitle:
			label.font = UIFont.preferredFont(forTextStyle: .footnote)
		}
		
		label.sizeToFit()
		return label
	}
}
enum RCBodyTemplates {
	case list
}
class RCBody {
	var RCBodyTemplate: RCBodyTemplates?
	var RCBodyViewController: Any?
	
	init(RCBodyViewController: Any, as template: RCBodyTemplates) {
		switch template {
		case .list:
			self.RCBodyViewController = RCBodyViewController as! RCBodyListViewController
			break
		}
		
		RCBodyTemplate = template
	}
	
	func addRCBody(to RCResponseCard: RCResponseCardView, in RCViewController: RCResponseCardViewController) {
		let view = UIView(frame: CGRect(x: 0, y: RCResponseCard.RCHeader!.frame.height, width: RCViewController.constraint(for: .width, in: RCViewController.ChatViewController!), height: RCViewController.constraint(for: .maximumHeight, in: RCViewController.ChatViewController!) - RCResponseCard.RCHeader!.frame.height))
		
		switch RCBodyTemplate! {
		case .list:
			(RCBodyViewController as! RCBodyListViewController).willMove(toParentViewController: RCViewController)
			(RCBodyViewController as! RCBodyListViewController).view.frame.size = CGSize(width: RCViewController.constraint(for: .width, in: RCViewController.ChatViewController!), height: RCViewController.constraint(for: .maximumHeight, in: RCViewController.ChatViewController!) - RCResponseCard.RCHeader!.frame.height)
			view.addSubview((RCBodyViewController as! RCBodyListViewController).view)
			RCViewController.addChildViewController(RCBodyViewController as! RCBodyListViewController)
			(RCBodyViewController as! RCBodyListViewController).didMove(toParentViewController: RCViewController)
			
			(RCBodyViewController as! RCBodyListViewController).collectionView!.frame.size = view.frame.size
			break
		}
		RCViewController.view.addSubview(view)
	}
	
}
class RCFooter {
	
}
