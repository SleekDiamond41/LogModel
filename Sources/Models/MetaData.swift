//
//  MetaData.swift
//  
//
//  Created by Michael Arrington on 8/27/20.
//

import Foundation


public struct MetaData: Codable, Equatable {
	typealias Version = (UInt8, UInt8, UInt8)
	
	let version: Version
	
	public init(_ major: UInt8, _ minor: UInt8, _ patch: UInt8) {
		self.version = (major, minor, patch)
	}
}

// MARK: - Equatable Conformance
extension MetaData {
	
	public static func ==(left: MetaData, right: MetaData) -> Bool {
		return left.version == right.version
	}
}

// MARK: - Codable Conformance
extension MetaData {
	
	public enum DecodingError: Error {
		case invalidFormat(String)
		case typeConversion(String, index: Int)
	}
	
	public enum CodingKeys: String, CodingKey {
		case version
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		let s = try container.decode(String.self, forKey: .version)
		let splits = s.split(separator: ".")
		
		guard splits.count == 3 else {
			throw DecodingError.invalidFormat(s)
		}
		
		var nums = [UInt8]()
		
		for (offset, split) in splits.enumerated() {
			guard let num = UInt8(split) else {
				throw DecodingError.typeConversion(s, index: offset)
			}
			nums.append(num)
		}
		
		assert(nums.count == 3, "how did we start with 3 elements and end with not 3 elements without failing?")
		
		self.version = (nums[0], nums[1], nums[2])
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode("\(version.0).\(version.1).\(version.2)", forKey: .version)
	}
}
