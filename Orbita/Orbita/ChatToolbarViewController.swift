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
		
		let list = ["Lower Back", "Upper Back", "Neck", "Left Shoulder", "Right Shoulder", "Biceps", "Triceps"]
		
		let header = RCHeader(title: "Choose All that Apply", enableSendButton: true, in: ChatViewController!)
		
		let RCBodyContent = RCBodyListViewController(list: list, canSelectMultipleItems: true)
		let RCBodyView = RCBody(RCBodyViewController: RCBodyContent, as: .list)
		
		ChatViewController!.showResponseCard(RCHeader: header, RCBody: RCBodyView, footer: nil)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
