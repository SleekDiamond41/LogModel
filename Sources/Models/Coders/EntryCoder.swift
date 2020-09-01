//
//  EntryCoder.swift
//  
//
//  Created by Michael Arrington on 8/28/20.
//

import Foundation


protocol EntryCoderBacker {
	var rowDelimiter: Data { get }
	
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
					data += self.backer.rowDelimiter + d
					group.leave()
				}
			}
		}
		group.wait()
		
		return data
	}
	
	public func decode(from splits: [String]) -> [Entry] {
		// these two guards are a slight performance optimization
		guard !splits.isEmpty else {
			return []
		}
		guard splits.count > 1 else {
			return [self.backer.decode(from: splits[0])]
		}
		
		let group = DispatchGroup()
		
		let workQueue = DispatchQueue.global(qos: .userInteractive)
		let updateQueue = DispatchQueue(label: "com.duct-ape-productions.Models.Decode", qos: .userInteractive, target: workQueue)
		
		var results = [Entry?](repeating: nil, count: splits.count)
		
		for i in splits.indices {
			group.enter()
			
			workQueue.async {
				let entry = self.backer.decode(from: splits[i])
				
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
