//
//  RCBodyScale.swift
//  Orbita
//
//  Created by Jake Casino on 4/6/18.
//

import UIKit

class RCScale: UIViewController {
	var RCHeaderTitle: String?
	var RCHeaderSendButton: RCAction?
	var type: ScaleTypes?
	
	var handle: UIView?
	var touchPosition: UIView?
	
	var range = [Any]()
	var SliderValue: RCLabel?
	var SliderEndValues: [RCAction]?
	var stops = [CGFloat]()
	var bufferZones = [CGFloat]()
	var ticks = [UIView]()
	
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
		
		touchPosition = UIView(frame: handle!.frame)
		makeSliderGrabbable()
		touchPosition!.backgroundColor = UIColor.clear
		touchPosition!.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(sliderWasDragged(gesture:))))
		touchPosition!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sliderWasTapped(gesture:))))
		view.addSubview(touchPosition!)
		
		if let sliderValue = SliderValue {
			sliderValue.textColor = UIColor(named: "Orbita Blue")
		}
		
		let margin: CGFloat = 16
		let numberOfStops: Int
		var leftValue: Int
		var rightValue: Int
		var bufferWidth: CGFloat
		
		switch type! {
		case .continuous:
			leftValue = 0
			rightValue = 0
			
			var limitNotReached = true
			while limitNotReached {
				let tickWidth = 2
				let tickGutter = 8
					
				if (rightValue * (tickWidth + tickGutter)) > Int(view.frame.width + (margin * 2)) {
					limitNotReached = false
				} else {
					rightValue += 1
				}
			}
			break
		case .discrete:
			if (range[0] as! Int) < (range[1] as! Int) {
				leftValue = (range[0] as! Int)
				rightValue = (range[1] as! Int)
			} else {
				leftValue = (range[1] as! Int)
				rightValue = (range[0] as! Int)
			}
		}
		
		numberOfStops = rightValue - leftValue + 1
		bufferWidth = (view.frame.width - (margin * 2)) / CGFloat(numberOfStops - 1)
		
		for index in 1 ... numberOfStops {
			if index == 1 {
				stops.append(margin)
				bufferZones.append(margin + (bufferWidth / 2))
			} else if index == numberOfStops {
				stops.append(view.frame.width - margin - handle!.frame.width)
				bufferZones.append(bufferZones[0] + (bufferWidth * CGFloat(index - 1)))
			} else {
				let width: CGFloat
				switch type! {
				case .continuous:
					width = 2
				case .discrete:
					width = handle!.frame.width
				}
				stops.append(margin + (bufferWidth * CGFloat(index - 1)) - (width / 2))
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
			ticks.append(tick)
			view.insertSubview(ticks[index], belowSubview: handle!)
			if ((type! == .continuous) && (index == stops.count - 2)) {
				tick.backgroundColor = UIColor.clear
			}
			range.append(Int(index) + leftValue)
		}
		
		bufferZones = bufferZones.reversed()
		range = range.reversed()
		ticks = ticks.reversed()
		
		stops = stops.reversed()
		SliderEndValues![1].addTarget(self, action: #selector(leftValueSelected(sender:)), for: .touchUpInside)
		SliderEndValues![0].addTarget(self, action: #selector(rightValueSelected(sender:)), for: .touchUpInside)
	}
	
	func makeSliderGrabbable() {
		touchPosition!.frame = handle!.frame
		touchPosition!.frame.size = CGSize(width: 44, height: touchPosition!.frame.height)
		touchPosition!.frame.origin = CGPoint(x: touchPosition!.frame.origin.x - (touchPosition!.frame.width / 2), y: touchPosition!.frame.origin.y)
	}
	
	func moveSlider(to index: Int) {
		handle!.frame.origin = CGPoint(x: stops[index], y: handle!.frame.origin.y)
		if let sliderValue = SliderValue {
			if (index == 0 || index == range.count - 1 ) {
				sliderValue.alpha = 0
			} else {
				sliderValue.text = (range[index] as! Int).description
				sliderValue.alpha = 1
				sliderValue.sizeToFit()
				sliderValue.frame.origin = CGPoint(x: handle!.frame.origin.x , y: sliderValue.frame.origin.y)
			}
		}
	}
	
	@objc func leftValueSelected(sender: UIButton) {
		moveSlider(to: 0)
		makeSliderGrabbable()
		RCHeaderSendButton!.isEnabled = true
	}
	@objc func rightValueSelected(sender: UIButton) {
		moveSlider(to: stops.count - 1)
		makeSliderGrabbable()
		RCHeaderSendButton!.isEnabled = true
	}
	
	@objc func sliderWasTapped(gesture: UITapGestureRecognizer) {
		if gesture.state == .ended {
			RCHeaderSendButton!.isEnabled = true
		}
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
					touchPosition!.frame.origin = CGPoint(x: newPosition, y: gesture.view!.frame.origin.y)
					switch type! {
					case .continuous:
						handle!.frame = touchPosition!.frame
						print((handle!.frame.origin.x + (handle!.frame.width / 2)).description)
						for (index, bufferZone) in bufferZones.enumerated() {
							let handlePosition = handle!.frame.origin.x + (handle!.frame.width / 2)
							if handlePosition > bufferZone {
								if bufferZones.indices.contains(index + 1) {
									if handlePosition < bufferZones[index + 1] {
										if ticks.indices.contains(index - 2) {
											ticks[index - 2].backgroundColor = UIColor.red
										}
									}
								}
							}
						}
						break
					case .discrete:
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
			RCHeaderSendButton!.isEnabled = true
			if let touchPosition = touchPosition {
				touchPosition.frame = handle!.frame
				makeSliderGrabbable()
			}
		}
	}
}
