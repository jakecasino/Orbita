//
//  ResponseCardComponents.swift
//  Orbita
//
//  Created by Jake Casino on 4/3/18.
//

import UIKit

enum RCBodyTemplates {
	case list
	case scale
	case visualUpload
	case audioUpload
}

class RCContent {
	var RCHeader: RCBarComponent?
	var RCBodyContent: Any?
	var RCTemplate: RCBodyTemplates?
	var RCFooter: RCBarComponent?
	var canExpandCard: Bool?
	
	init(RCBody: Any, as template: RCBodyTemplates, in ChatViewController: ChatViewController) {
		canExpandCard = false
		switch template {
		case .list:
			let RCBody = RCBody as! RCList
			self.RCBodyContent = RCBody
			canExpandCard = true
			
			let RCHeaderTitle: String
			if RCBody.collectionView!.allowsMultipleSelection {
				RCHeaderTitle = "Choose All that Apply"
			} else {
				RCHeaderTitle = "Choose One"
			}
			RCHeader = RCBarComponent(.header, labels: [RCHeaderTitle], actions: [RCAction.glyphs.send], in: ChatViewController)
			guard RCHeader!.RCActions.indices.contains(0) else { break }
			RCBody.RCHeaderSendButton = RCHeader!.RCActions[0]
			
			RCFooter = RCBarComponent(.footer, labels: [], actions: ["See Full List"], in: ChatViewController)
			
			guard RCFooter!.RCActions.indices.contains(0) else { break }
			RCBody.SeeFullListButton = RCFooter!.RCActions[0]
			break
		case .scale:
			let RCBody = RCBody as! RCScale
			self.RCBodyContent = RCBody
			
			let RCHeaderTitle = String(RCBody.RCHeaderTitle!)
			RCHeader = RCBarComponent(.header, labels: [RCHeaderTitle], actions: [RCAction.glyphs.send], in: ChatViewController)
			
			guard RCHeader!.RCActions.indices.contains(0) else { break }
			RCBody.RCHeaderSendButton = RCHeader!.RCActions[0]
			
			switch RCBody.type! {
			case .continuous:
				RCFooter = RCBarComponent(.footer, labels: [], actions: [(RCBody.range.first! as! String), (RCBody.range.last! as! String)], in: ChatViewController)
			case .discrete:
				RCFooter = RCBarComponent(.footer, labels: ["SliderValue"], actions: ["\(RCBody.range.first!)", "\(RCBody.range.last!)"], in: ChatViewController)
				
				guard RCFooter!.RCLabels.indices.contains(0) else { break }
				RCBody.SliderValue = RCFooter!.RCLabels[0]
			}
			
			RCBody.SliderEndValues = RCFooter!.RCActions
			break
		case .visualUpload:
			let RCBody = RCBody as! RCVisualUpload
			self.RCBodyContent = RCBody
			
			let RCHeaderTitle = "Choose one" // FIX
			RCHeader = RCBarComponent(.header, labels: [RCHeaderTitle], actions: [RCAction.glyphs.send], in: ChatViewController)
			RCFooter = RCBarComponent(.footer, labels: [], actions: ["Choose from Library"], in: ChatViewController)
			
			guard RCFooter!.RCActions.indices.contains(0) else { break }
			RCBody.ChooseFromLibrary = RCFooter!.RCActions[0]
		case .audioUpload:
			let RCBody = RCBody as! RCAudioUpload
			self.RCBodyContent = RCBody
			
			RCHeader = RCBarComponent(.header, labels: [RCBody.RCHeaderTitle!], actions: [RCAction.glyphs.send], in: ChatViewController)
			guard RCHeader!.RCActions.indices.contains(0) else { break }
			RCBody.RCHeaderSendButton = RCHeader!.RCActions[0]
			
			RCFooter = RCBarComponent(.footer, labels: ["0:00"], actions: [], in: ChatViewController)
			guard RCFooter!.RCLabels.indices.contains(0) else { break }
			RCBody.timerLabel = RCFooter!.RCLabels[0]
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
	var RCLabels = [RCLabel]()
	var RCActions = [RCAction]()
	var form: Forms?
	
	enum Forms {
		case header
		case footer
	}
	
	convenience init(_ RCBarComponentForm: Forms, labels: [String], actions: [Any], in ChatViewController: ChatViewController) {
		let paddingVertical: CGFloat
		
		self.init(frame: CGRect.zero)
		self.ChatViewController = ChatViewController
		self.form = RCBarComponentForm
		
		// Generate RCLabels
		for (index, label) in labels.enumerated() {
			if self.form! == .header {
				if index == 0 {
					self.RCLabels.append(RCLabel(text: label, style: .title))
				} else if index == 1 {
					self.RCLabels.append(RCLabel(text: label, style: .subtitle))
				}
			} else {
				self.RCLabels.append(RCLabel(text: label, style: .title))
			}
		}
		
		// Create RCActions
		for action in actions {
			if let action = action as? RCAction.glyphs {
				var buttonSize: CGFloat
				switch self.form! {
				case .header:
					buttonSize = 30
				case .footer:
					buttonSize = 30
				}
				self.RCActions.append(RCAction(glyph: action, for: self.form!, size: buttonSize, customColor: nil, in: ChatViewController))
			} else if let action = action as? String {
				self.RCActions.append(RCAction(label: action))
			}
		}
		
		// Set the height of the bar
		switch self.form! {
		case .header:
			paddingVertical = 16
			break
		case .footer:
			paddingVertical = 10
			break
		}
		let height: CGFloat
		if !self.RCLabels.isEmpty {
			height = paddingVertical + self.RCLabels[0].frame.height + paddingVertical
		} else {
			height = paddingVertical + RCLabel(text: " ", style: RCLabel.TextStyles.title).frame.height + paddingVertical
		}
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
			
			let paddingHorizontal: CGFloat = 16
			
			// Add RCLabels to superview
			switch RCLabels.count {
			case 1:
				let x: CGFloat
				switch form! {
				case .header:
					x = paddingHorizontal
					break
				case .footer:
					x = (frame.width - RCLabels[0].frame.width) / 2
				}
				RCLabels[0].frame.origin = CGPoint(x: x, y: (frame.height - RCLabels[0].frame.height) / 2)
				
				if let RCContent = ChatViewController!.RCResponseCard!.RCContent {
					if RCContent.RCTemplate! == .scale {
						let RCScale = RCContent.RCBodyContent as! RCScale
						if RCScale.type! == .discrete {
							RCScale.moveSlider(to: (RCScale.range.count / 2))
						}
					}
				}
				
				break
			case 2:
				RCLabels[0].frame.origin = CGPoint(x: paddingHorizontal, y: (frame.height - RCLabels[0].frame.height) / 2)
				RCLabels[1].frame.origin = CGPoint(x: frame.width - RCLabels[1].frame.width - paddingHorizontal, y: (frame.height - RCLabels[0].frame.height) / 2)
				break
			default:
				break
			}
			for RCLabel in RCLabels {
				addSubview(RCLabel)
			}
			
			// Add RCActions to superview
			switch RCActions.count {
			case 1:
				let x: CGFloat
				switch form! {
				case .header:
					x = frame.width - RCActions[0].frame.width - paddingHorizontal
					break
				case .footer:
					x = (frame.width - RCActions[0].frame.width) / 2
				}
				RCActions[0].frame.origin = CGPoint(x: x, y: (frame.height - RCActions[0].frame.height) / 2)
				break
			case 2:
				RCActions[0].frame.origin = CGPoint(x: paddingHorizontal, y: (frame.height - RCActions[0].frame.height) / 2)
				RCActions[0].contentHorizontalAlignment = .left
				
				RCActions[1].frame.origin = CGPoint(x: frame.width - RCActions[1].frame.width - paddingHorizontal, y: (frame.height - RCActions[1].frame.height) / 2)
				RCActions[1].contentHorizontalAlignment = .right
				break
			case 3:
				RCActions[0].frame.origin = CGPoint(x: paddingHorizontal, y: (frame.height - RCActions[0].frame.height) / 2)
				RCActions[0].contentHorizontalAlignment = .left
				
				RCActions[1].frame.origin = CGPoint(x: (frame.width - RCActions[1].frame.width) / 2, y: (frame.height - RCActions[1].frame.height) / 2)
				
				RCActions[2].frame.origin = CGPoint(x: frame.width - RCActions[2].frame.width - paddingHorizontal, y: (frame.height - RCActions[2].frame.height) / 2)
				RCActions[2].contentHorizontalAlignment = .right
				break
			default:
				break
			}
			for RCAction in RCActions {
				addSubview(RCAction)
			}
		}
	}
}

class RCLabel: UILabel {
	enum TextStyles {
		case title
		case subtitle
	}
	
	init(text: String, style: TextStyles) {
		super.init(frame: CGRect.zero)
		self.text = text.uppercased()
		
		let font: UIFont
		switch style {
		case .title:
			font = UILabel().Raleway(textStyle: .footnote, weight: .bold)
		case .subtitle:
			font = UIFont.preferredFont(forTextStyle: .footnote)
		}
		self.font = font
		
		self.textColor = UIColor.black
		sizeToFit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

class RCAction: UIButton {
	var ChatViewController: ChatViewController?
	var backgroundColor_store: UIColor!
	enum glyphs {
		case send
		case microphone
	}
	
	override var isHighlighted: Bool {
		didSet {
			if isHighlighted {
				tintColor = backgroundColor
			} else {
				tintColor = UIColor.white
			}
		}
	}
	
	override var isEnabled: Bool {
		didSet {
			if isEnabled {
				backgroundColor = backgroundColor_store
			} else {
				backgroundColor = UIColor(named: "Medium Grey")
			}
		}
	}
	
	init(label: String) {
		super.init(frame: CGRect.zero)
		setTitle(label.uppercased(), for: .normal)
		
		// Set the font for the button
		let text = RCLabel(text: label, style: .title)
		self.titleLabel!.font = text.font
		self.setTitleColor(UIColor(named: "Orbita Blue"), for: .normal)
		self.setTitleColor(UIColor(named: "Orbita Blue Selected"), for: .highlighted)
		sizeToFit()
	}
	
	init(glyph: glyphs, for form: RCBarComponent.Forms?, size: CGFloat, customColor: UIColor?, in ChatViewController: ChatViewController) {
		super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
		self.ChatViewController = ChatViewController
		
		func setBackgroundColor() {
			if let customColor = customColor {
				backgroundColor = customColor
			} else {
				backgroundColor = UIColor(named: "Orbita Blue")
			}
			backgroundColor_store = backgroundColor!
		}
		
		func createCircleButton() {
			layer.cornerRadius = size / 2
		}
		
		if let form = form {
			switch form {
			case .header:
				createCircleButton()
				setBackgroundColor()
				tintColor = UIColor.white
				break
			case .footer:
				break
			}
		} else {
			createCircleButton()
			setBackgroundColor()
			tintColor = UIColor.white
		}
		
		switch glyph {
		case .send:
			setImage(UIImage(named: "Send"), for: .normal)
			addTarget(self, action: #selector(dismissResponseCard(sender:)), for: .touchUpInside)
			isEnabled = false
		case .microphone:
			setImage(UIImage(named: "Microphone"), for: .normal)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func dismissResponseCard(sender: UIButton) {
		ChatViewController!.RCResponseCard!.dismiss {
			
		}
	}
}
