//
//  MyFileDelegate.swift
//  
//
//  Created by Michael Arrington on 8/22/20.
//

import OSLog

@available(OSX 10.12, iOS 10.0, *)
final class MyFileDelegate: FileDelegate {
	
	typealias Limit = UInt16
	typealias Version = (UInt8, UInt8, UInt8)
	
	/// This delegate prefers to keep the number of lines per file below a certain threshold,
	/// but may write more lines to a single file if sent in a single `write(_:)` call.
	let preferredMaxLinesPerFile: Limit = 10_000
	
	private let meta = MetaData()
	private let logger = OSLog(subsystem: "com.duct-ape-productions.LogModel", category: "WritingData")
	
	private var currentLineCount: Limit = 0
	
	private let filenameProvider: FilenameProviding
	
	
	init(filename: FilenameProviding) {
		self.filenameProvider = filename
	}
	
	private struct MetaData: Encodable {
		let version: Version = (0, 0, 0)
		
		func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			
			try container.encode("\(version.0),\(version.1),\(version.2)", forKey: .version)
		}
		
		enum CodingKeys: String, CodingKey {
			case version
		}
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
	
	func write(_ entries: [Entry]) {
		let count = Limit(entries.count)
		
		if (count + currentLineCount) > preferredMaxLinesPerFile {
			// we would be over the limit, move on to a new file
			filenameProvider.advance()
			currentLineCount = 0
		}
		
		let encoder = JSONEncoder()
		let url = filenameProvider.currentFile()
		
		do {
			guard let newLineData = "\n".data(using: .utf8) else {
				os_log("failed to encode newline character ('\\n') to utf8 encoding. This shouldn't be possible.", log: logger, type: .fault)
				return
			}
			
			var data = Data(try entries
								.map { try encoder.encode($0) }
								.joined(separator: newLineData))
			
			if currentLineCount == 0 {
				// TODO: also write some meta-data,
				// i.e. date, version number
				// maybe bundle name, userID, and deviceID at the
				// top of each line and skip writing them on each line
				data = metaData() + newLineData + data
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
