//
//  ResponseCardListCollectionViewController.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit
class ResponseCardListItem: UICollectionViewCell {
	
	override var isSelected: Bool {
		didSet {
			if self.isSelected  {
				backgroundColor = UIColor(named: "Orbita Blue")
			} else {
				backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15)
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
class ResponseCardListCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	var collectionView: UICollectionView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let layout = UICollectionViewFlowLayout()
		layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
		collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
		collectionView?.backgroundColor = UIColor(named: "Light Grey")
		collectionView?.dataSource = self
		collectionView?.delegate = self
		collectionView?.register(ResponseCardListItem.self, forCellWithReuseIdentifier: "ResponseCardListItem")
		view.addSubview(collectionView!)
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 15
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResponseCardListItem", for: indexPath) as! ResponseCardListItem
		cell.createListLabel(for: "Hello")
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
		let width = view.frame.width - (margin * 2)
		let height = labelHeight(font: UIFont.preferredFont(forTextStyle: .body), width: width) + 24
		return CGSize(width: width, height: height)
	}

}
