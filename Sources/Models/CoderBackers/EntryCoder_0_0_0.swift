//
//  EntryCoder_0_0_0.swift
//  
//
//  Created by Michael Arrington on 8/30/20.
//

import Foundation


struct EntryCoder_0_0_0: EntryCoderBacker {
	let rowDelimiter: Data = "🚷".data(using: .utf8)!
	let columnDelimiter: Character = "❗️"
	let emptyStringReplacement: String = "🔱"
	
	func encode(_ entry: Entry) -> Data {
		let parts: [String] = [
			entry.id.map { String($0) } ?? "",
			String(entry.date.timeIntervalSinceReferenceDate),
			String(entry.severity.rawValue),
			entry.message,
			entry.category,
			entry.directory,
			entry.file,
			entry.function,
			String(entry.line),
			String(entry.threadID),
			entry.frameworkID ?? "",
			entry.userID?.uuidString ?? "",
			(entry.deviceID?.uuidString ?? ""),
		]
		let text = parts
			// add the delimiter in front of every line
			// so we have separators between multiple batches, as we as between
			// MetaData and Entries
			.map { String(columnDelimiter) + toCSV($0) }
			.joined()
		
		guard let data = text.data(using: .utf8) else {
			preconditionFailure("failed to encode text")
		}
		
		return data
	}
	
	
	func decode(from text: String) -> Entry {
		
		let splits = text
			.split(separator: columnDelimiter)
			.map { fromCSV(String($0)) }
		
		guard let severity = Severity(rawValue: UInt8(splits[2])!) else {
			preconditionFailure()
		}
		guard let dateTime = TimeInterval(splits[1]) else {
			preconditionFailure()
		}
		guard let line = UInt32(splits[8]) else {
			preconditionFailure()
		}
		guard let threadID = Int(splits[9]) else {
			preconditionFailure()
		}
		
		let frameworkID = splits[10]
		
		return Entry(id: UInt64(splits[0]),
					 date: Date(timeIntervalSinceReferenceDate: dateTime),
					 severity: severity,
					 message: splits[3],
					 category: splits[4],
					 directory: splits[5],
					 file: splits[6],
					 function: splits[7],
					 line: line,
					 threadID: threadID,
					 frameworkID: !frameworkID.isEmpty ? frameworkID : nil,
					 userID: UUID(uuidString: String(splits[11])),
					 deviceID: UUID(uuidString: String(splits[12])))
	}
	
	
	@inlinable
	func toCSV(_ s: String) -> String {
		if s.isEmpty {
			return emptyStringReplacement
		}
		return s
	}
	
	@inlinable
	func fromCSV(_ s: String) -> String {
		if s == emptyStringReplacement {
			return ""
		}
		return s
	}
}
