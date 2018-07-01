//
//  ChatToolbarViewController.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit

class ChatToolbarDelegate: UIViewController {
	var microphone: Button!
	var more: Button!
	
	override func didMove(toParentViewController parent: UIViewController?) {
		if let main = parent {
			let microphoneSize: CGFloat = 76
			let	secondaryButtonSize: CGFloat = 34
			
			view.resizeTo(width: constraint(.deviceWidth), height: microphoneSize + main.view.safeAreaInsets.bottom + (spacing(.medium) * 2))
			view.moveTo(x: nil, y: origins.bottom)
			view.visualSetup(backgroundColor: UIColor.white, cornerRadius: nil, masksToBounds: nil, alpha: nil)
			
			microphone = Button(withGlyph: UIImage(named: "Microphone")!, backgroundColor: color(.orbitaBlue), nil, cornerRadius: roundedCorners(size: microphoneSize))
			microphone.resizeTo(width: microphoneSize, height: microphoneSize)
			view.addSubview(microphone)
			microphone.moveTo(x: origins.center, y: origins.middle)
			
			more = Button(withGlyph: UIImage(named: "More")!, backgroundColor: UIColor.clear, color(.mediumGrey), cornerRadius: nil)
			more.resizeTo(width: secondaryButtonSize, height: secondaryButtonSize)
			view.addSubview(more)
			more.moveTo(x: view.bounds.width - secondaryButtonSize - spacing(.extraLarge), y: origins.middle)
			more.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ShowResponseCard(_:))))
		}
	}
	
	@objc func ShowResponseCard(_ sender: Any) {
		if let main = parent as? MainViewController {
			
			let alertView = UIAlertController(title: "Response Cards", message: "Which one did you want to see?", preferredStyle: .actionSheet)
			let showSingleSelectionList = UIAlertAction(title: "Single Selection List", style: .default) { (action) in
				let list = ["Lorem", "Ipsum", "Dolor", "Sit Amet", "Consectetur", "Adipiscing", "Elit", "Mauris mollis", "Nisi id tortor", "Blandit", "Nec vestibulum", "Ligula", "Tincidunt"]
				
				let Body = RCList(list: list, canSelectMultipleItems: false)
				let Content = RCContent(RCBody: Body, as: .list, in: main)
				main.showResponseCard(RCContent: Content)
			}
			let showMultipleSelectionList = UIAlertAction(title: "Multiple Selection List", style: .default) { (action) in
				let list = ["Lorem", "Ipsum", "Dolor", "Sit Amet", "Consectetur", "Adipiscing", "Elit", "Mauris mollis", "Nisi id tortor", "Blandit", "Nec vestibulum", "Ligula", "Tincidunt"]
				
				let Body = RCList(list: list, canSelectMultipleItems: true)
				let Content = RCContent(RCBody: Body, as: .list, in: main)
				main.showResponseCard(RCContent: Content)
			}
			let showDiscreteScale = UIAlertAction(title: "Discrete Scale", style: .default) { (action) in
				let Body = RCScale(title: "Pain Level", range: [1,5])
				let Content = RCContent(RCBody: Body, as: .scale, in: main)
				main.showResponseCard(RCContent: Content)
			}
			let showContinuousScale = UIAlertAction(title: "Continuous Scale", style: .default) { (action) in
				let Body = RCScale(title: "Current Mood", range: ["Sad", "Happy"])
				let Content = RCContent(RCBody: Body, as: .scale, in: main)
				main.showResponseCard(RCContent: Content)
			}
			let showImageUpload = UIAlertAction(title: "Image Upload", style: .default) { (action) in
				let Body = RCVisualUpload(title: "Cut", type: RCVisualUpload.mediaTypes.image, enableLive: false)
				let Content = RCContent(RCBody: Body, as: .visualUpload, in: main)
				main.showResponseCard(RCContent: Content)
			}
			let showAudioUpload = UIAlertAction(title: "Audio Upload", style: .default) { (action) in
				let Body = RCAudioUpload(title: "Speech Test")
				let Content = RCContent(RCBody: Body, as: .audioUpload, in: main)
				main.showResponseCard(RCContent: Content)
			}
			let showDatePicker = UIAlertAction(title: "Date Picker", style: .default) { (action) in
				let Body = RCDatePickerController(HeaderTitle: "Birthday", pickerStyle: .date)
				let Content = RCContent(RCBody: Body, as: .datePicker, in: main)
				main.showResponseCard(RCContent: Content)
			}
			alertView.addAction(showSingleSelectionList)
			alertView.addAction(showMultipleSelectionList)
			alertView.addAction(showDiscreteScale)
			alertView.addAction(showContinuousScale)
			alertView.addAction(showImageUpload)
			alertView.addAction(showAudioUpload)
			alertView.addAction(showDatePicker)
			present(alertView, animated: true, completion: nil)
		}
	}
}
