//
//  Demo.swift
//  Orbita
//
//  Created by Jake Casino on 4/27/18.
//

import Foundation

class Demo {
	func messages() -> [Message] {
		var messages = [Message]()
		messages.append(Message(sender: "ChatBot", message: "Hello"))
		
		return messages
	}
}
