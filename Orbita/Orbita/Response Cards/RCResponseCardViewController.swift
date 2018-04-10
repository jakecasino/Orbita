//
//  ResponseCard.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit

class RCResponseCardView: UIView {
	var shadow: RCResponseCardViewShadow?
	var RCContent: RCContent?
	var ChatViewController: ChatViewController?
	
	convenience init(RCContent: RCContent, in ChatViewController: ChatViewController) {
		
		// Set up necessary view controller
		let RCViewController = RCResponseCardViewController(with: RCContent.RCTemplate!)
		RCViewController.ChatViewController = ChatViewController
		ChatViewController.RCViewController = RCViewController
		
		// Set up layout for Response Card
		self.init(setUpFrameIn: ChatViewController, canExpandCard: RCContent.canExpandCard!)
		RCViewController.RCResponseCard = self
		RCViewController.view.frame.size = self.frame.size // Need to update when height changes
		self.RCContent = RCContent
		self.ChatViewController = ChatViewController
		
		// Set up visual language for Response Card
		backgroundColor = UIColor(named: "Light Grey")
		layer.cornerRadius = 12
		layer.masksToBounds = true
		alpha = 0
		shadow = RCResponseCardViewShadow(for: self)
		ChatViewController.view.insertSubview(shadow!, belowSubview: self)
		
		// Connect RCViewController to Response Card and ChatViewController
		RCViewController.willMove(toParentViewController: ChatViewController)
		addSubview(ChatViewController.RCViewController!.view)
		ChatViewController.addChildViewController(RCViewController)
		RCViewController.didMove(toParentViewController: ChatViewController)
		
		// Add RCBodyContent
		RCContent.add(to: self, in: RCViewController)
	}
	
	convenience init(setUpFrameIn ChatViewController: ChatViewController, canExpandCard: Bool) {
		let margin: CGFloat = 16
		let x = margin
		let y = ChatViewController.view.frame.height
		let width = ChatViewController.view.frame.width - (margin * 2)
		let height = ChatViewController.RCViewController!.minimumHeight!
		self.init(frame: CGRect(x: x, y: y, width: width, height: height))
		
		ChatViewController.RCResponseCard = self
		ChatViewController.view.insertSubview(self, belowSubview: ChatViewController.ChatToolbar)
		
		if canExpandCard {
			addGestureRecognizer(UIPanGestureRecognizer(target: ChatViewController, action: #selector(ChatViewController.RCResponseCardWasDragged(gesture:))))
		}
	}
	
	deinit {
		RCContent = nil
	}
	
	typealias finishedDismissing = () -> ()
	func dismiss(finishedDisimissing: @escaping finishedDismissing) {
		UIView.animate(withDuration: 0.3, animations: {
			self.alpha = 0
			self.shadow!.alpha = 0
		}) { (finished: Bool) in
			for view in self.ChatViewController!.view.subviews {
				if let RCResponseCardView = view as? RCResponseCardView {
					RCResponseCardView.removeFromSuperview()
					self.ChatViewController!.RCResponseCard = nil
				}
				if let RCResponseCardViewShadow = view as? RCResponseCardViewShadow {
					RCResponseCardViewShadow.removeFromSuperview()
					self.shadow = nil
				}
			}
			for childViewController in self.ChatViewController!.childViewControllers {
				if let RCResponseCardViewController = childViewController as? RCResponseCardViewController {
					RCResponseCardViewController.removeFromParentViewController()
					self.ChatViewController!.RCViewController = nil
				}
			}
			finishedDisimissing()
		}
	}
}

class RCResponseCardViewController: UIViewController {
	var ChatViewController: ChatViewController?
	var RCResponseCard: RCResponseCardView?
	var minimumHeight: CGFloat?
	var maximumHeight: CGFloat?
	
	init(with RCBodyTemplate: RCBodyTemplates) {
		super.init(nibName: nil, bundle: nil)
		switch RCBodyTemplate {
		case .list:
			minimumHeight = 300
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		RCResponseCard = nil
		minimumHeight = nil
	}
	
	func RCResponseCardViewDidChange() {
		let percentThreshold: CGFloat = 0.25
		let originYThresholdForMaximumHeight = constraint(for: .deviceHeight) * percentThreshold
		let height: CGFloat
		let y: CGFloat
		var shouldRemoveGestureRecognizer = false
		
		if RCResponseCard!.frame.origin.y < originYThresholdForMaximumHeight {
			y = constraint(for: .originYwhenMaximized)
			height = constraint(for: .maximumHeight)
			
			switch RCResponseCard!.RCContent!.RCTemplate! {
			case .list:
				(ChatViewController!.RCResponseCard!.RCContent!.RCBodyContent as! RCList).collectionView!.isScrollEnabled = true
				break
			}
			shouldRemoveGestureRecognizer = true
			
		} else {
			y = constraint(for: .originYwhenMinimized)
			height = constraint(for: .minimumHeight)
			
			switch RCResponseCard!.RCContent!.RCTemplate! {
			case .list:
				(RCResponseCard!.RCContent!.RCBodyContent as! RCList).collectionView!.isScrollEnabled = false
				break
			}
		}
		
		RCResponseCard!.frame = CGRect(x: constraint(for: .marginLeft), y: y, width: constraint(for: .width), height: height)
		RCResponseCard!.shadow!.frame = RCResponseCard!.frame
		
		if shouldRemoveGestureRecognizer {
			for gestureRecognizer in RCResponseCard!.gestureRecognizers! {
				RCResponseCard!.removeGestureRecognizer(gestureRecognizer)
			}
		}
	}
	
	enum RCResponseCardContraints {
		case marginTop
		case marginBottom
		case marginLeft
		case marginRight
		case paddingTop
		case paddingBottom
		case paddingLeft
		case paddingRight
		case deviceWidth
		case deviceHeight
		case width
		case minimumHeight
		case maximumHeight
		case originYwhenMinimized
		case originYwhenMaximized
	}
	
	func constraint(for constraint: RCResponseCardContraints) -> CGFloat {
		let margin: CGFloat = 16
		let padding: CGFloat = 16
		switch constraint {
		case .marginTop:
			return margin
		case .marginBottom:
			return margin
		case .marginLeft:
			return margin
		case .marginRight:
			return margin
		case .paddingTop:
			return padding
		case .paddingBottom:
			return padding
		case .paddingLeft:
			return padding
		case .paddingRight:
			return padding
		case .deviceWidth:
			return ChatViewController!.view.frame.width
		case .deviceHeight:
			return ChatViewController!.view.frame.height
		case .width:
			return self.constraint(for: .deviceWidth) - self.constraint(for: .marginLeft) - self.constraint(for: .marginRight)
		case .minimumHeight:
			return self.minimumHeight!
		case .maximumHeight:
			return self.constraint(for: .deviceHeight) - ChatViewController!.ChatToolbar.frame.height - self.constraint(for: .originYwhenMaximized) - self.constraint(for: .marginBottom)
		case .originYwhenMinimized:
			return self.constraint(for: .deviceHeight) - ChatViewController!.ChatToolbar.frame.height - self.constraint(for: .marginBottom) -  self.constraint(for: .minimumHeight)
		case .originYwhenMaximized:
			return ChatViewController!.view.safeAreaInsets.top + self.constraint(for: .marginTop)
		}
	}
}

extension UIView {
	func createShadow(opacity: Float, offset: CGSize, cornerRadius: CGFloat, shadowRadius: CGFloat) {
		backgroundColor = UIColor.white
		layer.shadowColor = UIColor.black.cgColor
		layer.cornerRadius = cornerRadius
		layer.masksToBounds = false
		layer.shadowRadius = shadowRadius
		layer.shadowOffset = offset
		layer.shadowOpacity = opacity
	}
}

extension UIButton {
	convenience init(for component: RCBarComponent.Forms, action: actions, size: CGFloat) {
		self.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
		tintColor = UIColor.white
		backgroundColor = UIColor(named: "Orbita Blue")
		layer.cornerRadius = size / 2
		
		switch action {
		case .send:
			setImage(UIImage(named: "Send"), for: .normal)
		}
	}
}
extension UILabel {
	func Raleway(textStyle: UIFontTextStyle, weight: UIFont.Weight) -> UIFont {
		adjustsFontForContentSizeCategory = true
		return UIFontMetrics.default.scaledFont(for: UIFont(Raleway: textStyle, weight: weight)!)
	}
}

extension UIFont {
	convenience init?(Raleway textStyle: UIFontTextStyle, weight: UIFont.Weight) {
		let font: String
		switch weight {
		case .bold:
			font = "Raleway-Bold"
			break
		default:
			font = "Raleway-Regular"
			break
		}
		self.init(name: font, size: UIFont.preferredFont(forTextStyle: textStyle).pointSize)
	}
}

class RCResponseCardViewShadow: UIView {
	convenience init(for RCResponseCardView: RCResponseCardView) {
		self.init(frame: RCResponseCardView.frame)
		createShadow(opacity: 0.15, offset: CGSize.zero, cornerRadius: RCResponseCardView.layer.cornerRadius, shadowRadius: 2)
	}
}
