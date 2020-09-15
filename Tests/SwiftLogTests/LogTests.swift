//
//  LogTests.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

import XCTest
import Backers
@testable import SwiftLog

import os

@available(OSX 10.15, iOS 13, *)
class LogTests: XCTestCase {
	
	var log: Log!
	
	let bundleID = "com.duct-ape-productions.SwiftLog"
	lazy var dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
		.first!
		.appendingPathComponent("Testing")
		.appendingPathComponent("Logs")
		.appendingPathComponent(bundleID)
		.appendingPathComponent("LogTests")
	
	
	override func setUp() {
		print(dir.path)
		
		log = Log(bundleID: "testing", category: "LogTests", backer: Console())

//		log = Log(
//			bundleID: bundleID,
//			category: .SwiftLogTests,
//			backer: backer)
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
	
	
	@available(OSX 11.0, iOS 14.0, *)
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
			
			for i in 1...999 {
				let threadName = Thread.current.hash
				self.log.verbose("Here is message number \(i) on thread '\(threadName)'")
			}
			log.error("something real bad happened, gotta record immediately")
		}
	}
	
	func testTime_savingToDatabase() {
		self.measure {
			for i in 1...1000 {
				let threadName = Thread.current.hash
				self.log.verbose("Here is message number \(i) on thread '\(threadName)'")
			}
		}
	}
}
