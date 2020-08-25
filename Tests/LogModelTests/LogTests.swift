//
//  LogTests.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

import XCTest
@testable import LogModel

import os

@available(OSX 11, iOS 13, *)
class LogTests: XCTestCase {
	
	var log: Log!
	
	let bundleID = "com.duct-ape-productions.LogModel"
	lazy var dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
		.first!
		.appendingPathComponent("Testing")
		.appendingPathComponent("Logs")
		.appendingPathComponent(bundleID)
		.appendingPathComponent("LogTests")
	
	
	override func setUp() {
		print(dir.path)
		
		let backer = LogBacker(
			bundleID: bundleID,
			userID: nil,
			deviceID: nil,
			serverURL: nil)
		
		log = Log(
			bundleID: bundleID,
			category: .logModelTests,
			backer: backer)
	}
	
	override func tearDownWithError() throws {
		log = nil
		
		do {
			try FileManager.default.removeItem(at: dir)
		} catch let error as NSError {
			guard error.code == NSFileReadNoSuchFileError else {
				// no such file, nothing to see here
				return
			}
			throw error
		}
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
	
	
	func testTime_savingToFile_CSV() {
		
		let log = Logger(subsystem: "com.the-duct-ape.Logs.LogTests", category: #function)
		
		self.measure {
			
			for i in 1...1000 {
				log.warning("Here is message number \(i)")
			}
		}
	}
	
	func testTime_savingToFile_JSON() {
		self.measure {
			
		}
	}
	
	func testTime_savingToDatabase() {
		self.measure {
			for i in 1...1000 {
				log.verbose("Here is message number \(i)")
			}
//			log.log(.error, "something real bad happened, gotta record immediately")
		}
	}
}
