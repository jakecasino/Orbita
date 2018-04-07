//
//  ResponseCard.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit
class RCResponseCardViewController: UIViewController {
	var ChatViewController: ChatViewController?
	var minimumHeight: CGFloat?
	
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
	
	func RCResponseCardViewDidChange() {
		let percentThreshold: CGFloat = 0.25
		let originYThresholdForMaximumHeight = constraint(for: .deviceHeight, in: ChatViewController!) * percentThreshold
		let height: CGFloat
		let y: CGFloat
		if ChatViewController!.RCResponseCard!.frame.origin.y < originYThresholdForMaximumHeight {
			y = constraint(for: .originYwhenMaximized, in: ChatViewController!)
			height = constraint(for: .maximumHeight, in: ChatViewController!)
		} else {
			y = constraint(for: .originYwhenMinimized, in: ChatViewController!)
			height = constraint(for: .minimumHeight, in: ChatViewController!)
		}
		ChatViewController!.RCResponseCard!.frame = CGRect(x: constraint(for: .marginLeft, in: ChatViewController!), y: y, width: constraint(for: .width, in: ChatViewController!), height: height)
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
	
	func constraint(for constraint: RCResponseCardContraints, in ChatViewController: ChatViewController) -> CGFloat {
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
			return ChatViewController.view.frame.width
		case .deviceHeight:
			return ChatViewController.view.frame.height
		case .width:
			return self.constraint(for: .deviceWidth, in: ChatViewController) - self.constraint(for: .marginLeft, in: ChatViewController) - self.constraint(for: .marginRight, in: ChatViewController)
		case .minimumHeight:
			return self.minimumHeight!
		case .maximumHeight:
			return self.constraint(for: .deviceHeight, in: ChatViewController) - ChatViewController.ChatToolbar.frame.height - self.constraint(for: .originYwhenMaximized, in: ChatViewController) - self.constraint(for: .marginBottom, in: ChatViewController)
		case .originYwhenMinimized:
			return self.constraint(for: .deviceHeight, in: ChatViewController) - ChatViewController.ChatToolbar.frame.height - self.constraint(for: .marginBottom, in: ChatViewController) -  self.constraint(for: .minimumHeight, in: ChatViewController)
		case .originYwhenMaximized:
			return ChatViewController.view.safeAreaInsets.top + self.constraint(for: .marginTop, in: ChatViewController)
		}
	}
}

class RCResponseCardView: UIView {
	weak var RCHeader: RCHeader?
	weak var RCBodyView: RCBody?
	
	deinit {
		RCHeader = nil
		RCBodyView = nil
	}
}

class RCResponseCardViewShadow: UIView {
	
}
