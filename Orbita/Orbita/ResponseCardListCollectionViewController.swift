//
//  ResponseCardListCollectionViewController.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit
class ResponseCardListItem: UICollectionViewCell {
	@IBOutlet weak var label: UILabel!
	
}
class ResponseCardListCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	@IBOutlet weak var collectionView: UICollectionView!
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 15
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResponseCardListItem", for: indexPath) as! ResponseCardListItem
		cell.label.text = "Label"
		cell.label.frame.origin.x = 16
		cell.label.frame.origin.y = 12
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
	
	func generate(_ object: String) {
		
	}
	
	func get(_ object: String,_ parameter: String?) -> Any? {
		switch object {
		case "height":
			switch parameter {
			case "label, body, single line":
				return nil
			default:
				return nil
			}
		default:
			return nil
		}
	}

}
