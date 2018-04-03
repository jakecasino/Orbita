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
		ChatViewController?.generate("Response Card")
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
