//
//  RCBodyScale.swift
//  Orbita
//
//  Created by Jake Casino on 4/6/18.
//

import UIKit

class RCScale: UIViewController {
	var range = [Int]()
	var handle: UIView?
	var RCHeaderTitle: String?
	var handleValue: UILabel?
	
	init(title: String, range: [Int]) {
		super.init(nibName: nil, bundle: nil)
		self.RCHeaderTitle = title
		self.range = range
		
		handle = UIView(frame: CGRect.zero)
		handle!.backgroundColor = UIColor(named: "Orbita Blue")
		handle!.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(sliderWasDragged(gesture:))))
		handle!.layer.masksToBounds = true
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		range.removeAll()
	}
	
	override func didMove(toParentViewController parent: UIViewController?) {
		view.frame = view.superview!.bounds
		handle!.frame.size = CGSize(width: 8, height: view.frame.height - 12)
		handle!.layer.cornerRadius = handle!.frame.width / 2
		handle!.frame.origin = CGPoint(x: (view.frame.width - handle!.frame.width) / 2, y: (view.frame.height - handle!.frame.height) / 2)
		handleValue!.text = Int(handle!.frame.origin.x).description
		handleValue!.textColor = UIColor(named: "Orbita Blue")
		view.addSubview(handle!)
	}
	
	@objc func sliderWasDragged(gesture: UIPanGestureRecognizer) {
		if gesture.state == .changed {
			let translation = gesture.translation(in: self.view)
			let newPosition = gesture.view!.frame.origin.x + translation.x
			if newPosition > (view.frame.height - handle!.frame.height) / 2 { // Leftmost stop
				if newPosition < view.frame.width - (handle!.frame.width + ((view.frame.height - handle!.frame.height) / 2)) { // Rightmost stop
					handle!.frame.origin = CGPoint(x: newPosition, y: gesture.view!.frame.origin.y)
					gesture.setTranslation(CGPoint.zero, in: self.view)
					handleValue!.text = Int(newPosition).description
				}
			}
		}
	}
}
