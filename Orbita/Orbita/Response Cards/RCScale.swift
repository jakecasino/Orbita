//
//  RCBodyScale.swift
//  Orbita
//
//  Created by Jake Casino on 4/6/18.
//

import UIKit

class RCScale: UIViewController {
	var range = [Int]()
	
	init(range: [Int]) {
		super.init(nibName: nil, bundle: nil)
		self.range = range
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		range.removeAll()
	}
}
