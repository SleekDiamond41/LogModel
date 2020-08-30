//
//  Entry.swift
//
//
//  Created by Michael Arrington on 8/28/20.
//

import Foundation

public struct EntryData {
	public let date: Date
	public let severity: Severity
	public let message: Message
	public let category: String
	public let appID: String
	public let threadID: Int
	public let filepath: String
	public let function: String
	public let line: UInt32
	public var frameworkID: String?
	
	public init(date: Date,
				severity: Severity,
				message: Message,
				category: String,
				appID: String,
				threadID: Int,
				filepath: String,
				function: String,
				line: UInt32,
				frameworkID: String?) {
		
		self.date = date
		self.severity = severity
		self.message = message
		self.category = category
		self.appID = appID
		self.threadID = threadID
		self.filepath = filepath
		self.function = function
		self.line = line
		self.frameworkID = frameworkID
	}
	
	public func makeEntry() -> Entry {
		preconditionFailure()
//		return Entry(id: nil,
//					 date: date,
//					 severity: severity,
//					 message: message.string(for: .low),
//					 category: category,
//					 directory: <#T##String#>,
//					 file: <#T##String#>,
//					 function: <#T##String#>,
//					 line: <#T##UInt32#>,
//					 threadID: <#T##Int#>,
//					 bundleID: <#T##String#>,
//					 userID: <#T##UUID?#>,
//					 deviceID: <#T##UUID?#>)
	}
}

/// An entry in the Log
public class Entry: Codable, CustomStringConvertible {
	public var id: UInt64?
	public let date: Date
	public let severity: Severity
	public let message: String
	public let category: String
	public let directory: String
	public let file: String
	public let function: String
	public let line: UInt32
	public let threadID: Int
	public let appID: String
	public let frameworkID: String?
	public let userID: UUID?
	public let deviceID: UUID?
	
	
	public var description: String {
		return message
	}
	
	
	public init(id: UInt64?,
		 date: Date,
		 severity: Severity,
		 message: String,
		 category: String,
		 directory: String,
		 file: String,
		 function: String,
		 line: UInt32,
		 threadID: Int,
		 appID: String,
		 frameworkID: String?,
		 userID: UUID?,
		 deviceID: UUID?
	) {
		
		self.id = id
		self.date = date
		self.severity = severity
		self.message = message
		self.category = category
		self.directory = directory
		self.file = file
		self.function = function
		self.line = line
		self.threadID = threadID
		self.appID = appID
		self.frameworkID = frameworkID
		self.userID = userID
		self.deviceID = deviceID
	}
	
	public required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		self.id = try container.decodeIfPresent(UInt64.self, forKey: .id)
		self.date = try container.decode(Date.self, forKey: .date)
		self.severity = try container.decode(Severity.self, forKey: .severity)
		self.message = try container.decode(String.self, forKey: .message)
		self.category = try container.decode(String.self, forKey: .category)
		self.directory = try container.decode(String.self, forKey: .directory)
		self.file = try container.decode(String.self, forKey: .file)
		self.function = try container.decode(String.self, forKey: .function)
		self.line = try container.decode(UInt32.self, forKey: .line)
		self.threadID = try container.decode(Int.self, forKey: .threadID)
		self.appID = try container.decode(String.self, forKey: .appID)
		self.frameworkID = try container.decodeIfPresent(String.self, forKey: .frameworkID)
		self.userID = try container.decodeIfPresent(UUID.self, forKey: .userID)
		self.deviceID = try container.decodeIfPresent(UUID.self, forKey: .deviceID)
	}
	
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encodeIfPresent(id, forKey: .id)
		try container.encode(date, forKey: .date)
		try container.encode(severity, forKey: .severity)
		try container.encode(message, forKey: .message)
		try container.encode(category, forKey: .category)
		try container.encode(directory, forKey: .directory)
		try container.encode(file, forKey: .file)
		try container.encode(function, forKey: .function)
		try container.encode(line, forKey: .line)
		try container.encode(threadID, forKey: .threadID)
		try container.encode(appID, forKey: .appID)
		try container.encodeIfPresent(frameworkID, forKey: .frameworkID)
		try container.encodeIfPresent(userID, forKey: .userID)
		try container.encodeIfPresent(deviceID, forKey: .deviceID)
	}
	
	
	public enum CodingKeys: String, CodingKey {
		case id
		case date
		case severity
		case message
		case category
		case directory
		case file
		case function
		case line
		// TODO: replace customData with appVersion
		// maybe one for build number
		// can I rip that info from Info.plist?
		case threadID = "thread_id"
		case appID = "app_id"
		case frameworkID = "framework_id"
		case userID = "user_id"
		case deviceID = "device_id"
	}
}
