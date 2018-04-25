//
//  RCMediaPicker.swift
//  Orbita
//
//  Created by Jake Casino on 4/12/18.
//

import UIKit

class RCVisualUpload: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, RCResponseCard {
	var RCHeaderSendButton: RCAction?
	
	var mediaType: mediaTypes?
	var media: UIImageView?
	var liveIsEnabled: Bool?
	var ChooseFromLibrary: RCAction?
	var captureButton: UIButton?
	
	enum mediaTypes {
		case image
		case video
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
		
		if !liveIsEnabled! {
			let dashBorder = CAShapeLayer()
			dashBorder.strokeColor = UIColor(named: "Medium Grey")!.cgColor
			dashBorder.lineDashPattern = [13, 13]
			dashBorder.lineWidth = 2
			dashBorder.frame = view.bounds
			dashBorder.transform = CATransform3DMakeScale(-0.85, -0.85, 0)
			dashBorder.fillColor = nil
			dashBorder.path = UIBezierPath(rect: view.bounds).cgPath
			view.layer.addSublayer(dashBorder)
			
			let placeholderIconSize: CGFloat = 72
			let placeholderIcon = UIImageView(frame: CGRect(x: (view.frame.width - placeholderIconSize) / 2, y: (view.frame.height - placeholderIconSize) / 2, width: placeholderIconSize, height: placeholderIconSize))
			placeholderIcon.image = UIImage(named: "Photo")
			placeholderIcon.tintColor = UIColor(named: "Medium Grey")
			view.addSubview(placeholderIcon)
		}
		
		switch mediaType! {
		case .image:
			media = UIImageView(frame: view.bounds)
			view.addSubview(media!)
			ChooseFromLibrary!.addTarget(self, action: #selector(launchLibrary), for: UIControlEvents.touchUpInside)
			break
		case .video:
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
		}
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
		if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
			media!.image = image
			media!.contentMode = .scaleAspectFill
			RCHeaderSendButton!.isEnabled = true
		}
		
		self.dismiss(animated: true, completion: nil)
	}
}
