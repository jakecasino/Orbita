//
//  RCMediaPicker.swift
//  Orbita
//
//  Created by Jake Casino on 4/12/18.
//

import UIKit

class RCMediaUpload: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	var mediaType: mediaTypes?
	var media: Any?
	var liveIsEnabled: Bool?
	var ChooseFromLibrary: UIButton?
	
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
		
		if mediaType! != .audio {
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
		
		switch mediaType! {
		case .image:
			media = UIImageView(frame: view.bounds)
			view.addSubview(media as! UIImageView)
			ChooseFromLibrary!.addTarget(self, action: #selector(launchLibrary), for: UIControlEvents.touchUpInside)
			break
		case .video:
			break
		case .audio:
			break
		}
	}
	
	@objc func launchLibrary() {
		switch mediaType! {
		case .image:
			if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
				let imagePicker = UIImagePickerController()
				imagePicker.delegate = self
				imagePicker.sourceType = .photoLibrary
				imagePicker.allowsEditing = false
				self.present(imagePicker, animated: true, completion: nil)
			}
			break
		case .video:
			if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
				let imagePicker = UIImagePickerController()
				imagePicker.delegate = self
				imagePicker.sourceType = .photoLibrary
				imagePicker.allowsEditing = false
				self.present(imagePicker, animated: true, completion: nil)
			}
			break
		case .audio:
			break
		}
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
		if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
			(media as! UIImageView).image = image
			(media as! UIImageView).contentMode = .scaleAspectFill
		}
		
		self.dismiss(animated: true, completion: nil)
	}
}
