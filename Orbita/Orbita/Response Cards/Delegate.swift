//
//  ResponseCard.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit

class RCResponseCard: UIView {
	var main: MainViewController!
	var delegate: RCDelegate!
	var content: RCContent!
	var shadow: RCResponseCardViewShadow!
	
	convenience init(content CONTENT: RCContent, in MAIN: MainViewController) {
		self.init(frame: CGRect.zero)
		main = MAIN
		main.ResponseCard = self
		content = CONTENT
		
		// delegate initialization
		delegate = RCDelegate(with: content.template)
		
		// response card visual setup
		resizeTo(width: main.view.frame.width - (spacing(.medium) * 2), height: delegate.minimumHeight)
		move(x: spacing(.medium), y: main.view.frame.height)
		main.view.insertSubview(self, belowSubview: main.ChatToolbar.view)
		
		visualSetup(backgroundColor: color(.lighterGrey), cornerRadius: cornerRadius(.medium), masksToBounds: true, alpha: 0)
		shadow = RCResponseCardViewShadow(for: self)
		main.view.insertSubview(shadow, belowSubview: self)
		
		// delegate setup
		delegate.view.setSize(equalTo: frame) // Need to update when height changes
		if delegate.canExpandResponseCard {
			let pan = UIPanGestureRecognizer(target: main, action: #selector(main.responseCardWasDragged(gesture:)))
			addGestureRecognizer(pan)
		}
		
		// delegate link to main
		addSubview(delegate.view)
		main.addChildViewController(delegate)
		delegate.didMove(toParentViewController: main)
	}
	
	deinit {
		main = nil
		delegate = nil
		content = nil
		shadow = nil
	}
	
	typealias finishedDismissing = () -> ()
	func dismiss(completion: @escaping finishedDismissing) {
		UIView.animate(withDuration: 0.3, animations: {
			self.alpha = 0
			self.shadow!.alpha = 0
		}) { (finished: Bool) in
			
			for view in self.main!.view.subviews {
				if let RCResponseCardView = view as? RCResponseCard {
					RCResponseCardView.removeFromSuperview()
					self.main!.ResponseCard = nil
				}
				if let RCResponseCardViewShadow = view as? RCResponseCardViewShadow {
					RCResponseCardViewShadow.removeFromSuperview()
					self.shadow = nil
				}
			}
			for childViewController in self.main!.childViewControllers {
				if let delegate = childViewController as? RCDelegate {
					delegate.removeFromParentViewController()
				}
			}
			completion()
		}
	}
}

class RCDelegate: UIViewController {
	var minimumHeight: CGFloat!
	var canExpandResponseCard: Bool!
	
	enum cardStates {
		case minimized
		case maximized
	}
	
	enum RCResponseCardContraints {
		case maximumHeight
		case OriginY_Minimized
		case OriginY_Maximized
	}
	
	init(with RCBodyTemplate: RCBodyTemplates) {
		super.init(nibName: nil, bundle: nil)
		canExpandResponseCard = false
		
		// Set minimum height for each response card
		let header = RCBarComponent(.header, labels: ["l"], actions: [], in: MainViewController())
		let footer = RCBarComponent(.footer, labels: ["l"], actions: [], in: MainViewController())
		minimumHeight = header.frame.height + footer.frame.height
		
		switch RCBodyTemplate {
		case .list:
			minimumHeight = minimumHeight + 200
			canExpandResponseCard = true
		case .scale:
			minimumHeight = minimumHeight + 48
		case .visualUpload:
			minimumHeight = minimumHeight + ((constraint(.contentWidth) * 3) / 4)
		case .audioUpload:
			minimumHeight = minimumHeight + 104
		case .datePicker:
			let row = UIButton(frame: CGRect.zero)
			row.setTitle(" ", for: .normal)
			row.titleLabel!.font = UILabel().Raleway(textStyle: .body, weight: .bold)
			row.sizeToFit()
			
			let innerPaddingVertical = RCDatePickerComponent().innerPaddingVertical
			row.resizeTo(width: 0, height: row.frame.height + (innerPaddingVertical * 2))
			
			minimumHeight = minimumHeight + (row.frame.height * 5)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		minimumHeight = nil
	}
	
	override func didMove(toParentViewController parent: UIViewController?) {
		if let main = parent as? MainViewController {
			let content = main.ResponseCard!.content!
			let header = content.header!
			var footer: RCBarComponent? = nil
			
			// Create view for body
			var height =  -(header.frame.height)
			if canExpandResponseCard { height = height + cardConstraint(.maximumHeight) }
			else { height = height + minimumHeight }
			if let FOOTER = content.footer {
				footer = FOOTER
				height -= footer!.frame.height
				
			}
			let BODY_VIEW = UIView(frame: CGRect.zero)
			BODY_VIEW.move(x: nil, y: header.frame.height)
			BODY_VIEW.resizeTo(width: constraint(.contentWidth), height: height)
			view.addSubview(BODY_VIEW)
			
			// Connect RCBodyView to necessary view controllers
			switch content.template! {
			case .list:
				let BODY_CONTENT = content.body as! RCList
				BODY_VIEW.addSubview(BODY_CONTENT.view)
				addChildViewController(BODY_CONTENT)
				BODY_CONTENT.didMove(toParentViewController: self)
				BODY_CONTENT.delegate = self
				break
				
			case .scale:
				let BODY_CONTENT = content.body as! RCScale
				BODY_VIEW.addSubview(BODY_CONTENT.view)
				addChildViewController(BODY_CONTENT)
				BODY_CONTENT.didMove(toParentViewController: self)
				break
				
			case .visualUpload:
				let BODY_CONTENT = content.body as! RCVisualUpload
				BODY_VIEW.addSubview(BODY_CONTENT.view)
				addChildViewController(BODY_CONTENT)
				BODY_CONTENT.didMove(toParentViewController: self)
				break
				
			case .audioUpload:
				let BODY_CONTENT = content.body as! RCAudioUpload
				BODY_VIEW.addSubview(BODY_CONTENT.view)
				addChildViewController(BODY_CONTENT)
				BODY_CONTENT.didMove(toParentViewController: self)
				break
				
			case .datePicker:
				let RCBodyContent = content.body as! RCDatePickerController
				BODY_VIEW.addSubview(RCBodyContent.view)
				addChildViewController(RCBodyContent)
				RCBodyContent.didMove(toParentViewController: self)
				break
			}
			
			// Add headers and footers
			view.addSubview(header.shadow)
			view.addSubview(header)
			if let footer = footer {
				footer.move(x: nil, y: origins.bottom)
				footer.shadow!.setOrigin(equalTo: footer)
				view.addSubview(footer.shadow)
				view.addSubview(footer)
			}
		}
	}
	
	func RCResponseCardViewDidChange() {
		let THRESHOLD: CGFloat = 0.25
		let OriginY_THRESHOLD_MAXIMIZED = constraint(.deviceHeight) * THRESHOLD
		
		if let main = parent as? MainViewController {
			if main.ResponseCard!.frame.origin.y < OriginY_THRESHOLD_MAXIMIZED {
				changeState(to: .maximized)
			} else { changeState(to: .minimized) }
		}
	}
	
	func changeState(to state: cardStates) {
		if let main = parent as? MainViewController {
			let ResponseCard = main.ResponseCard!
			
			let NEW_Height: CGFloat
			let NEW_OriginY: CGFloat
			var shouldRemoveGestureRecognizer = false
			
			switch state {
			case .minimized:
				NEW_OriginY = cardConstraint(.OriginY_Minimized)
				NEW_Height = minimumHeight
				
				switch ResponseCard.content!.template { // Determine any card maximization specialties
				case .list:
					(ResponseCard.content!.body as! RCList).collectionView!.isScrollEnabled = false
					break
				default:
					break
				}
			case .maximized:
				NEW_OriginY = cardConstraint(.OriginY_Maximized)
				NEW_Height = cardConstraint(.maximumHeight)
				
				if ResponseCard.content!.template == .list {
					if let main = parent as? MainViewController {
						(main.ResponseCard!.content!.body as! RCList).collectionView!.isScrollEnabled = true
					}
				}
				
				shouldRemoveGestureRecognizer = true
			}
			
			UIView.animate(withDuration: 0.3) {
				ResponseCard.move(x: nil, y: NEW_OriginY)
				ResponseCard.resizeTo(width: nil, height: NEW_Height)
				ResponseCard.shadow!.setFrame(equalTo: ResponseCard)
				
				if let footer = ResponseCard.content!.footer {
					footer.move(x: nil, y: origins.bottom)
					footer.shadow!.setFrame(equalTo: footer)
				}
			}
			
			if shouldRemoveGestureRecognizer {
				for gestureRecognizer in ResponseCard.gestureRecognizers! {
					ResponseCard.removeGestureRecognizer(gestureRecognizer)
				}
			}
		}
	}
	
	func cardConstraint(_ object: RCResponseCardContraints) -> CGFloat {
		if let main = parent as? MainViewController {
			switch object {
			case .maximumHeight:
				return constraint(.deviceHeight) - main.ChatToolbar.view.frame.height - self.cardConstraint(.OriginY_Maximized) - constraint(.contentSpacing)
			case .OriginY_Minimized:
				return constraint(.deviceHeight) - main.ChatToolbar.view.frame.height - constraint(.contentSpacing) -  self.minimumHeight!
			case .OriginY_Maximized:
				return main.view.safeAreaInsets.top + constraint(.contentSpacing)
			}
		} else { return 0 }
	}
}

class RCResponseCardViewShadow: UIView {
	convenience init(for RCResponseCardView: RCResponseCard) {
		self.init(frame: RCResponseCardView.frame)
		convertToShadow(opacity: 0.15, offset: CGSize.zero, cornerRadius: RCResponseCardView.layer.cornerRadius, shadowRadius: 2)
	}
}
