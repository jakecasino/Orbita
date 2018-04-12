//
//  RCBodyScale.swift
//  Orbita
//
//  Created by Jake Casino on 4/6/18.
//

import UIKit

class RCScale: UIViewController {
	var range = [Any]()
	var handle: UIView?
	var RCHeaderTitle: String?
	var footerLabels: [UIButton]?
	var type: ScaleTypes?
	var touchPosition: UIView?
	var stops = [CGFloat]()
	var bufferZones = [CGFloat]()
	
	enum ScaleTypes {
		case continuous
		case discrete
	}
	
	init(title: String, range: [Any]) {
		super.init(nibName: nil, bundle: nil)
		self.RCHeaderTitle = title
		self.range = range
		
		if range[0] is Int {
			if ((range[1] as! Int) - (range[0] as! Int) + 1) <= 10 {
				self.type = .discrete
			} else { self.type = .continuous }
		} else { self.type = .continuous }
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	deinit {
		range.removeAll()
	}
	
	override func didMove(toParentViewController parent: UIViewController?) {
		view.frame = view.superview!.bounds
		
		handle = UIView(frame: CGRect.zero)
		handle!.backgroundColor = UIColor(named: "Orbita Blue")
		handle!.layer.masksToBounds = true
		handle!.frame.size = CGSize(width: 8, height: view.frame.height - 12)
		handle!.layer.cornerRadius = handle!.frame.width / 2
		handle!.frame.origin = CGPoint(x: (view.frame.width - handle!.frame.width) / 2, y: (view.frame.height - handle!.frame.height) / 2)
		view.addSubview(handle!)
		
		if type! == .discrete {
			touchPosition = UIView(frame: handle!.frame)
			makeSliderGrabbable()
			touchPosition!.backgroundColor = UIColor.clear
			touchPosition!.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(sliderWasDragged(gesture:))))
			view.addSubview(touchPosition!)
			
			// Create stops
			let margin: CGFloat = 16
			let leftValue: Int
			let rightValue: Int
			if (range[0] as! Int) < (range[1] as! Int) {
				leftValue = range[0] as! Int
				rightValue = range[1] as! Int
			} else {
				leftValue = range[1] as! Int
				rightValue = range[0] as! Int
			}
			let numberOfStops = rightValue - leftValue + 1
			let bufferWidth = (view.frame.width - (margin * 2)) / CGFloat(numberOfStops - 1)
			
			for index in 1 ... numberOfStops {
				if index == 1 {
					stops.append(margin)
					bufferZones.append(margin + ((bufferWidth / 2)))
				} else if index == numberOfStops {
					stops.append(view.frame.width - margin - handle!.frame.width)
					bufferZones.append(bufferZones[0] + (bufferWidth * CGFloat(index - 1)))
				} else {
					stops.append(margin + (bufferWidth * CGFloat(index - 1)) - (handle!.frame.width / 2))
					bufferZones.append(bufferZones[0] + (bufferWidth * CGFloat(index - 1)))
				}
			}
			
			range = []
			
			for (index, stop) in stops.enumerated() {
				let tick = UIView(frame: CGRect.zero)
				tick.frame.size = CGSize(width: 2, height: 12)
				tick.frame.origin = CGPoint(x: stop + (handle!.frame.width / 2) - (tick.frame.width / 2), y: ((view.frame.height - tick.frame.height) / 2))
				tick.backgroundColor = UIColor(named: "Light Grey")
				tick.layer.cornerRadius = tick.frame.width / 2
				view.insertSubview(tick, belowSubview: handle!)
				range.append(Int(index) + leftValue)
			}
			
			stops = stops.reversed()
			bufferZones = bufferZones.reversed()
			range = range.reversed()
			
			footerLabels![2].addTarget(self, action: #selector(leftValueSelected(sender:)), for: UIControlEvents.touchUpInside)
			footerLabels![0].addTarget(self, action: #selector(rightValueSelected(sender:)), for: UIControlEvents.touchUpInside)
			
		} else {
			handle!.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(sliderWasDragged(gesture:))))
		}
	}
	
	func makeSliderGrabbable() {
		touchPosition!.frame.size = CGSize(width: 44, height: touchPosition!.frame.height)
		touchPosition!.frame.origin = CGPoint(x: touchPosition!.frame.origin.x - (touchPosition!.frame.width / 2), y: touchPosition!.frame.origin.y)
	}
	
	func moveSlider(to index: Int) {
		if let sliderValue = footerLabels![1] as? UIButton {
			handle!.frame.origin = CGPoint(x: stops[index], y: handle!.frame.origin.y)
			if (index == 0 || index == range.count - 1 ) {
				sliderValue.setTitle(" ", for: .normal)
				sliderValue.alpha = 0
			} else {
				sliderValue.setTitle((range[index] as! Int).description, for: .normal)
				sliderValue.alpha = 1
				sliderValue.sizeToFit()
				sliderValue.frame.origin = CGPoint(x: handle!.frame.origin.x , y: sliderValue.frame.origin.y)
			}
		}
	}
	
	@objc func leftValueSelected(sender: UIButton) {
		moveSlider(to: 0)
		touchPosition!.frame = handle!.frame
		makeSliderGrabbable()
	}
	@objc func rightValueSelected(sender: UIButton) {
		moveSlider(to: stops.count - 1)
		touchPosition!.frame = handle!.frame
		makeSliderGrabbable()
	}
	
	@objc func sliderWasDragged(gesture: UIPanGestureRecognizer) {
		if gesture.state == .began  {
			touchPosition!.frame = handle!.frame
		}
		if gesture.state == .changed {
			let translation = gesture.translation(in: self.view)
			let newPosition = gesture.view!.frame.origin.x + translation.x
			let margin: CGFloat = 16
			if newPosition >= margin { // Leftmost stop
				if newPosition <= view.frame.width - margin - handle!.frame.width { // Rightmost stop
					switch type! {
					case .continuous:
						handle!.frame.origin = CGPoint(x: newPosition, y: gesture.view!.frame.origin.y)
					case .discrete:
						touchPosition!.frame.origin = CGPoint(x: newPosition, y: gesture.view!.frame.origin.y)
						for (index, bufferZone) in bufferZones.enumerated() {
							if touchPosition!.frame.origin.x < bufferZone {
								moveSlider(to: index)
							}
						}
					}
					gesture.setTranslation(CGPoint.zero, in: self.view)
				}
			}
		}
		if gesture.state == .ended {
			if let touchPosition = touchPosition {
				touchPosition.frame = handle!.frame
				makeSliderGrabbable()
			}
		}
	}
}
