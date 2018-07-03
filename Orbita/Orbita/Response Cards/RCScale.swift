//
//  RCBodyScale.swift
//  Orbita
//
//  Created by Jake Casino on 4/6/18.
//

import UIKit

class RCScale: UIViewController, RCResponseCardDataSource {
	var HEADER_TITLE: String?
	var HEADER_ACTION: RCAction?
	var FOOTER_ACTION: RCAction?
	
	var type: ScaleTypes?
	
	var handle = UIView(frame: CGRect.zero)
	var HANDLE_GRABBER = UIView(frame: CGRect.zero)
	
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
		HEADER_TITLE = title
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
		HEADER_TITLE = nil
		HEADER_ACTION = nil
		FOOTER_ACTION = nil
		type = nil
		SliderValue = nil
		SliderEndValues = nil
		
		range.removeAll()
		stops.removeAll()
		bufferZones.removeAll()
		ticks.removeAll()
	}
	
	override func didMove(toParentViewController parent: UIViewController?) {
		if let superview = view.superview {
			view.setFrame(equalTo: superview.bounds)
		}
		
		handle.resizeTo(width: 8, height: view.frame.height - (ALT_spacing(.small) * 2))
		handle.move(x: origins.center, y: origins.middle)
		handle.visualSetup(backgroundColor: UIColor.orbitaBlue, cornerRadius: roundedCorners(size: handle.frame.width), masksToBounds: true, alpha: nil)
		view.addSubview(handle)
		
		HANDLE_GRABBER.setFrame(equalTo: handle)
		makeSliderGrabbable()
		HANDLE_GRABBER.visualSetup(backgroundColor: UIColor.clear, cornerRadius: nil, masksToBounds: nil, alpha: nil)
		HANDLE_GRABBER.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(sliderWasDragged(gesture:))))
		HANDLE_GRABBER.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sliderWasTapped(gesture:))))
		view.addSubview(HANDLE_GRABBER)
		
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
				stops.append(view.frame.width - margin - handle.frame.width)
				bufferZones.append(bufferZones[0] + (bufferWidth * CGFloat(index - 1)))
			} else {
				let width: CGFloat
				switch type! {
				case .continuous:
					width = 2
				case .discrete:
					width = handle.frame.width
				}
				stops.append(margin + (bufferWidth * CGFloat(index - 1)) - (width / 2))
				bufferZones.append(bufferZones[0] + (bufferWidth * CGFloat(index - 1)))
			}
		}
		
		
		range = []
		
		for (index, stop) in stops.enumerated() {
			let tick = UIView(frame: CGRect.zero)
			tick.frame.size = CGSize(width: 2, height: 12)
			tick.frame.origin = CGPoint(x: stop + (handle.frame.width / 2) - (tick.frame.width / 2), y: ((view.frame.height - tick.frame.height) / 2))
			tick.visualSetup(backgroundColor: UIColor.whiteD, cornerRadius: roundedCorners(size: tick.frame.width), masksToBounds: nil, alpha: nil)
			ticks.append(tick)
			view.insertSubview(ticks[index], belowSubview: handle)
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
		HANDLE_GRABBER.setFrame(equalTo: handle)
		HANDLE_GRABBER.resizeTo(width: 44, height: nil)
		HANDLE_GRABBER.move(x: HANDLE_GRABBER.frame.origin.x - (HANDLE_GRABBER.frame.width / 2), y: nil)
	}
	
	func moveSlider(to index: Int) {
		handle.move(x: stops[index], y: nil)
		if let sliderValue = SliderValue {
			if (index == 0 || index == range.count - 1 ) {
				sliderValue.alpha = 0
			} else {
				sliderValue.text = (range[index] as! Int).description
				sliderValue.alpha = 1
				sliderValue.sizeToFit()
				sliderValue.move(x: handle.frame.origin.x, y: nil)
			}
		}
	}
	
	@objc func leftValueSelected(sender: UIButton) {
		moveSlider(to: 0)
		makeSliderGrabbable()
		HEADER_ACTION!.isEnabled = true
	}
	@objc func rightValueSelected(sender: UIButton) {
		moveSlider(to: stops.count - 1)
		makeSliderGrabbable()
		HEADER_ACTION!.isEnabled = true
	}
	
	@objc func sliderWasTapped(gesture: UITapGestureRecognizer) {
		if gesture.state == .ended {
			HEADER_ACTION!.isEnabled = true
		}
	}
	
	@objc func sliderWasDragged(gesture: UIPanGestureRecognizer) {
		if gesture.state == .began  {
			HANDLE_GRABBER.setFrame(equalTo: handle)
		}
		if gesture.state == .changed {
			let translation = gesture.translation(in: self.view)
			let newPosition = gesture.view!.frame.origin.x + translation.x
			let margin: CGFloat = 16
			if newPosition >= margin { // Leftmost stop
				if newPosition <= view.frame.width - margin - handle.frame.width { // Rightmost stop
					HANDLE_GRABBER.move(x: newPosition, y: nil)
					switch type! {
					case .continuous:
						handle.setFrame(equalTo: HANDLE_GRABBER)
						handle.backgroundColor = UIColor.clear
						var tickPlus1 = 0
						for (index, tick) in ticks.enumerated() {
							let handlePosition = handle.frame.origin.x + (handle.frame.width / 2)
							if handlePosition > (tick.frame.origin.x) {
								tickPlus1 = index
								break
							}
						}
						for tick in ticks {
							tick.backgroundColor = UIColor(named: "Light Grey")
							if tick.frame.size.width > 2 {
								tick.frame.origin = CGPoint(x: tick.frame.origin.x + 3, y: tick.frame.origin.y)
							}
							tick.frame.size = CGSize(width: 2, height: 12)
							tick.frame.origin = CGPoint(x: tick.frame.origin.x, y: ((view.frame.height - tick.frame.height) / 2))
						}
						ticks[tickPlus1].frame.size = handle.frame.size
						ticks[tickPlus1].frame.origin = CGPoint(x: (ticks[tickPlus1].frame.origin.x - 3), y: ((view.frame.height - ticks[tickPlus1].frame.height) / 2))
						if ticks.indices.contains(tickPlus1 - 1) {
							ticks[tickPlus1 - 1].backgroundColor = UIColor.red
						}
						if ticks.indices.contains(tickPlus1 + 1) {
							ticks[tickPlus1 + 1].backgroundColor = UIColor.red
						}
						
						break
					case .discrete:
						for (index, bufferZone) in bufferZones.enumerated() {
							if HANDLE_GRABBER.frame.origin.x < bufferZone {
								moveSlider(to: index)
							}
						}
					}
					gesture.setTranslation(CGPoint.zero, in: self.view)
				}
			}
		}
		if gesture.state == .ended {
			HEADER_ACTION!.isEnabled = true
			HANDLE_GRABBER.setFrame(equalTo: handle)
			makeSliderGrabbable()
		}
	}
}
