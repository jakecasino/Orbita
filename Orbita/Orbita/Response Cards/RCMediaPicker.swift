//
//  RCMediaPicker.swift
//  Orbita
//
//  Created by Jake Casino on 4/12/18.
//

import UIKit

class RCMediaPicker: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	func photoLibrary() {
		if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
			let myPickerController = UIImagePickerController()
			myPickerController.delegate = self
			myPickerController.sourceType = .photoLibrary
			// currentVC.present(myPickerController, animated: true, completion: nil)
		}
	}
}
