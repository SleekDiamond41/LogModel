//
//  EntryCoder.swift
//  
//
//  Created by Michael Arrington on 8/28/20.
//

import Foundation


public class EntryCoder {
	
	public typealias Version = (UInt8, UInt8, UInt8)
	
	let version: Version
	
	public init(version: Version) {
		self.version = version
	}
	
	
	func encode(_ entry: Entry) -> Data {
		let text = [
			"\(entry.id ?? 0)",
			"\(entry.date.timeIntervalSinceReferenceDate)",
			"\(entry.severity.rawValue)",
			entry.message,
			entry.category,
			entry.directory,
			entry.file,
			entry.function,
			"\(entry.line)",
			"\(entry.threadID)",
			entry.bundleID,
			(entry.userID?.uuidString ?? ""),
			(entry.deviceID?.uuidString ?? ""),
		]
		.map { $0.isEmpty ? " " : $0 }
		.joined(separator: "\(columnDelimiter)")
		
		guard let data = text.data(using: .utf8) else {
			preconditionFailure("failed to encode text")
		}
		
		return data
	}
	
	
	public func encode(_ entries: [Entry]) -> Data {
		// these two guards are a slight performance optimization
		guard !entries.isEmpty else {
			return Data()
		}
		guard entries.count > 1 else {
			return encode(entries[0])
		}
		
		let group = DispatchGroup()
		
		let workQueue = DispatchQueue.global(qos: .userInteractive)
		let updateQueue = DispatchQueue(label: "com.duct-ape-productions.Models.Encode", qos: .userInteractive)
		
		guard let separator = String(rowDelimiter).data(using: .utf8) else {
			preconditionFailure("we darn well better be able to encode a simple character")
		}
		
		var data = Data()
		
		for i in entries.indices {
			group.enter()
			
			workQueue.async {
				entries[i].id = UInt64(i)
				let d = self.encode(entries[i])
				
				updateQueue.async {
					data += separator + d
					group.leave()
				}
			}
		}
		group.wait()
		
		return data
	}
	
	func decodeOne(from text: String) -> Entry {
		
		let splits = text.split(separator: columnDelimiter)
		
		guard let severity = Severity(rawValue: UInt8(splits[2])!) else {
			preconditionFailure()
		}
		
		return Entry(id: UInt64(splits[0]),
					 date: Date(timeIntervalSinceReferenceDate: TimeInterval(splits[1])!),
					 severity: severity,
					 message: String(splits[3]),
					 category: String(splits[4]),
					 directory: String(splits[5]),
					 file: String(splits[6]),
					 function: String(splits[7]),
					 line: UInt32(splits[8])!,
					 threadID: Int(splits[9])!,
					 bundleID: String(splits[10]),
					 userID: UUID(uuidString: String(splits[11])),
					 deviceID: UUID(uuidString: String(splits[12])))
	}
	
	public func decode(from splits: [String]) -> [Entry] {
		// these two guards are a slight performance optimization
		guard !splits.isEmpty else {
			return []
		}
		guard splits.count > 1 else {
			return [decodeOne(from: splits[0])]
		}
		
		let group = DispatchGroup()
		
		let workQueue = DispatchQueue.global(qos: .userInteractive)
		let updateQueue = DispatchQueue(label: "com.duct-ape-productions.Models.Decode", qos: .userInteractive, target: workQueue)
		
		var results = [Entry?](repeating: nil, count: splits.count)
		
		for i in splits.indices {
			group.enter()
			
			workQueue.async {
				let entry = self.decodeOne(from: splits[i])
				
				updateQueue.async {
					results[i] = entry
					group.leave()
				}
			}
		}
		group.wait()
		
		let compact = results.compactMap { $0 }
		
		assert(compact.count == splits.count)
		
		return compact
	}
}

let rowDelimiter: Character = "🚷"
let columnDelimiter: Character = "❗️"
