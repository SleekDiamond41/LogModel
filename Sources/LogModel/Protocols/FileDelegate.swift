//
//  FileDelegate.swift
//  
//
//  Created by Michael Arrington on 8/21/20.
//

import OSLog

protocol FileDelegate {
	func write(_ entries: [Entry])
}


@available(OSX 10.12, iOS 10.0, *)
final class MyFileDelegate: FileDelegate {
	
	let maxWritesPerFile = 10
	
	private var writeCount = 0
	
	private let filenameProvider: FilenameProviding
	
	
	init(filename: FilenameProviding) {
		self.filenameProvider = filename
	}
}

// MARK: - FileDelegate Conformance
@available(OSX 10.12, iOS 10.0, *)
extension MyFileDelegate {
	
	func write(_ entries: [Entry]) {
		let encoder = JSONEncoder()
		let url = filenameProvider.currentFile()
		
		do {
			let data = Data(try entries
								.map { try encoder.encode($0) }
								.joined(separator: "\n".data(using: .utf8)!))
			
			if writeCount == 0 {
				// TODO: also write some meta-data,
				// i.e. date, version number
				// maybe bundle name, userID, and deviceID at the top of each line and skip writing them on each line
			}
			
			try data.write(to: url)
			writeCount += 1
			
			if writeCount > maxWritesPerFile {
				filenameProvider.advance()
				writeCount = 0
			}
			
		} catch {
			let logger = OSLog(subsystem: "com.duct-ape-productions.LogModel", category: "WritingData")
			os_log("failed to save %d entries to file at '%s' with message '%s'", log: logger, type: .fault, entries.count, url.absoluteString, error.localizedDescription)
		}
	}
}
