//
//  ResponseCard.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit
protocol RCResponseCard {
	var RCHeaderSendButton: RCAction? { get set }
}
class RCResponseCardView: UIView {
	var shadow: RCResponseCardViewShadow?
	var RCContent: RCContent?
	var ChatViewController: ChatViewController?
	
	convenience init(RCContent: RCContent, in ChatViewController: ChatViewController) {
		
		// Set up necessary view controller
		let RCViewController = RCResponseCardViewController(with: RCContent.RCTemplate!)
		ChatViewController.RCViewController = RCViewController
		
		// Set up layout for Response Card
		self.init(setUpFrameIn: ChatViewController, canExpandCard: RCContent.canExpandCard!)
		RCViewController.RCResponseCard = self
		RCViewController.view.frame.size = self.frame.size // Need to update when height changes
		self.RCContent = RCContent
		self.ChatViewController = ChatViewController
		RCViewController.Chat = self.ChatViewController
		
		// Set up visual language for Response Card
		backgroundColor = UIColor(named: "Lighter Grey")
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
	var Chat: ChatViewController?
	var RCResponseCard: RCResponseCardView?
	var minimumHeight: CGFloat?
	var maximumHeight: CGFloat?
	
	init(with RCBodyTemplate: RCBodyTemplates) {
		super.init(nibName: nil, bundle: nil)
		
		// Must set a minimum height for each Response Card Type
		let margin: CGFloat = 16
		let width = UIScreen.main.bounds.width - (margin * 2)
		let RCHeader = RCBarComponent(.header, labels: ["l"], actions: [], in: ChatViewController())
		let RCFooter = RCBarComponent(.footer, labels: ["l"], actions: [], in: ChatViewController())
		
		switch RCBodyTemplate {
		case .list:
			minimumHeight = 300
		case .scale:
			minimumHeight = RCHeader.frame.height + RCFooter.frame.height + 48
		case .visualUpload:
			minimumHeight = RCHeader.frame.height + RCFooter.frame.height + ((width * 3) / 4)
		case .audioUpload:
			minimumHeight = RCHeader.frame.height + RCFooter.frame.height + 104
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		Chat = nil
		RCResponseCard = nil
		minimumHeight = nil
		maximumHeight = nil
	}
	
	override func didMove(toParentViewController parent: UIViewController?) {
		let RCContent = RCResponseCard!.RCContent!
		let RCHeader = RCContent.RCHeader
		
		// Create RCBodyView
		var height =  -(RCHeader!.frame.height)
		if RCContent.canExpandCard! { height = height + constraint(for: .maximumHeight) }
		else { height = height + constraint(for: .minimumHeight) }
		if let RCFooter = RCContent.RCFooter { height = height - RCFooter.frame.height }
		let RCBodyView = UIView(frame: CGRect(x: 0, y: RCHeader!.frame.height, width: constraint(for: .width), height: height))
		view.addSubview(RCBodyView)
		
		// Connect RCBodyView to necessary view controllers
		switch RCResponseCard!.RCContent!.RCTemplate! {
		case .list:
			let RCBodyContent = RCResponseCard!.RCContent!.RCBodyContent as! RCList
			RCBodyView.addSubview(RCBodyContent.view)
			addChildViewController(RCBodyContent)
			RCBodyContent.didMove(toParentViewController: self)
			RCBodyContent.RCViewController = self
			break
		case .scale:
			let RCBodyContent = RCResponseCard!.RCContent!.RCBodyContent as! RCScale
			RCBodyView.addSubview(RCBodyContent.view)
			addChildViewController(RCBodyContent)
			RCBodyContent.didMove(toParentViewController: self)
		case .visualUpload:
			let RCBodyContent = RCResponseCard!.RCContent!.RCBodyContent as! RCVisualUpload
			RCBodyView.addSubview(RCBodyContent.view)
			addChildViewController(RCBodyContent)
			RCBodyContent.didMove(toParentViewController: self)
		case .audioUpload:
			let RCBodyContent = RCResponseCard!.RCContent!.RCBodyContent as! RCAudioUpload
			RCBodyView.addSubview(RCBodyContent.view)
			addChildViewController(RCBodyContent)
			RCBodyContent.didMove(toParentViewController: self)
		}
		
		// Add headers and footers
		view.addSubview(RCHeader!.shadow!)
		view.addSubview(RCHeader!)
		if let RCFooter = RCContent.RCFooter {
			RCFooter.frame.origin = CGPoint(x: 0, y: view.superview!.frame.height - RCFooter.frame.height)
			RCFooter.shadow!.frame.origin = RCFooter.frame.origin
			view.addSubview(RCFooter.shadow!)
			view.addSubview(RCFooter)
		}
	}
	
	func RCResponseCardViewDidChange() {
		let percentThreshold: CGFloat = 0.25
		let originYThresholdForMaximumHeight = constraint(for: .deviceHeight) * percentThreshold
		if RCResponseCard!.frame.origin.y < originYThresholdForMaximumHeight {
			RCResponseCardChangeState(to: .maximized)
		} else {
			RCResponseCardChangeState(to: .minimized)
		}
	}
	
	func RCResponseCardChangeState(to state: cardStates) {
		let height: CGFloat
		let y: CGFloat
		var shouldRemoveGestureRecognizer = false
		
		switch state {
		case .minimized:
			y = constraint(for: .originYwhenMinimized)
			height = constraint(for: .minimumHeight)
			
			switch RCResponseCard!.RCContent!.RCTemplate! { // Determine any card maximization specialties
			case .list:
				(RCResponseCard!.RCContent!.RCBodyContent as! RCList).collectionView!.isScrollEnabled = false
				break
			default:
				break
			}
		case .maximized:
			y = constraint(for: .originYwhenMaximized)
			height = constraint(for: .maximumHeight)
			
			switch RCResponseCard!.RCContent!.RCTemplate! { // Determine any card maximization specialties
			case .list:
				(Chat!.RCResponseCard!.RCContent!.RCBodyContent as! RCList).collectionView!.isScrollEnabled = true
				break
			default:
				break
			}
			shouldRemoveGestureRecognizer = true
		}
		
		UIView.animate(withDuration: 0.3) {
			self.RCResponseCard!.frame = CGRect(x: self.constraint(for: .marginLeft), y: y, width: self.constraint(for: .width), height: height)
			self.RCResponseCard!.shadow!.frame = self.RCResponseCard!.frame
			
			if let RCFooter = self.RCResponseCard!.RCContent!.RCFooter {
				RCFooter.frame.origin = CGPoint(x: RCFooter.frame.origin.x, y: self.RCResponseCard!.frame.height - RCFooter.frame.height)
				RCFooter.shadow!.frame.origin = RCFooter.frame.origin
			}
		}
		
		if shouldRemoveGestureRecognizer {
			for gestureRecognizer in RCResponseCard!.gestureRecognizers! {
				RCResponseCard!.removeGestureRecognizer(gestureRecognizer)
			}
		}
	}
	
	enum cardStates {
		case minimized
		case maximized
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
			return Chat!.view.frame.width
		case .deviceHeight:
			return Chat!.view.frame.height
		case .width:
			return self.constraint(for: .deviceWidth) - self.constraint(for: .marginLeft) - self.constraint(for: .marginRight)
		case .minimumHeight:
			return self.minimumHeight!
		case .maximumHeight:
			return self.constraint(for: .deviceHeight) - Chat!.ChatToolbar.frame.height - self.constraint(for: .originYwhenMaximized) - self.constraint(for: .marginBottom)
		case .originYwhenMinimized:
			return self.constraint(for: .deviceHeight) - Chat!.ChatToolbar.frame.height - self.constraint(for: .marginBottom) -  self.constraint(for: .minimumHeight)
		case .originYwhenMaximized:
			return Chat!.view.safeAreaInsets.top + self.constraint(for: .marginTop)
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

class RCResponseCardViewShadow: UIView {
	convenience init(for RCResponseCardView: RCResponseCardView) {
		self.init(frame: RCResponseCardView.frame)
		createShadow(opacity: 0.15, offset: CGSize.zero, cornerRadius: RCResponseCardView.layer.cornerRadius, shadowRadius: 2)
	}
}
