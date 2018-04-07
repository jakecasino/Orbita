//
//  ResponseCardListCollectionViewController.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit
class RCBodyListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	var collectionView: UICollectionView?
	var list = [String]()
	
	init(list: [String], canSelectMultipleItems: Bool) {
		super.init(nibName: nil, bundle: nil)
		self.list = list
		
		let layout = UICollectionViewFlowLayout()
		layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
		collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
		collectionView!.backgroundColor = UIColor(named: "Light Grey")
		collectionView!.isScrollEnabled = false
		collectionView!.dataSource = self
		collectionView!.delegate = self
		collectionView!.register(RCBodyListItem.self, forCellWithReuseIdentifier: "ResponseCardListItem")
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
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return list.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResponseCardListItem", for: indexPath) as! RCBodyListItem
		cell.createListLabel(for: list[indexPath.row])
		cell.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
		cell.layer.cornerRadius = 12
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
		let margin: CGFloat = 8
		let width: CGFloat = view.frame.width - (margin * 2)
		let height = labelHeight(font: UIFont.preferredFont(forTextStyle: .body), width: width) + 24
		return CGSize(width: width, height: height)
	}

}

class RCBodyListItem: UICollectionViewCell {
	
	override var isSelected: Bool {
		didSet {
			if self.isSelected  {
				UIView.animate(withDuration: 0.15) {
					self.backgroundColor = UIColor(named: "Orbita Blue")
					let checkmarkSize: CGFloat = 30
					let padding: CGFloat = 8
					let checkmark = UIButton(frame: CGRect(x: self.frame.width - checkmarkSize - padding, y: (self.frame.height - checkmarkSize) / 2, width: checkmarkSize, height: checkmarkSize))
					checkmark.setImage(UIImage(named: "Checkmark"), for: .normal)
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
		label.font = UIFont.preferredFont(forTextStyle: .body)
		label.sizeToFit()
		label.frame.origin = CGPoint(x: 16, y: 12)
		addSubview(label)
	}
}
