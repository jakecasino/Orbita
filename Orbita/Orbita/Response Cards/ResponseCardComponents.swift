//
//  ResponseCardComponents.swift
//  Orbita
//
//  Created by Jake Casino on 4/3/18.
//

import UIKit
enum ResponseCardHeaderLabelType {
	case title
	case subtitle
}
class ResponseCardHeader {
	var title: UILabel!
	var subtitle: UILabel?
	var button: UIButton?
	
	init(title: String) {
		createUILabel(text: title, type: .title)
	}
	init(title: String, subtitle: String) {
		createUILabel(text: title, type: .title)
		createUILabel(text: subtitle, type: .subtitle)
	}
	init(title: String, button: String) {
		createUILabel(text: title, type: .title)
		let circleSize: CGFloat = 30
		let button = UIButton(frame: CGRect(x: 0, y: 0, width: circleSize, height: circleSize))
		button.setImage(UIImage(named: "Send"), for: .normal)
		button.tintColor = UIColor.white
		button.backgroundColor = UIColor(named: "Orbita Blue")
		button.layer.cornerRadius = circleSize / 2
		self.button = button
	}
	
	func createUILabel(text: String, type: ResponseCardHeaderLabelType) {
		let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
		label.text = text.uppercased()
		label.textColor = UIColor.black
		
		switch type {
		case .title:
			label.font = UIFont.boldSystemFont(ofSize: 12.0)
			label.sizeToFit()
			title = label
			break
		case .subtitle:
			label.font = UIFont.preferredFont(forTextStyle: .footnote)
			label.sizeToFit()
			subtitle = label
			break
		}
	}
	
	func createFrame(in ResponseCard: ResponseCardViewController) -> UIView {
		let padding: CGFloat = 16
		let width = ResponseCard.view.frame.width
		let height = title.frame.height + (padding * 2)
		let frame = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
		frame.backgroundColor = UIColor.white
		
		title.frame.origin = CGPoint(x: padding, y: padding)
		frame.addSubview(title)
		
		if let button = button {
			button.frame.origin = CGPoint(x: width - padding - button.frame.width, y: (height - button.frame.height) / 2)
			frame.addSubview(button)
		}
		
		return frame
	}
	
	func createShadow(in ResponseCard: ResponseCardViewController) -> UIView {
		let shadow = UIView(frame: CGRect(x: 0, y: 0, width: ResponseCard.view.frame.width, height: title.frame.height + 32))
		shadow.layer.shadowPath = UIBezierPath(rect: shadow.bounds).cgPath
		shadow.layer.shadowColor = UIColor.black.cgColor
		shadow.layer.shadowOpacity = 0.5
		shadow.layer.masksToBounds = false
		shadow.layer.shadowOffset = CGSize(width: 0, height: -4)
		return shadow
	}
}
struct ResponseCardFooter {
	
}
