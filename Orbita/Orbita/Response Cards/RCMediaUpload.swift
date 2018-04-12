//
//  RCMediaPicker.swift
//  Orbita
//
//  Created by Jake Casino on 4/12/18.
//

import UIKit

class RCMediaUpload: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	var mediaType: mediaTypes?
	var liveIsEnabled: Bool?
	
	enum mediaTypes {
		case image
		case video
		case audio
	}
	
	init(type: mediaTypes, enableLive liveIsEnabled: Bool) {
		super.init(nibName: nil, bundle: nil)
		self.mediaType = type
		self.liveIsEnabled = liveIsEnabled
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func didMove(toParentViewController parent: UIViewController?) {
		view.frame = view.superview!.bounds
		
		let dash = CAShapeLayer()
		dash.strokeColor = UIColor(named: "Medium Grey")!.cgColor
		dash.lineDashPattern = [13, 13]
		dash.lineWidth = 2
		dash.frame = view.bounds
		dash.transform = CATransform3DMakeScale(-0.85, -0.85, 0)
		dash.fillColor = nil
		dash.path = UIBezierPath(rect: view.bounds).cgPath
		view.layer.addSublayer(dash)
	}
	
	func photoLibrary() {
		if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
			let myPickerController = UIImagePickerController()
			myPickerController.delegate = self
			myPickerController.sourceType = .photoLibrary
			// currentVC.present(myPickerController, animated: true, completion: nil)
		}
	}
}
