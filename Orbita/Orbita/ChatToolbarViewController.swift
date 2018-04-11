//
//  ChatToolbarViewController.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit

class ChatToolbarViewController: UIViewController {
	var ChatViewController: ChatViewController?
	
	@IBAction func ShowResponseCard(_ sender: Any) {
		if ChatViewController!.RCViewController == nil {
			ChatViewController!.RCViewController = RCResponseCardViewController(with: .list)
		}
		showScale()
	}
	
	func showList() {
		let list = ["Lower Back", "Upper Back", "Neck", "Left Shoulder", "Right Shoulder", "Biceps", "Triceps"]
		let Body = RCList(list: list, canSelectMultipleItems: false)
		let Content = RCContent(RCBody: Body, as: .list, in: ChatViewController!)
		ChatViewController!.showResponseCard(RCContent: Content)
	}
	func showScale() {
		let Body = RCScale(title: "Pain Level", range: [1,7])
		let Content = RCContent(RCBody: Body, as: .scale, in: ChatViewController!)
		ChatViewController!.showResponseCard(RCContent: Content)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
