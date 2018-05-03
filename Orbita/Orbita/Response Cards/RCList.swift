//
//  ResponseCardListCollectionViewController.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit

class RCList: UICollectionViewController, UICollectionViewDelegateFlowLayout, RCResponseCardComponents {
	let CELL_ID = "ListItem"
	var RCHeaderSendButton: RCAction?
	
	var list = [String]()
	var SeeFullListButton: RCAction?
	var RCViewController: RCDelegate?
	
	init(list: [String], canSelectMultipleItems: Bool) {
		super.init(nibName: nil, bundle: nil)
		view = UIView(frame: CGRect.zero)
		self.list = list
		
		let layout = UICollectionViewFlowLayout()
		layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
		
		collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
		collectionView!.backgroundColor = color(.lighterGrey)
		collectionView!.isScrollEnabled = false
		collectionView!.register(RCListItem.self, forCellWithReuseIdentifier: CELL_ID)
		view.addSubview(collectionView!)
		
		if canSelectMultipleItems { collectionView!.allowsMultipleSelection = true }
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		collectionView = nil
		list.removeAll()
	}
	
	override func didMove(toParentViewController parent: UIViewController?) {
		if let superview = view.superview {
			view.frame = superview.bounds
			collectionView!.frame = view.bounds
		}
		
		SeeFullListButton!.addTarget(self, action: #selector(maximizeCard), for: .touchUpInside)
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return list.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_ID, for: indexPath) as! RCListItem
		cell.createListLabel(for: list[indexPath.row])
		cell.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
		cell.layer.cornerRadius = cornerRadius(.medium)
		cell.layer.masksToBounds = true
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		func labelHeight(font: UIFont, width: CGFloat) -> CGFloat {
			let label = UILabel(frame: CGRect(x: 0,y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
			label.numberOfLines = 0
			label.lineBreakMode = NSLineBreakMode.byWordWrapping
			label.font = font
			label.text = "l"
			
			label.sizeToFit()
			return label.frame.height
		}
		let width: CGFloat = view.frame.width - (spacing(.small) * 2)
		let height = labelHeight(font: UILabel().Raleway(textStyle: .body, weight: .regular), width: width) + 24
		return CGSize(width: width, height: height)
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		toggleSendButtonInRCHeader()
	}
	
	override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		toggleSendButtonInRCHeader()
	}
	
	func toggleSendButtonInRCHeader() {
		if RCViewController!.RCResponseCard!.RCContent!.RCHeader!.RCActions.indices.contains(0) {
			if !collectionView!.indexPathsForSelectedItems!.isEmpty {
				RCHeaderSendButton!.isEnabled = true
			} else {
				RCHeaderSendButton!.isEnabled = false
			}
		}
	}
	
	@objc func maximizeCard() {
		RCViewController!.RCResponseCardChangeState(to: .maximized)
	}
}

class RCListItem: UICollectionViewCell {
	
	override var isSelected: Bool {
		didSet {
			if self.isSelected  {
				UIView.animate(withDuration: 0.15) {
					self.backgroundColor = color(.orbitaBlue)
					let checkmarkSize: CGFloat = 30
					let checkmark = UIButton(frame: CGRect(x: self.frame.width - checkmarkSize - spacing(.small), y: (self.frame.height - checkmarkSize) / 2, width: checkmarkSize, height: checkmarkSize))
					checkmark.setImage(glyph(.checkmark), for: .normal)
					checkmark.tintColor = UIColor.white
					self.addSubview(checkmark)
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
		let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
		label.text = listItem
		label.textColor = UIColor.white
		label.font = label.Raleway(textStyle: .body, weight: .regular)
		label.sizeToFit()
		label.frame.origin = CGPoint(x: 16, y: 12)
		addSubview(label)
	}
}
