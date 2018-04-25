//
//  RCDatePicker.swift
//  Orbita
//
//  Created by Jake Casino on 4/25/18.
//

import UIKit

class RCDatePickerController: UIViewController, RCResponseCard {
	var HeaderTitle: String!
	var RCHeaderSendButton: RCAction?
	var picker: RCDatePickerView!
	
	convenience init(HeaderTitle: String, pickerStyle: RCDatePickerStyles) {
		self.init(nibName: nil, bundle: nil)
		self.HeaderTitle = HeaderTitle
		
		picker = RCDatePickerView(pickerStyle: pickerStyle)
	}
	
	override func didMove(toParentViewController parent: UIViewController?) {
		if let parent = parent {
			view.frame = parent.view.bounds
			view.addSubview(picker)
			picker.reloadAllComponents()
		}
	}
}

enum RCDatePickerStyles {
	case date
	case dateAndTime
}

class RCDatePickerView: UIPickerView {
	var components = [component]()
	var style: RCDatePickerStyles!
	
	enum Months: String {
		case JAN = "January"
		case FEB = "February"
		case MAR = "March"
		case APR = "April"
		case MAY = "May"
		case JUN = "June"
		case JUL = "July"
		case AUG = "August"
		case SEP = "September"
		case OCT = "October"
		case NOV = "November"
		case DEC = "December"
		
		static let all = [JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV, DEC]
	}
	
	struct component {
		var items: [String]!
	}
	
	init(pickerStyle: RCDatePickerStyles) {
		super.init(frame: CGRect.zero)
		style = pickerStyle
		dataSource = self
		delegate = self
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func didMoveToSuperview() {
		if let superview = superview {
			frame = superview.bounds
		}
	}
	
	func numberOfDays(in month: Months) -> Int {
		switch month {
		case .JAN: return 31
		case .FEB: return 28
		case .MAR: return 31
		case .APR: return 30
		case .MAY: return 31
		case .JUN: return 30
		case .JUL: return 31
		case .AUG: return 31
		case .SEP: return 30
		case .OCT: return 31
		case .NOV: return 30
		case .DEC: return 31
		}
	}
}

extension RCDatePickerView: UIPickerViewDataSource {
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		switch style! {
		case .date:
			switch component {
			case 0: return Months.all.count
			case 1: return 31
			case 2: return 100
			default: return 0
			}
		case .dateAndTime:
			return 0
		}
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 3
	}
}

extension RCDatePickerView: UIPickerViewDelegate {
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return getTitle(forRow: row, inComponent: component)
	}
	func getTitle(forRow row: Int, inComponent component: Int) -> String {
		switch style! {
		case .date:
			switch component {
			case 0: return Months.all[row].rawValue
			case 1: return String(row + 1)
			case 2: return String(2018 - row)
			default: return "bye"
			}
		case .dateAndTime:
			return "Hello"
		}
	}
	func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		let title = getTitle(forRow: row, inComponent: component)
		let titleFormat = NSAttributedString(string: title, attributes: [NSAttributedStringKey.font: UIFont(name: "Raleway-Bold", size: UIFont.preferredFont(forTextStyle: .body).pointSize)!])
		return titleFormat
	}
}
