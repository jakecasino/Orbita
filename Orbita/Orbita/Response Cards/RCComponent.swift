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

enum RCBodyTemplates {
	case list
	case scale
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
			RCFooter = RCBarComponent(.footer, labels: ["See Full List"], actions: [], in: ChatViewController)
			break
		case .scale:
			self.RCBodyContent = RCBody as! RCScale
			canExpandCard = false
			
			// Create RCHeader for RCScale
			let RCHeaderTitle = String((RCBody as! RCScale).RCHeaderTitle!)
			RCHeader = RCBarComponent(.header, labels: [RCHeaderTitle], actions: [.send], in: ChatViewController)
			switch (RCBody as! RCScale).type! {
			case .continuous:
				RCFooter = RCBarComponent(.footer, labels: ["\((RCBody as! RCScale).range.first!)", "\((RCBody as! RCScale).range.last!)"], actions: [], in: ChatViewController)
			case .discrete:
				RCFooter = RCBarComponent(.footer, labels: ["\((RCBody as! RCScale).range.first!)", "slider value", "\((RCBody as! RCScale).range.last!)"], actions: [], in: ChatViewController)
				RCFooter!.labels[1].textAlignment = .center
				RCFooter!.labels[1].textColor = UIColor(named: "Orbita Blue")
				(RCBody as! RCScale).sliderValue = RCFooter!.labels[1]
			}
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
	
}

class RCBarComponent: UIView {
	var ChatViewController: ChatViewController?
	var shadow: UIView?
	var labels = [UILabel]()
	var actions = [UIButton]()
	var form: Forms?
	
	enum Forms {
		case header
		case footer
	}
	
	enum TextStyles {
		case title
		case subtitle
	}
	
	convenience init(_ RCBarComponentForm: Forms, labels: [String], actions: [actions], in ChatViewController: ChatViewController) {
		let paddingVertical: CGFloat
		let buttonSize: CGFloat
		
		self.init(frame: CGRect.zero)
		self.ChatViewController = ChatViewController
		self.form = RCBarComponentForm
		
		func generateUILabel(text: String, type: TextStyles) -> UILabel {
			let label = UILabel(frame: CGRect.zero)
			label.text = text.uppercased()
			
			switch form! {
			case .header:
				label.textColor = UIColor.black
			case .footer:
				label.textColor = UIColor(named: "Orbita Blue")
			}
			
			switch type {
			case .title:
				label.font = label.Raleway(textStyle: .footnote, weight: .bold)
			case .subtitle:
				label.font = UIFont.preferredFont(forTextStyle: .footnote)
			}
			
			label.sizeToFit()
			return label
		}
		
		switch self.form! {
		case .header:
			paddingVertical = 16
			buttonSize = 30
			
			for (index, text) in labels.enumerated() {
				if index == 0 {
					let title = generateUILabel(text: text, type: .title)
					self.labels.append(title)
				} else if index == 1 {
					let subtitle = generateUILabel(text: text, type: .subtitle)
					self.labels.append(subtitle)
				} else {
					break
				}
			}
			
			if !(actions.isEmpty) {
				self.actions.append(UIButton(for: self.form!, action: actions[0], size: buttonSize))
				self.actions[0].addTarget(self, action: #selector(send(sender:)), for: UIControlEvents.touchUpInside)
			}
		case .footer:
			paddingVertical = 10
			buttonSize = 30
			for text in labels {
				let label = generateUILabel(text: text, type: .title)
				self.labels.append(label)
			}
			break
		}
		
		let height = paddingVertical + self.labels[0].frame.height + paddingVertical
		frame.size = CGSize(width: frame.width, height: height)
		backgroundColor = UIColor.white
		
		shadow = UIView(frame: frame)
		shadow!.createShadow(opacity: 0.15, offset: CGSize(width: 0, height: 0), cornerRadius: 0, shadowRadius: 1)
	}
	
	deinit {
		ChatViewController = nil
		shadow = nil
		form = nil
	}
	
	override func didMoveToSuperview() {
		if let superview = superview {
			frame.size = CGSize(width: superview.frame.width, height: frame.height)
			shadow!.frame = frame
			shadow!.layer.shadowPath = UIBezierPath(rect: shadow!.bounds).cgPath
			
			let paddingVertical: CGFloat
			let paddingHorizontal: CGFloat = 16
			
			switch form! {
			case .header:
				paddingVertical = 16
				for (index, label) in labels.enumerated() {
					if index == 0 {
						label.frame.origin = CGPoint(x: paddingHorizontal, y: paddingVertical)
						addSubview(label)
					}
					if index == 1 {
						label.frame.origin = CGPoint(x: paddingHorizontal, y: paddingVertical)
						addSubview(label)
					} else {
						break
					}
				}
				if !(actions.isEmpty) {
					let x = frame.width - paddingHorizontal - actions[0].frame.width
					let y = (frame.height - actions[0].frame.height) / 2
					actions[0].frame.origin = CGPoint(x: x, y: y)
					addSubview(actions[0])
				}
				break
			case .footer:
				paddingVertical = 10
				
				// Layout first label
				if !(labels.isEmpty) {
					labels[0].frame.origin = CGPoint(x: paddingHorizontal, y: paddingVertical)
					addSubview(labels[0])
				}
				
				// Layout other labels
				let numberOfLabels = labels.count
				switch numberOfLabels {
				case 2:
					labels[1].frame.origin = CGPoint(x: superview.frame.width - paddingHorizontal - labels[1].frame.width, y: paddingVertical)
					addSubview(labels[1])
					break
				case 3:
					labels[1].frame.origin = CGPoint(x: (superview.frame.width - labels[1].frame.width) / 2, y: paddingVertical)
					addSubview(labels[1])
					labels[2].frame.origin = CGPoint(x: superview.frame.width - paddingHorizontal - labels[2].frame.width, y: paddingVertical)
					addSubview(labels[2])
					
					// Adjust sliderValue Label for RCSCale at launch
					if let RCContent = ChatViewController!.RCResponseCard!.RCContent {
						if RCContent.RCTemplate! == .scale {
							let RCScale = RCContent.RCBodyContent as! RCScale
							RCScale.moveSlider(to: (RCScale.range.count / 2))
						}
					}
					
					break
				default:
					break
				}
				break
			}
		}
	}
	
	@objc func send(sender: UIButton) {
		ChatViewController!.RCResponseCard!.dismiss {
			
		}
	}
}
