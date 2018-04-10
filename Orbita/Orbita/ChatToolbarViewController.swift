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
		
		// Define the body for RCResponse Card
		let list = ["Lower Back", "Upper Back", "Neck", "Left Shoulder", "Right Shoulder", "Biceps", "Triceps"]
		let Body = RCList(list: list, canSelectMultipleItems: false)
		
		// Build and package the necessary RCComponents
		let Content = RCContent(RCBody: Body, as: .list, in: ChatViewController!)
		
		// Send the RCContent package to ChatViewController
		ChatViewController!.showResponseCard(RCContent: Content)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
