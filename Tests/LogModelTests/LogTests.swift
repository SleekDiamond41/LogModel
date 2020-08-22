//
//  LogTests.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

import XCTest
import Files
@testable import LogModel

import os

@available(OSX 11.0, *)
class LogTests: XCTestCase {
	
	var log: Log!
	
	let bundleID = "com.duct-ape-productions.LogModel"
	lazy var dir = Directory.appSupport
		.Testing
		.Logs
		.appending(bundleID.replacingOccurrences(of: ".", with: "__"))
		.appending("LogModelTests")
	
	override func setUp() {
		print(dir.url.path)
		
		log = Log(bundleID: bundleID,
				  userID: nil,
				  deviceID: nil,
				  dir: dir.url)
	}
	
	override func tearDown() {
		log = nil
		
		dir.delete()
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
		
		var count = 1
		let log = Logger(subsystem: "com.the-duct-ape.Logs", category: "testing-\(count)")
		
		self.measure {
//			let file = self.dir.appending("testTime_savingToFile").file("\(count)", .txt)
			
			for i in 1...1000 {
//				let entry = Entry(id: nil,	// id will be set by the LocalStorage
//								  date: Date(),
//								  severity: .verbose,
//								  message: "Here is message number \(i)",
//								  directory: "LogModelTests",
//								  file: "LogTests.swift",
//								  function: #function,
//								  line: #line,
//								  customData: nil,
//								  bundleID: "com.the-duct-ape.LogModel.LogModelTests",
//								  userID: nil,
//								  deviceID: nil)
				
				log.warning("Here is message number \(i)")
//				do {
//					try file.append(toCSV(entry).data(using: .utf8)!)
//				} catch {
//					XCTFail(String(describing: error))
//				}
			}
			
			count += 1
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
