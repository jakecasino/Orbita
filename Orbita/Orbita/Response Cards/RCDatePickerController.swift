//
//  RCDatePicker.swift
//  Orbita
//
//  Created by Jake Casino on 4/25/18.
//

import UIKit

class RCDatePickerController: UIViewController, RCResponseCardComponents {
	var HeaderTitle: String!
	var RCHeaderSendButton: RCAction?
	var picker: RCDatePickerView!
	
	convenience init(HeaderTitle: String, pickerStyle: RCDatePickerStyles) {
		self.init(nibName: nil, bundle: nil)
		self.HeaderTitle = HeaderTitle
		
		picker = RCDatePickerView(pickerStyle: pickerStyle, in: self)
	}
	
	override func didMove(toParentViewController parent: UIViewController?) {
		if let superview = view.superview {
			view.frame = superview.bounds
			view.addSubview(picker)
		}
	}
}

enum RCDatePickerStyles {
	case date
	case dateAndTime
}

class RCDatePickerView: UIView {
	var DatePickerController: RCDatePickerController!
	var components = [RCDatePickerComponent]()
	var style: RCDatePickerStyles!
	
	init(pickerStyle: RCDatePickerStyles, in RCDatePickerController: RCDatePickerController) {
		super.init(frame: CGRect.zero)
		style = pickerStyle
		DatePickerController = RCDatePickerController
		
		components.append(RCDatePickerComponent(for: .months))
		components.append(RCDatePickerComponent(for: .days))
		components.append(RCDatePickerComponent(for: .years))
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func didMoveToSuperview() {
		if let superview = superview {
			frame = superview.bounds
			
			for (index, component) in components.enumerated() {
				addSubview(component)
				
				if index == 0 {
					component.set(width: bounds.width * 0.4)
					component.setAlignmentForRows(to: .right)
				} else if index == 1 {
					component.frame.origin = CGPoint(x: components[0].frame.width + (bounds.width * 0.05), y: 0)
					component.set(width: bounds.width * 0.15)
				} else if index == 2 {
					component.frame.origin = CGPoint(x: components[1].frame.origin.x + components[1].frame.width + bounds.width * 0.05, y: 0)
					component.set(width: bounds.width * 0.35)
				}
			}
		}
	}
}

class RCDatePickerComponent: UIScrollView {
	let innerPaddingVertical: CGFloat = 4
	var template: componentTemplates?
	var rows = [UIButton]()
	
	enum componentTemplates {
		case months
		case days
		case years
	}
	
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
	
	init() {
		super.init(frame: CGRect.zero)
	}
	
	init(for template: componentTemplates) {
		super.init(frame: CGRect.zero)
		self.template = template
		contentSize = CGSize.zero
		showsVerticalScrollIndicator = false
		delegate = self
		
		var rows = [String]()
		switch template {
		case .months:
			for month in Months.all {
				rows.append(month.rawValue)
			}
		case .days:
			for day in 1...31 {
				rows.append("\(day)")
			}
		case .years:
			for year in 1930...2018 {
				rows.append("\(year)")
			}
			rows = rows.reversed()
		}
		
		for (index, rowLabel) in rows.enumerated() {
			let row = UIButton(frame: CGRect.zero)
			row.setTitle(rowLabel, for: .normal)
			row.setTitleColor(UIColor.black, for: .normal)
			row.titleLabel!.font = UILabel().Raleway(textStyle: .body, weight: .bold)
			row.isUserInteractionEnabled = false
			row.contentHorizontalAlignment = .left
			row.sizeToFit()
			
			row.frame.size = CGSize(width: 0, height: row.frame.height + (innerPaddingVertical * 2))
			
			if index == 0 {
				let startingPoint = row.frame.height * 2
				row.frame.origin = CGPoint(x: 0, y: startingPoint)
				contentSize = CGSize(width: 0, height: contentSize.height + (startingPoint * 2))
			} else {
				row.frame.origin = CGPoint(x: 0, y: self.rows[index - 1].frame.origin.y + row.frame.height)
			}
			
			self.rows.append(row)
			contentSize = CGSize(width: 0, height: contentSize.height + row.frame.height)
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func set(width: CGFloat) {
		if let superview = superview {
			frame.size = CGSize(width: width, height: superview.bounds.height)
			
			for row in rows {
				let padding: CGFloat = 12
				row.frame.size = CGSize(width: bounds.width - padding, height: row.frame.height)
				addSubview(row)
			}
			
			contentSize = CGSize(width: bounds.width, height: contentSize.height)
		}
	}
	
	func setAlignmentForRows(to alignment: UIControlContentHorizontalAlignment) {
		for row in rows {
			row.contentHorizontalAlignment = alignment
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

extension RCDatePickerComponent: UIScrollViewDelegate {
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if let parentView = superview as? RCDatePickerView {
			parentView.DatePickerController.RCHeaderSendButton!.isEnabled = true
		}
	}
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		if let parentView = superview as? RCDatePickerView {
			parentView.DatePickerController.RCHeaderSendButton!.isEnabled = true
		}
	}
}
