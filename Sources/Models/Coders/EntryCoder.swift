//
//  EntryCoder.swift
//  
//
//  Created by Michael Arrington on 8/28/20.
//

import Foundation


protocol EntryCoderBacker {
	var rowDelimiter: Data { get }
	var rowDelimiterCharacter: Character { get }
	
	func encode(_ entry: Entry) -> Data
	func decode(from text: String) -> Entry
}


public class EntryCoder {
	
	public typealias Version = (UInt8, UInt8, UInt8)
	
	let backer: EntryCoderBacker
	
	public convenience init(version: Version) {
		
		self.init(EntryCoder_0_0_0())
	}
	
	init(_ backer: EntryCoderBacker) {
		self.backer = backer
	}
	
	public func encode(_ meta: MetaData) -> Data {
		return "m:".data(using: .utf8)! + Data([meta.version.0, meta.version.1, meta.version.2])
	}
	
	public func encode(_ meta: MetaData, entries: [Entry]) -> Data {
		return encode(meta) + encode(entries)
	}
	
	public func encode(_ entries: [Entry]) -> Data {
		// these two guards are a slight performance optimization
		guard !entries.isEmpty else {
			return Data()
		}
		guard entries.count > 1 else {
			return backer.encode(entries[0])
		}
		
		let group = DispatchGroup()
		
		let workQueue = DispatchQueue.global(qos: .userInteractive)
		let updateQueue = DispatchQueue(label: "com.duct-ape-productions.Models.Encode", qos: .userInteractive)
		
		var data = Data()
		
		for i in entries.indices {
			group.enter()
			
			workQueue.async {
				entries[i].id = UInt64(i)
				let d = self.backer.encode(entries[i])
				
				updateQueue.async {
					data += self.backer.rowDelimiter + "e:".data(using: .utf8)! + d
					group.leave()
				}
			}
		}
		group.wait()
		
		return data
	}
	
	public func decode(from data: Data) -> (MetaData?, [Entry]) {
		return decode(from: String(data: data, encoding: .utf8)!)
	}
	
	public func decode(from string: String) -> (MetaData?, [Entry]) {
		return decode(from: string
						.split(separator: backer.rowDelimiterCharacter)
						.map { String($0) })
	}
	
	public func decode(from s: String) -> MetaData {
		let nums = s
			.split(separator: ".")
			.map { UInt8($0)! }
		
		return MetaData(nums[0], nums[1], nums[2])
	}
	
	public func decode(from s: String) -> Entry {
		return backer.decode(from: s)
	}
	
	func decodeValue(from s: String) -> Value {
		
		guard let indicator = s.first else {
			preconditionFailure()
		}
		
		let range = s.range(of: ":")!
		let text = String(s[range.upperBound...])
		
		switch indicator {
		case "e":
			return .entry(decode(from: text))
		case "m":
			return .meta(decode(from: text))
		default:
			preconditionFailure("unknown prefix")
		}
	}
	
	public func decode(from splits: [String]) -> (MetaData?, [Entry]) {
		// these two guards are a slight performance optimization
		var meta: MetaData?
		var results = [Entry]()
		
		guard !splits.isEmpty else {
			return (nil, [])
		}
		guard splits.count > 1 else {
			let value = decodeValue(from: splits[0])
			
			switch value {
			case .meta(let meta):
				return (meta, [])
			case .entry(let entry):
				return (nil, [entry])
			}
		}
		
		let group = DispatchGroup()
		
		let workQueue = DispatchQueue.global(qos: .userInteractive)
		let updateQueue = DispatchQueue(label: "com.duct-ape-productions.Models.Decode", qos: .userInteractive, target: workQueue)
		
		results.reserveCapacity(splits.count)
		
		group.enter()
		
		workQueue.async {
			
			// get the MetaData if it's there
			let value = self.decodeValue(from: splits[0])
			
			switch value {
			case .meta(let m):
				updateQueue.async {
					meta = m
				}
			case .entry(let entry):
				entry.id = UInt64(0)
				
				updateQueue.async {
					results.append(entry)
					group.leave()
				}
			}
		}
		
		for i in 1..<splits.count {
			group.enter()
			
			workQueue.async {
				let s = splits[i]
				let index = s.index(s.startIndex, offsetBy: 2)
				let entry: Entry = self.decode(from: String(s[index...]))
				entry.id = UInt64(i)
				
				updateQueue.async {
					results.append(entry)
					group.leave()
				}
			}
		}
		group.wait()
		
		let compact = results.compactMap { $0 }
		
		assert(compact.count == splits.count)
		
		return (meta, compact)
	}
	
	enum Value {
		case meta(MetaData)
		case entry(Entry)
	}
}
