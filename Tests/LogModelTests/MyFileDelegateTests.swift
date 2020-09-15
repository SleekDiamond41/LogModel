//
//  MyFileDelegateTests.swift
//  
//
//  Created by Michael Arrington on 8/27/20.
//

import Foundation
import XCTest
import Persistence
import Models
@testable import LogModel

class CSVLogEncoder {
	
	func encode(_ entry: Entry) -> Data {
		let coder = EntryCoder(version: (0, 0, 0))
		return coder.encode([entry])
	}
}

class SwiftLogDecoder {
	
	enum DecodingError: Error {
		case unexpectedDataStringFormat
	}
	
	func decode(from data: Data) throws -> (MetaData, [Entry]) {
		guard let dataString = String(data: data, encoding: .utf8) else {
			throw DecodingError.unexpectedDataStringFormat
		}
		
		let splits = dataString
			.split(separator: "🚷")
		
		assert(splits.count >= 2, "we should only encode things if we have one MetaData object and at least one Entry")
		
		do {
			guard let data = splits[0].data(using: .utf8) else {
				preconditionFailure("failed to turn data String back into data")
			}
			let decoder = JSONDecoder()
			let meta = try decoder.decode(MetaData.self, from: data)
			
			let coder = EntryCoder(version: (0, 0, 0))
			let entries = coder.decode(from: Array(splits.map { String($0) }.dropFirst()))
			// drop first because the first one is metadata
			// FIXME: get rid of this weird assumption
			
			return (meta, entries)
		} catch {
			preconditionFailure(error.localizedDescription)
		}
	}
}

class MyFileDelegateTests: XCTestCase {
	
	let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
		.first!
		.appendingPathComponent("com.duct-ape-productions.LogModelTests")
		.appendingPathComponent("MyFileDelegateTests")
	
	let entries: [Entry] = {
		return (1...10).map { i in
			Entry(id: i,
				  date: Date(),
				  severity: .info,
				  message: "a fance entry with lots of meaningful data, this should be very helpful",
				  category: "MyFileDelegateTests",
				  directory: "LogModelTests",
				  file: "MyFileDelegateTests",
				  function: #function,
				  line: #line,
				  threadID: 290840,
				  frameworkID: nil,
				  userID: nil,
				  deviceID: nil)
		}
	}()
	
	override func setUp() {
		do {
			try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	
	override func tearDown() {
		do {
			try FileManager.default.removeItem(at: dir)
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
	
	class MockFilenameProvider: FilenameProviding {
		
		let dir: URL
		var fileID: Int
		
		init(dir: URL, fileID: Int) {
			self.dir = dir
			self.fileID = fileID
		}
		
		func currentFile() -> URL {
			return dir.appendingPathComponent("\(fileID)")
		}
		
		func advance() {
			fileID += 1
		}
	}
	
	func testingEncoding() {
		
		let filename = MockFilenameProvider(dir: dir, fileID: 0)
		let delegate = MyFileDelegate(filename: filename, preferredLinesPerFile: 10)
		
		delegate.write(entries)
		
		do {
			let data = try Data(contentsOf: filename.currentFile())
			let decoder = SwiftLogDecoder()
			
			let (resultMeta, resultEntries) = try decoder.decode(from: data)
			
			XCTAssertEqual(resultMeta, MetaData(0, 0, 0))
			
			guard resultEntries.count == entries.count else {
				XCTFail("there should have been '\(entries.count)' results but there were '\(resultEntries.count)' instead")
				return
			}
			
			for i in entries.indices {
				let a = resultEntries[i]
				let b = entries[i]
				
				XCTAssertEqual(a.message, b.message)
			}
			
			
		} catch {
			XCTFail(error.localizedDescription)
		}
	}
}
