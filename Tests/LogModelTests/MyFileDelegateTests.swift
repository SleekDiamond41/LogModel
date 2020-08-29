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
		return entry.toCSV()
			.data(using: .utf8)!
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
			.split(separator: "\n")
		
		assert(splits.count >= 2, "we should only encode things if we have one MetaData object and at least one Entry")
		
		do {
			guard let data = splits[0].data(using: .utf8) else {
				preconditionFailure("failed to turn data String back into data")
			}
			let decoder = JSONDecoder()
			let meta = try decoder.decode(MetaData.self, from: data)
			
			let queue = DispatchQueue(label: "com.duct-ape-productions.LogModel.SwiftLogDecoder")
			let group = DispatchGroup()
			
			var entries = [Entry?](repeating: nil, count: (splits.count - 1))
			
			for i in 1..<splits.count {
				group.enter()
				
				DispatchQueue.global(qos: .userInitiated).async {
					
					let entry = Entry(from: String(splits[i]))
					
					queue.async {
						// we started this loop with index 1, we have to subtract 1
						// when assigning Entries into the `entries` array
						entries[i - 1] = entry
						group.leave()
					}
				}
			}
			
			group.wait()
			
			let results = entries.compactMap { $0 }
			
			assert(results.count == entries.count, "we must have failed to decode some entries somewhere")
			
			return (meta, results)
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
		var entries = [Entry]()
		
		for i in 1...10 {
			entries.append(Entry(id: nil,
								 date: Date(),
								 severity: .info,
								 message: "entry number \(i)",
								 category: "MyFileDelegateTests",
								 directory: "LogModelTests",
								 file: "MyFileDelegateTests",
								 function: #function,
								 line: #line,
								 threadID: 290840,
								 bundleID: "com.duct-ape-productions.LogModelTests",
								 userID: nil,
								 deviceID: nil))
		}
		
		return entries
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
