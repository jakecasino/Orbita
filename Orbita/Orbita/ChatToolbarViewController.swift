//
//  ChatToolbarViewController.swift
//  Orbita
//
//  Created by Jake Casino on 3/30/18.
//

import UIKit

class ChatToolbarViewController: UIViewController {
	var ResponseCardViewController: ResponseCardViewController?
	
	@IBAction func ShowResponseCard(_ sender: Any) {
		let header = ResponseCardHeader(title: "Choose all that apply")
		ResponseCardViewController?.showResponseCard(header: header, footer: nil, minimumHeight: 300)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
