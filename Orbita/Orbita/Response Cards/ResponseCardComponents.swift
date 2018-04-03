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
	init(title: String, button: UIButton) {
		createUILabel(text: title, type: .title)
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
}
struct ResponseCardFooter {
	
}
