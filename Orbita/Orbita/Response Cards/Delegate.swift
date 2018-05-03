//
//  ResponseCard.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit

protocol RCResponseCardComponents {
	var RCHeaderSendButton: RCAction? { get set }
}

class RCResponseCard: UIView {
	var shadow: RCResponseCardViewShadow!
	var RCContent: RCContent?
	var Main: MainViewController!
	
	convenience init(RCContent: RCContent, in MainViewController: MainViewController) {
		
		// Set up necessary view controller
		let RCViewController = RCDelegate(with: RCContent.RCTemplate!)
		MainViewController.RCViewController = RCViewController
		
		// Set up layout for Response Card
		self.init(setUpFrameIn: MainViewController, canExpandCard: RCContent.canExpandCard!)
		RCViewController.RCResponseCard = self
		RCViewController.view.frame.size = self.frame.size // Need to update when height changes
		self.RCContent = RCContent
		self.Main = MainViewController
		RCViewController.Chat = self.Main
		
		// Set up visual language for Response Card
		backgroundColor = color(.lighterGrey)
		layer.cornerRadius = cornerRadius(.medium)
		layer.masksToBounds = true
		alpha = 0
		shadow = RCResponseCardViewShadow(for: self)
		Main.view.insertSubview(shadow!, belowSubview: self)
		
		// Connect RCViewController to Response Card and ChatViewController
		addSubview(Main.RCViewController!.view)
		Main.addChildViewController(RCViewController)
		RCViewController.didMove(toParentViewController: Main)
	}
	
	convenience init(setUpFrameIn Main: MainViewController, canExpandCard: Bool) {
		self.init(frame: CGRect.zero)
		frame.origin = CGPoint(x: spacing(.medium), y: Main.view.frame.height)
		frame.size = CGSize(width: Main.view.frame.width - (spacing(.medium) * 2), height: Main.RCViewController!.minimumHeight!)
		
		Main.ResponseCard = self
		Main.view.insertSubview(self, belowSubview: Main.ChatToolbar)
		
		if canExpandCard {
			let pan = UIPanGestureRecognizer(target: Main, action: #selector(MainViewController.responseCardWasDragged(gesture:)))
			addGestureRecognizer(pan)
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
			
			for view in self.Main!.view.subviews {
				if let RCResponseCardView = view as? RCResponseCard {
					RCResponseCardView.removeFromSuperview()
					self.Main!.ResponseCard = nil
				}
				if let RCResponseCardViewShadow = view as? RCResponseCardViewShadow {
					RCResponseCardViewShadow.removeFromSuperview()
					self.shadow = nil
				}
			}
			for childViewController in self.Main!.childViewControllers {
				if let RCResponseCardViewController = childViewController as? RCDelegate {
					RCResponseCardViewController.removeFromParentViewController()
					self.Main!.RCViewController = nil
				}
			}
			finishedDisimissing()
		}
	}
}

class RCDelegate: UIViewController {
	var Chat: MainViewController?
	var RCResponseCard: RCResponseCard?
	var minimumHeight: CGFloat!
	var maximumHeight: CGFloat?
	
	init(with RCBodyTemplate: RCBodyTemplates) {
		super.init(nibName: nil, bundle: nil)
		
		// Must set a minimum height for each Response Card Type
		
		let RCHeader = RCBarComponent(.header, labels: ["l"], actions: [], in: MainViewController())
		let RCFooter = RCBarComponent(.footer, labels: ["l"], actions: [], in: MainViewController())
		
		switch RCBodyTemplate {
		case .list:
			minimumHeight = 300
		case .scale:
			minimumHeight = RCHeader.frame.height + RCFooter.frame.height + 48
		case .visualUpload:
			minimumHeight = RCHeader.frame.height + RCFooter.frame.height + ((constraint(.contentWidth) * 3) / 4)
		case .audioUpload:
			minimumHeight = RCHeader.frame.height + RCFooter.frame.height + 104
		case .datePicker:
			let row = UIButton(frame: CGRect.zero)
			row.setTitle(" ", for: .normal)
			row.titleLabel!.font = UILabel().Raleway(textStyle: .body, weight: .bold)
			row.sizeToFit()
			
			let innerPaddingVertical = RCDatePickerComponent().innerPaddingVertical
			row.frame.size = CGSize(width: 0, height: row.frame.height + (innerPaddingVertical * 2))
			minimumHeight = RCHeader.frame.height + RCFooter.frame.height + (row.frame.height * 5)
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
		if RCContent.canExpandCard! { height = height + cardConstraint(.maximumHeight) }
		else { height = height + minimumHeight }
		if let RCFooter = RCContent.RCFooter {
			height -= RCFooter.frame.height
			
		}
		let RCBodyView = UIView(frame: CGRect(x: 0, y: RCHeader!.frame.height, width: constraint(.contentWidth), height: height))
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
		case .datePicker:
			let RCBodyContent = RCResponseCard!.RCContent!.RCBodyContent as! RCDatePickerController
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
		let originYThresholdForMaximumHeight = constraint(.deviceHeight) * percentThreshold
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
			y = cardConstraint(.originYwhenMinimized)
			height = minimumHeight!
			
			switch RCResponseCard!.RCContent!.RCTemplate! { // Determine any card maximization specialties
			case .list:
				(RCResponseCard!.RCContent!.RCBodyContent as! RCList).collectionView!.isScrollEnabled = false
				break
			default:
				break
			}
		case .maximized:
			y = cardConstraint(.originYwhenMaximized)
			height = cardConstraint(.maximumHeight)
			
			switch RCResponseCard!.RCContent!.RCTemplate! { // Determine any card maximization specialties
			case .list:
				(Chat!.ResponseCard!.RCContent!.RCBodyContent as! RCList).collectionView!.isScrollEnabled = true
				break
			default:
				break
			}
			shouldRemoveGestureRecognizer = true
		}
		
		UIView.animate(withDuration: 0.3) {
			self.RCResponseCard!.frame = CGRect(x: constraint(.contentSpacing), y: y, width: constraint(.contentWidth), height: height)
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
		case maximumHeight
		case originYwhenMinimized
		case originYwhenMaximized
	}
	
	func cardConstraint(_ object: RCResponseCardContraints) -> CGFloat {
		switch object {
		case .maximumHeight:
			return constraint(.deviceHeight) - Chat!.ChatToolbar.frame.height - self.cardConstraint(.originYwhenMaximized) - constraint(.contentSpacing)
		case .originYwhenMinimized:
			return constraint(.deviceHeight) - Chat!.ChatToolbar.frame.height - constraint(.contentSpacing) -  self.minimumHeight!
		case .originYwhenMaximized:
			return Chat!.view.safeAreaInsets.top + constraint(.contentSpacing)
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
	convenience init(for RCResponseCardView: RCResponseCard) {
		self.init(frame: RCResponseCardView.frame)
		createShadow(opacity: 0.15, offset: CGSize.zero, cornerRadius: RCResponseCardView.layer.cornerRadius, shadowRadius: 2)
	}
}
