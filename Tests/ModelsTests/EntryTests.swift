//
//  EntryTests.swift
//  
//
//  Created by Michael Arrington on 8/27/20.
//

import XCTest
@testable import Models

class EntryTests: XCTestCase {
	
	let coder = EntryCoder_0_0_0()
	
	let person = "Bob"
	
	let entries = (1...1_000)
		.map {
			Entry(id: $0,
				  date: Date(),
				  severity: .info,
				  message: "Hello, 'Bob', \($0)",
				  category: "Testing",
				  directory: "LogModelTests",
				  file: "EntryTests",
				  function: "myFunction()",
				  line: #line,
				  threadID: 23849,
				  appID: "com.duct-ape-productions.app-name",
				  frameworkID: nil,
				  userID: UUID(),
				  deviceID: nil)
		}
	
	
	func testCSV() {
		let entry = entries[0]
		let csv = coder.encode(entry)
		
		let result = coder.decode(from: String(data: csv, encoding: .utf8)!)
		
		XCTAssertEqual(result.id, entry.id)
		XCTAssertLessThan(abs(result.date.distance(to: entry.date)), 0.00001)
		XCTAssertEqual(result.severity, entry.severity)
		XCTAssertEqual(result.message, entry.message)
		XCTAssertEqual(result.category, entry.category)
		XCTAssertEqual(result.directory, entry.directory)
		XCTAssertEqual(result.file, entry.file)
		XCTAssertEqual(result.function, entry.function)
		XCTAssertEqual(result.line, entry.line)
		XCTAssertEqual(result.threadID, entry.threadID)
		XCTAssertEqual(result.appID, entry.appID)
		XCTAssertEqual(result.frameworkID, entry.frameworkID)
		XCTAssertEqual(result.userID, entry.userID)
		XCTAssertEqual(result.deviceID, entry.deviceID)
	}
	
	
	func testEncode() {
		let listCoder = EntryCoder(coder)
		var results = Data()
		
		self.measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
			results = listCoder.encode(entries)
		}
		
		print(results.count)
	}
	
	func testDecode() {
		let listCoder = EntryCoder(coder)
		let data = entries
			.map { coder.encode($0) }
			.map { String(data: $0, encoding: .utf8)! }
		
		
		var results = [Entry]()
		
		self.measure(metrics: [XCTClockMetric(), XCTMemoryMetric()]) {
			results = listCoder.decode(from: data)
		}
		
		print(results.count)
	}
}