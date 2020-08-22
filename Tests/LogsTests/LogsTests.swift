//
//  File.swift
//  
//
//  Created by Michael Arrington on 8/9/20.
//

import XCTest
@testable import Logs

@available(OSX 10.12, iOS 10, *)
class LogsTests: XCTestCase {
	
	let log = Log(subsystem: "com.duct-ape-productions.Logs", category: "tests")
	
	func testWriteLogs() {
		print(#dsohandle)
		log.info("this is my version")
	}
}
