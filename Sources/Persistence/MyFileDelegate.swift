//
//  MyFileDelegate.swift
//  
//
//  Created by Michael Arrington on 8/22/20.
//

import Foundation
import Models


@available(OSX 10.12, iOS 10.0, *)
public final class MyFileDelegate: FileDelegate {
	
	public typealias Limit = UInt16
	
	/// This delegate prefers to keep the number of lines per file below a certain threshold,
	/// but may write more lines to a single file if sent in a single `write(_:)` call.
	let preferredMaxLinesPerFile: Limit
	
	private let meta = MetaData(0, 0, 0)
	private let logger = DebugReporter(category: "Persistence")
	
	private var filenameProvider: FilenameProviding
	private var currentLineCount: Limit = 0
	
	public init(filename: FilenameProviding, preferredLinesPerFile: Limit = 10_000) {
		self.filenameProvider = filename
		self.preferredMaxLinesPerFile = preferredLinesPerFile
	}
	
	private func metaData() -> Data {
		let encoder = JSONEncoder()
		
		do {
			return try encoder.encode(meta)
		} catch {
			logger.log("failed to encode MetaData '%s' to JSON with message '%s'", String(describing: meta), error.localizedDescription)
			
			preconditionFailure()
		}
	}
}

// MARK: - FileDelegate Conformance
@available(OSX 10.12, iOS 10.0, *)
extension MyFileDelegate {
	
	public func write(_ entries: [Entry]) {
		let count = Limit(entries.count)
		
		if (count + currentLineCount) > preferredMaxLinesPerFile {
			// we would be over the limit, move on to a new file
			filenameProvider.advance()
			currentLineCount = 0
		}
		
		let url = filenameProvider.currentFile()
		
		do {
			let coder = EntryCoder(version: (0, 0, 0))
			var data = coder.encode(entries)
			
			if currentLineCount == 0 {
				// TODO: also write some meta-data,
				// i.e. date, version number
				// maybe bundle name, userID, and deviceID at the
				// top of each line and skip writing them on each line
				data = metaData() + data
				try data.write(to: url)
			} else {
				
				let handle = try FileHandle(forUpdating: url)
				handle.seekToEndOfFile()
				handle.write(data)
				handle.closeFile()
			}
			
			currentLineCount += count
			
		} catch {
			logger.log("failed to save %d entries to file at '%s' with message '%s'", entries.count, url.absoluteString, error.localizedDescription)
		}
	}
}
