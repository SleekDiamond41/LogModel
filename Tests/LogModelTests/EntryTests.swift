//
//  EntryTests.swift
//  
//
//  Created by Michael Arrington on 8/27/20.
//

import XCTest
@testable import LogModel

class EntryTests: XCTestCase {
	
	let person = "Bob"
	
	lazy var entry = Entry(id: 15,
						   date: Date(),
						   severity: .info,
						   message: "",
						   category: "Testing",
						   directory: "LogModelTests",
						   file: "EntryTests",
						   function: "myFunction()",
						   line: #line,
						   customData: "",
						   bundleID: "com.duct-ape-productions.app-name",
						   userID: UUID(),
						   deviceID: nil)
	
	func testCSV() {
		// we're testing encoding and decoding,
		// not the Message type
		entry.message = "Hello, 'Bob'"
		let csv = entry.toCSV()
		
		let result = Entry(from: csv)
		
		XCTAssertEqual(result.id, entry.id)
		XCTAssertLessThan(abs(result.date.distance(to: entry.date)), 0.0001)
		XCTAssertEqual(result.severity, entry.severity)
		XCTAssertEqual(result.message, entry.message)
		XCTAssertEqual(result.category, entry.category)
		XCTAssertEqual(result.file, entry.file)
		XCTAssertEqual(result.function, entry.function)
		XCTAssertEqual(result.line, entry.line)
		XCTAssertEqual(result.customData, entry.customData)
		XCTAssertEqual(result.bundleID, entry.bundleID)
		XCTAssertEqual(result.userID, entry.userID)
		XCTAssertEqual(result.deviceID, entry.deviceID)
	}
}
