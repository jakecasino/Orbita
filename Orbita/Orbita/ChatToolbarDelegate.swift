//
//  ChatToolbarViewController.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit

class ChatToolbarDelegate: UIViewController {
	
	@IBAction func ShowResponseCard(_ sender: Any) {
		if let MainView = parent as? MainViewController {
			if MainView.RCViewController == nil {
				MainView.RCViewController = RCDelegate(with: .list)
			}
			
			let alertView = UIAlertController(title: "Response Cards", message: "Which one did you want to see?", preferredStyle: .actionSheet)
			let showSingleSelectionList = UIAlertAction(title: "Single Selection List", style: .default) { (action) in
				let list = ["Lorem", "Ipsum", "Dolor", "Sit Amet", "Consectetur", "Adipiscing", "Elit", "Mauris mollis", "Nisi id tortor", "Blandit", "Nec vestibulum", "Ligula", "Tincidunt"]
				
				let Body = RCList(list: list, canSelectMultipleItems: false)
				let Content = RCContent(RCBody: Body, as: .list, in: MainView)
				MainView.showResponseCard(RCContent: Content)
			}
			let showMultipleSelectionList = UIAlertAction(title: "Multiple Selection List", style: .default) { (action) in
				let list = ["Lorem", "Ipsum", "Dolor", "Sit Amet", "Consectetur", "Adipiscing", "Elit", "Mauris mollis", "Nisi id tortor", "Blandit", "Nec vestibulum", "Ligula", "Tincidunt"]
				
				let Body = RCList(list: list, canSelectMultipleItems: true)
				let Content = RCContent(RCBody: Body, as: .list, in: MainView)
				MainView.showResponseCard(RCContent: Content)
			}
			let showDiscreteScale = UIAlertAction(title: "Discrete Scale", style: .default) { (action) in
				let Body = RCScale(title: "Pain Level", range: [1,5])
				let Content = RCContent(RCBody: Body, as: .scale, in: MainView)
				MainView.showResponseCard(RCContent: Content)
			}
			let showContinuousScale = UIAlertAction(title: "Continuous Scale", style: .default) { (action) in
				let Body = RCScale(title: "Current Mood", range: ["Sad", "Happy"])
				let Content = RCContent(RCBody: Body, as: .scale, in: MainView)
				MainView.showResponseCard(RCContent: Content)
			}
			let showImageUpload = UIAlertAction(title: "Image Upload", style: .default) { (action) in
				let Body = RCVisualUpload(type: RCVisualUpload.mediaTypes.image, enableLive: false)
				let Content = RCContent(RCBody: Body, as: .visualUpload, in: MainView)
				MainView.showResponseCard(RCContent: Content)
			}
			let showAudioUpload = UIAlertAction(title: "Audio Upload", style: .default) { (action) in
				let Body = RCAudioUpload(title: "Speech Test")
				let Content = RCContent(RCBody: Body, as: .audioUpload, in: MainView)
				MainView.showResponseCard(RCContent: Content)
			}
			let showDatePicker = UIAlertAction(title: "Date Picker", style: .default) { (action) in
				let Body = RCDatePickerController(HeaderTitle: "Birthday", pickerStyle: .date)
				let Content = RCContent(RCBody: Body, as: .datePicker, in: MainView)
				MainView.showResponseCard(RCContent: Content)
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
