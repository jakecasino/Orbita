//
//  ResponseCardListCollectionViewController.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit

class RCList: UICollectionViewController, UICollectionViewDelegateFlowLayout, RCResponseCardDataSource {
	
	// Properties
	var HEADER_TITLE: String?
	var HEADER_ACTION: RCAction?
	var FOOTER_ACTION: RCAction?
	var delegate: RCDelegate?
	
	var items = [String]()
	let CELL_ITEM = "item"
	
	// Initializers
	init(list: [String], canSelectMultipleItems: Bool) {
		super.init(nibName: nil, bundle: nil)
		view = UIView(frame: CGRect.zero)
		items = list
		
		let layout = UICollectionViewFlowLayout()
		let inset = spacing(.small)
		layout.sectionInset = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
		
		collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		collectionView!.backgroundColor = color(.lighterGrey)
		collectionView!.isScrollEnabled = false
		view.addSubview(collectionView!)
		
		collectionView!.register(RCListItem.self, forCellWithReuseIdentifier: CELL_ITEM)
		
		if canSelectMultipleItems { collectionView!.allowsMultipleSelection = true }
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		HEADER_TITLE = nil
		HEADER_ACTION = nil
		FOOTER_ACTION = nil
		delegate = nil
		items.removeAll()
		collectionView = nil
	}
	
	override func didMove(toParentViewController parent: UIViewController?) {
		if let superview = view.superview {
			view.setFrame(equalTo: superview.bounds)
			collectionView!.setFrame(equalTo: view)
			FOOTER_ACTION!.addTarget(self, action: #selector(maximizeCard), for: .touchUpInside)
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return items.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_ITEM, for: indexPath) as! RCListItem
		cell.createListLabel(for: items[indexPath.row])
		cell.visualSetup(backgroundColor: UIColor(white: 0, alpha: 0.15), cornerRadius: cornerRadius(.medium), masksToBounds: true, alpha: nil)
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		func labelHeight(font: UIFont, width: CGFloat) -> CGFloat {
			let label = UILabel(frame: CGRect.zero)
			label.resizeTo(width: width, height: CGFloat.greatestFiniteMagnitude)
			label.numberOfLines = 0
			label.lineBreakMode = NSLineBreakMode.byWordWrapping
			label.font = font
			label.text = "l"
			
			label.sizeToFit()
			return label.frame.height
		}
		let width: CGFloat = view.frame.width - (spacing(.small) * 2)
		let height = labelHeight(font: UILabel().Raleway(textStyle: .body, weight: .regular), width: width) + (ALT_spacing(.medium) * 2)
		return CGSize(width: width, height: height)
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		HEADER_TOGGLE_ACTION()
	}
	
	override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		HEADER_TOGGLE_ACTION()
	}
	
	func HEADER_TOGGLE_ACTION() {
		if let main = delegate!.parent as? MainViewController {
			if main.ResponseCard!.content!.header!.RCActions.indices.contains(0) {
				if !collectionView!.indexPathsForSelectedItems!.isEmpty {
					HEADER_ACTION!.isEnabled = true
				} else {
					HEADER_ACTION!.isEnabled = false
				}
			}
		}
	}
	
	@objc func maximizeCard() {
		delegate!.changeState(to: .maximized)
	}
}

class RCListItem: UICollectionViewCell {
	
	override var isSelected: Bool {
		didSet {
			if self.isSelected  {
				let checkmark = UIButton(frame: CGRect.zero)
				addSubview(checkmark)
				
				let checkmarkSize: CGFloat = 30
				checkmark.resizeTo(width: checkmarkSize, height: checkmarkSize)
				checkmark.move(x: self.frame.width - checkmarkSize - spacing(.small), y: origins.middle)
				checkmark.setImage(glyph(.checkmark), for: .normal)
				checkmark.tintColor = UIColor.white
				
				UIView.animate(withDuration: 0.15) {
					self.backgroundColor = color(.orbitaBlue)
				}
			} else {
				backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)
				for view in subviews {
					if let checkmark = view as? UIButton {
						checkmark.removeFromSuperview()
					}
				}
			}
		}
	}
	
	func createListLabel(for listItem: String) {
		let label = UILabel(frame: CGRect.zero)
		label.text = listItem
		label.textColor = UIColor.white
		label.font = label.Raleway(textStyle: .body, weight: .regular)
		label.sizeToFit()
		label.move(x: spacing(.medium), y: ALT_spacing(.medium))
		addSubview(label)
	}
}
