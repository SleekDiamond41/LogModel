//
//  MyFileDelegate.swift
//  
//
//  Created by Michael Arrington on 8/22/20.
//

import OSLog
import Models


@available(OSX 10.12, iOS 10.0, *)
public final class MyFileDelegate: FileDelegate {
	
	public typealias Limit = UInt16
	
	/// This delegate prefers to keep the number of lines per file below a certain threshold,
	/// but may write more lines to a single file if sent in a single `write(_:)` call.
	let preferredMaxLinesPerFile: Limit
	
	private let meta = MetaData(0, 0, 0)
	private let logger = OSLog(subsystem: "com.duct-ape-productions.LogModel", category: "Persistence")
	
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
			os_log("failed to encode MetaData '%s' to JSON with message '%s'",
				   log: logger,
				   type: .fault,
				   String(describing: meta), error.localizedDescription)
			
			preconditionFailure()
		}
	}
}

// MARK: - FileDelegate Conformance
@available(OSX 10.12, iOS 10.0, *)
extension MyFileDelegate {
	
	public func encode(_ entries: [Entry]) -> [Data?] {
		let group = DispatchGroup()
		var results = [Data?](repeating: nil, count: entries.count)
		
		let queue = DispatchQueue(label: "com.stuff.mystuff.temp-my-example", qos: .userInitiated)
		
		for i in entries.indices {
			group.enter()
			
			DispatchQueue.global(qos: .userInitiated).async {
				
				// encode each entry concurrently
				guard let result = entries[i].toCSV().data(using: .utf8) else {
					preconditionFailure("failed to encode entry at index '\(i)': \(entries[i])")
				}
				
				queue.async {
					
					// accessing the array concurrently has been causing
					// some issues, so we move that interaction onto a
					// serial queue
					results[i] = result
					group.leave()
				}
			}
		}
		
		group.wait()
		
		return results
	}
	
	public func write(_ entries: [Entry]) {
		let count = Limit(entries.count)
		
		if (count + currentLineCount) > preferredMaxLinesPerFile {
			// we would be over the limit, move on to a new file
			filenameProvider.advance()
			currentLineCount = 0
		}
		
		let url = filenameProvider.currentFile()
		let results = encode(entries)
		
		do {
			guard let delimiter = "\n".data(using: .utf8) else {
				os_log("failed to encode newline character ('\\n') to utf8 encoding. This shouldn't be possible.", log: logger, type: .fault)
				return
			}
			
			
			let compact = results.compactMap { $0 }
			assert(compact.count == results.count, "we must have failed to encode one of the Entries")
			
			var data = Data(compact.joined(separator: delimiter))
			
			
			if currentLineCount == 0 {
				// TODO: also write some meta-data,
				// i.e. date, version number
				// maybe bundle name, userID, and deviceID at the
				// top of each line and skip writing them on each line
				data = metaData() + delimiter + data
				try data.write(to: url)
			} else {
				
				let handle = try FileHandle(forUpdating: url)
				handle.seekToEndOfFile()
				handle.write(data)
				handle.closeFile()
			}
			
			currentLineCount += count
			
		} catch {
			os_log("failed to save %d entries to file at '%s' with message '%s'", log: logger, type: .fault, entries.count, url.absoluteString, error.localizedDescription)
		}
	}
}
