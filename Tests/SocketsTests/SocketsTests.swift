//
//  SocketsTests.swift
//  
//
//  Created by Michael Arrington on 8/28/20.
//

import XCTest
import Models
@testable import Sockets


class SocketsTests: XCTestCase {
	var socket: Socket!
	
	override func setUp() {
		super.setUp()
		
		let url = URL(string: "ws://192.168.0.75:34232")!
		socket = Socket(url: url)
	}
	
	override func tearDown() {
		socket = nil
		
		super.tearDown()
	}
	
	func testSendingSomethingSimple() {
		socket.sendSimple("Hello, World")
		
		let e = XCTestExpectation()
		
		Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
			self.socket.sendSimple("This is the second message, should work pretty good")
			e.fulfill()
		}
		
		wait(for: [e], timeout: 6)
	}
}
