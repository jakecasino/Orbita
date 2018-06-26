//
//  Demo.swift
//  Orbita
//
//  Created by Jake Casino on 4/27/18.
//

import Foundation

class Demo {
	func ChatExample1() -> [RCChatBubble] {
		var content = [RCChatBubble]()
		content.append(RCChatBubble(sender: "ChatBot", type: RCChatBubbleTypes.incomingText, content: "Hello Rachel!"))
		content.append(RCChatBubble(sender: "ChatBot", type: RCChatBubbleTypes.incomingText, content: "I'm your Orbita Assistant"))
		content.append(RCChatBubble(sender: "ChatBot", type: RCChatBubbleTypes.incomingText, content: "Tap below to see some of the things I can do for you"))
		content.append(RCChatBubble(sender: "ChatBot", type: RCChatBubbleTypes.outgoingText, content: "thanks"))
		content.append(RCChatBubble(sender: "ChatBot", type: RCChatBubbleTypes.outgoingText, content: "Can you help me schedule an appointment with my doctor?"))
		content.append(RCChatBubble(sender: "ChatBot", type: RCChatBubbleTypes.incomingText, content: "Sure!"))
		
		return content
	}
}
