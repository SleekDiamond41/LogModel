//
//  LogTests.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

import XCTest
import Files
@testable import LogModel

class LogTests: XCTestCase {
	
	var log: Log!
	let dir = Directory.appSupport.testing
	
	override func setUp() {
		print(dir.url.path)
		
		log = Log(bundleID: "com.the-duct-ape.LogModel.LogModelTests",
				  userID: nil,
				  deviceID: nil,
				  dir: dir.url,
				  name: "LogTests")
	}
	
	override func tearDown() {
		log = nil
		
		dir.file("LogTests", .sqlite).delete()
	}
	
	func testWriteVerbose() {
		log.verbose("this is my first ever message")
		
		let e = XCTestExpectation()

		// logging in a background thread causes serious issues
		// if we end execution on `main` too quickly
		Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
			e.fulfill()
		}

		wait(for: [e], timeout: 5)
	}
}
