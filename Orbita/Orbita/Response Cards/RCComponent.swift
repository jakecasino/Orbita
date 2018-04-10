//
//  ResponseCardComponents.swift
//  Orbita
//
//  Created by Jake Casino on 4/3/18.
//

import UIKit
enum actions {
	case send
}
enum RCBarComponentForms {
	case header
	case footer
}
class RCBarComponent: UIView {
	var ChatViewController: ChatViewController?
	var shadow: UIView?
	var titles = [UILabel]()
	var actions = [UIButton]()
	var RCBarComponentForm: RCBarComponentForms?
	
	enum RCBarComponentTextStyles {
		case title
		case subtitle
	}
	
	convenience init(_ RCBarComponentForm: RCBarComponentForms, labels: [String], actions: [actions], in ChatViewController: ChatViewController) {
		self.init(frame: CGRect.zero)
		self.ChatViewController = ChatViewController
		self.RCBarComponentForm = RCBarComponentForm
		
		func createUILabels(for titles: [String]) {
			func createRCHeaderUILabel(text: String, type: RCBarComponentTextStyles) -> UILabel {
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
			
			switch self.RCBarComponentForm! {
			case .header:
				for (index, text) in titles.enumerated() {
					if index == 0 {
						let title = createRCHeaderUILabel(text: text, type: .title)
						self.titles.append(title)
					} else if index == 1 {
						let subtitle = createRCHeaderUILabel(text: text, type: .subtitle)
						self.titles.append(subtitle)
					} else {
						break
					}
				}
			case .footer:
				break
			}
		}
		
		func createUIButtons(for actions: [actions]) {
			let buttonSize: CGFloat
			switch self.RCBarComponentForm! {
			case .header:
				buttonSize = 30
				break
			case .footer:
				buttonSize = 30
				break
			}
			
			for action in actions {
				let image: UIImage
				switch action {
				case .send:
					image = UIImage(named: "Send")!
					break
				}
				
				let button = UIButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
				button.setImage(image, for: .normal)
				button.addTarget(self, action: #selector(send(sender:)), for: UIControlEvents.touchUpInside)
				
				switch self.RCBarComponentForm! {
				case .header:
					button.tintColor = UIColor.white
					button.backgroundColor = UIColor(named: "Orbita Blue")
					button.layer.cornerRadius = buttonSize / 2
					break
				case .footer:
					break
				}
				
				self.actions.append(button)
			}
		}
		
		createUILabels(for: labels)
		createUIButtons(for: actions)
		
		
		let padding: CGFloat
		
		switch self.RCBarComponentForm! {
		case .header:
			padding = 16
			break
		case .footer:
			padding = 10
			break
		}
		
		let height = padding + titles[0].frame.height + padding
		frame.size = CGSize(width: frame.width, height: height)
		backgroundColor = UIColor.white
		
		shadow = UIView(frame: frame)
		shadow!.createShadow(opacity: 0.15, offset: CGSize(width: 0, height: 0), cornerRadius: 0, shadowRadius: 1)
	}
	
	deinit {
		ChatViewController = nil
		shadow = nil
		RCBarComponentForm = nil
	}
	
	override func didMoveToSuperview() {
		if let superview = superview {
			frame.size = CGSize(width: superview.frame.width, height: frame.height)
			shadow!.frame = frame
			shadow!.layer.shadowPath = UIBezierPath(rect: shadow!.bounds).cgPath
			
			let padding: CGFloat
			
			switch RCBarComponentForm! {
			case .header:
				padding = 16
				let numberOfLabels = titles.count
				switch numberOfLabels {
				case 1:
					titles[0].frame.origin = CGPoint(x: padding, y: padding)
					addSubview(titles[0])
					break
				case 2:
					titles[0].frame.origin = CGPoint(x: padding, y: padding)
					break
				default:
					break
				}
				if !(actions.isEmpty) {
					let x = frame.width - padding - actions[0].frame.width
					let y = (frame.height - actions[0].frame.height) / 2
					actions[0].frame.origin = CGPoint(x: x, y: y)
					addSubview(actions[0])
				}
				break
			case .footer:
				padding = 10
				break
			}
		}
	}
	
	@objc func send(sender: UIButton) {
		ChatViewController!.RCResponseCard!.dismiss {
			
		}
	}
}
enum RCBodyTemplates {
	case list
	// case scaleDiscrete
}
class RCContent {
	var RCHeader: RCBarComponent?
	var RCBodyContent: Any?
	var RCTemplate: RCBodyTemplates?
	var RCFooter: RCBarComponent?
	var canExpandCard: Bool?
	
	init(RCBody: Any, as template: RCBodyTemplates, in ChatViewController: ChatViewController) {
		switch template {
		case .list:
			self.RCBodyContent = RCBody as! RCList
			canExpandCard = true
			
			// Create RCHeader for RCList
			let RCHeaderTitle: String
			if (RCBody as! RCList).collectionView!.allowsMultipleSelection {
				RCHeaderTitle = "Choose All that Apply"
			} else {
				RCHeaderTitle = "Choose One"
			}
			RCHeader = RCBarComponent(.header, labels: [RCHeaderTitle], actions: [.send], in: ChatViewController)
			
			break
		}
		RCTemplate = template
	}
	
	deinit {
		RCHeader = nil
		RCBodyContent = nil
		RCTemplate = nil
		RCFooter = nil
		canExpandCard = nil
	}
	
	func add(to RCResponseCard: RCResponseCardView, in RCViewController: RCResponseCardViewController) {
		
		let RCBodyView = UIView(frame: CGRect(x: 0, y: RCHeader!.frame.height, width: RCViewController.constraint(for: .width), height: RCViewController.constraint(for: .maximumHeight) - RCHeader!.frame.height))
		RCViewController.view.addSubview(RCBodyView)
		
		switch RCTemplate! {
		case .list:
			let RCBodyContent = self.RCBodyContent as! RCList
			RCBodyContent.willMove(toParentViewController: RCViewController)
			RCBodyView.addSubview(RCBodyContent.view)
			RCBodyContent.view.frame.size = CGSize(width: RCBodyContent.view.superview!.frame.width, height: RCViewController.constraint(for: .maximumHeight) - RCHeader!.frame.height)
			RCViewController.addChildViewController(RCBodyContent)
			RCBodyContent.didMove(toParentViewController: RCViewController)
			
			RCBodyContent.collectionView!.frame.size = RCBodyContent.collectionView!.superview!.frame.size
			break
		}
		
		RCViewController.view.addSubview(RCHeader!.shadow!)
		RCViewController.view.addSubview(RCHeader!)
	}
	
}
